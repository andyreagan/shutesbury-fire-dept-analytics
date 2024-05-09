CREATE TABLE Inc_main_extended AS
SELECT
    Inc_main.*,
    -- pull in longer description
    lookup.Descript,
    -- make a collapsed description
    CASE
        WHEN Inci_type <=299 THEN 'Fire General' 
        WHEN Inci_type = 321 THEN 'EMS' 
        WHEN Inci_type in (322, 323, 324) THEN 'Motor Vehicle' 
        WHEN Inci_type >= 300 AND Inci_type <= 399 THEN 'Rescue' 
        WHEN Inci_type >= 400 AND Inci_type <= 499 THEN 'Hazardous Condition (no fire)' 
        WHEN Inci_type >= 800 AND Inci_type <= 899 THEN 'Hazardous Condition (no fire)' 
        WHEN Inci_type >= 500 AND Inci_type <= 599 THEN 'Service Call' 
        WHEN Inci_type >= 600 AND Inci_type <= 699 THEN 'Good Intent' 
        WHEN Inci_type >= 700 AND Inci_type <= 799 THEN 'False Alarm' 
        ELSE Inci_type::VARCHAR 
        END AS Inci_collapsed,  
    -- computed times AND response numbers:
    ((Inc_main.Arv_date + Inc_main.Arv_time) - (Inc_main.Alm_date + Inc_main.Alm_time)) AS Resp_time, 
    (Inc_main.Per_supp + Inc_main.Per_ems + Inc_main.Per_rescue + Inc_main.Per_other) AS NumRespondingBase, 
    coalesce(Act_det_station.responding, 0) AS NumRespondingPersonnel,
    coalesce(Act_det.responding, 0) AS NumRespondingPersonnelScene,
    -- was the call in town?
    Inc_main.Mutl_aid in ('N', '1', '2') AS In_town,
    Act_main.Activ_id
FROM Inc_main 
LEFT JOIN 
    (
        SELECT  * FROM Lkp_inci WHERE Category = 'INCI TYPE' AND code != 'UUU'
    ) lookup 
    ON Inc_main.Inci_type = lookup.code 
LEFT JOIN 
    Act_main 
    ON Inc_main.Inci_no = Act_main.Inci_no
LEFT JOIN 
    (
        SELECT  
            Activ_id, 
            count(*) AS responding
        FROM 
            Act_det
        GROUP BY 1
    ) Act_det_station
    ON Act_main.Activ_id = Act_det_station.Activ_id
LEFT JOIN 
    (
        SELECT  
            Activ_id, 
            count(*) AS responding
        FROM 
            Act_det 
        WHERE 
            Unit != 'STAT' OR Unit IS NULL
        GROUP BY 1
    ) Act_det 
    ON Act_main.Activ_id = Act_det.Activ_id    
;

-- calls by incident type, width description

SELECT  
    Inci_type, 
    Descript, 
    round(avg(date_part('minutes', Resp_time))*10)/10 AS Resp_time, 
    round(avg(NumRespondingBase)*10)/10 AS Responding, 
    count(*) AS Num_calls 
FROM 
    Inc_main_extended 
WHERE 
    YEAR(Alm_date) IN (2020, 2021, 2022, 2023) 
GROUP BY 1, 2 
ORDER BY 1;

-- collapsed codes
-- in town (not responding for mutual aid)

SELECT
    Inci_collapsed, 
    round(avg(date_part('minutes', Resp_time))*10)/10 AS Resp_time, 
    round(avg(NumRespondingBase)*10)/10 AS Responding,  
    count(*) AS Num_calls 
FROM Inc_main_extended 
WHERE 
    YEAR(alm_date) >= 2020 
    AND YEAR(alm_date) <= 2023 
    AND In_town
GROUP BY 1
ORDER BY 1;

-- response time for mutual aid

SELECT  
    Inci_collapsed, 
    round(avg(date_part('minutes', Resp_time))*10)/10 AS Resp_time, 
    round(avg(NumRespondingBase)*10)/10 AS Responding,  
    count(*) AS Num_calls 
FROM Inc_main_extended 
WHERE 
    YEAR(alm_date) >= 2020 
    AND YEAR(alm_date) <= 2023 
    AND NOT In_town
GROUP BY 1
ORDER BY 1;

-- number responding, total:

SELECT  
    NumRespondingBase,
    count(*) AS Num_calls 
FROM 
    Inc_main_extended Inc_main
WHERE 
    YEAR(alm_date) >= 2020 AND YEAR(alm_date) <= 2023
GROUP BY 1
ORDER BY 1;

-- compare the responding counts

SELECT  
    Inc_main.Inci_no,
    NumRespondingBase,
    NumRespondingPersonnel,
    NumRespondingBase=NumRespondingPersonnel AS match
FROM 
    Inc_main_extended Inc_main
WHERE 
    YEAR(Inc_main.alm_date) >= 2020 
    AND YEAR(Inc_main.alm_date) <= 2023 
    AND NOT match
order by 1;

-- ^ same except for 2 calls which go FROM 3 -> 4 responding.
-- number responding, not including to station:

SELECT  
    NumRespondingPersonnelScene,
    count(*) AS Num_calls
FROM 
    Inc_main_extended Inc_main
WHERE 
    YEAR(Inc_main.alm_date) >= 2020 
    AND YEAR(Inc_main.alm_date) <= 2023 
GROUP BY 1
ORDER BY 1;

-- no response calls:

SELECT  
    Inc_main.Inci_no,
    NumRespondingPersonnelScene
FROM 
    Inc_main_extended Inc_main
WHERE 
    YEAR(Inc_main.alm_date) >= 2020 
    AND YEAR(Inc_main.alm_date) <= 2023 
    AND NumRespondingPersonnelScene = 0;

-- by time of day:

SELECT  
    HOUR(alm_time),
    count(*) AS Num_calls 
FROM 
    Inc_main_extended Inc_main 
WHERE 
    YEAR(alm_date) >= 2020 
    AND YEAR(alm_date) <= 2023
GROUP BY 1
ORDER BY 1;

--

CREATE TABLE Act_det_extended AS
SELECT
    Act_det.*,
    REGEXP_EXTRACT(Stf_main.Last, '[A-Za-z]+') AS LastName
FROM
    Act_det
LEFT JOIN 
    Stf_main
    ON Act_det.Staff_id = Stf_main.Staff_id
;

-- top responders within year:

SELECT  
    Act_det.LastName,
    COUNT(*) AS NumCalls,
    (ROUND(COUNT(*)/x.year_count*1000)/10)::VARCHAR || '%' AS PercentageCalls
FROM 
    Inc_main_extended Inc_main
LEFT JOIN 
    Act_det_extended Act_det 
    ON Inc_main.Activ_id = Act_det.Activ_id  
LEFT JOIN
    (
        SELECT  
            YEAR(Inc_main.alm_date) AS year_num, 
            COUNT(*) AS year_count 
        FROM 
            Inc_main
        GROUP BY 1
    ) x
    ON YEAR(Inc_main.alm_date) = x.year_num
WHERE 
    YEAR(Inc_main.alm_date) == 2021
    -- AND (Act_det.Unit != 'STAT' or Act_det.Unit is null)
GROUP BY 
    1, x.year_count
ORDER BY 
    2 DESC;

-- all time

SELECT  
    Act_det.LastName,
    COUNT(*) AS Num_calls
FROM 
    Inc_main_extended Inc_main
LEFT JOIN
    Act_det_extended Act_det 
    ON Inc_main.Activ_id = Act_det.Activ_id
GROUP BY 1
ORDER BY 2 DESC;

-- first call

SELECT  
    LastName,
    MIN(Inc_main.Alm_date) AS First_Call
FROM
    Inc_main_extended Inc_main
LEFT JOIN
    Act_det_extended Act_det 
    ON Inc_main.Activ_id = Act_det.Activ_id
    -- AND (Act_det.Unit != 'STAT' or Act_det.Unit is null)
GROUP BY 1
ORDER BY 2 DESC;

-- add on first call

CREATE TABLE Act_det_extended_firstcall AS
SELECT
    Act_det.*,
    FirstCall.First_Call
FROM
    Act_det
LEFT JOIN 
    (
        SELECT  
            Act_det.Staff_id,
            MIN(Inc_main.Alm_date) AS First_Call
        FROM
            Inc_main_extended Inc_main
        LEFT JOIN
            Act_det_extended Act_det 
            ON Inc_main.Activ_id = Act_det.Activ_id
        GROUP BY 1
        ORDER BY 2 DESC
    ) FirstCall
    ON FirstCall.Staff_id = Act_det.Staff_id
;

-- join staff to
-- all calls
-- based on alm_date >= first_call
-- and alm_date <= retire_date
-- and count the number of matches
-- so we get a view of all time, but also with a %
-- of course, this relies on having a good retire_date
