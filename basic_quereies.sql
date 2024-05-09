-- calls by incident type, width description

select Inci_type, 
lookup.Descript, 
avg(date_part('minutes', (Arv_date + Arv_time) - (Alm_date + Alm_time))) as Resp_time, 
avg(Per_supp + Per_ems + Per_rescue + Per_other) as Responding, 
count(*) as Num_calls 
from Inc_main 
left join 
    (select * from Lkp_inci where Category = 'INCI TYPE' and code != 'UUU') lookup 
    on Inc_main.Inci_type = lookup.code where year(Alm_date) in (2020, 2021, 2022, 2023) 
group by 1, 2 
order by 1;

-- collapsed codes
-- in town (not responding for mutual aid)

select case 
when Inci_type <=299 then 'Fire General'
when Inci_type = 321 then 'EMS'
when Inci_type in (322, 323, 324) then 'Motor Vehicle'
when Inci_type >= 300 and Inci_type <= 399 then 'Rescue'
when Inci_type >= 400 and Inci_type <= 499 then 'Hazardous Condition (no fire)'
when Inci_type >= 800 and Inci_type <= 899 then 'Hazardous Condition (no fire)'
when Inci_type >= 500 and Inci_type <= 599 then 'Service Call'
when Inci_type >= 600 and Inci_type <= 699 then 'Good Intent'
when Inci_type >= 700 and Inci_type <= 799 then 'False Alarm'
else Inci_type::varchar
end as Inci_collapsed, 
avg(date_part('minutes', (Arv_date + Arv_time) - (Alm_date + Alm_time))) as Resp_time, 
avg(Per_supp + Per_ems + Per_rescue + Per_other) as Responding, 
count(*) as Num_calls 
from Inc_main 
where year(alm_date) >= 2020 and year(alm_date) <= 2023 and Mutl_aid in ('N', '1', '2')
group by 1
order by 1;

-- response time for mutual aid

select case 
when Inci_type <=299 then 'Fire General'
when Inci_type = 321 then 'EMS'
when Inci_type in (322, 323, 324) then 'Motor Vehicle'
when Inci_type >= 300 and Inci_type <= 399 then 'Rescue'
when Inci_type >= 400 and Inci_type <= 499 then 'Hazardous Condition (no fire)'
when Inci_type >= 800 and Inci_type <= 899 then 'Hazardous Condition (no fire)'
when Inci_type >= 500 and Inci_type <= 599 then 'Service Call'
when Inci_type >= 600 and Inci_type <= 699 then 'Good Intent'
when Inci_type >= 700 and Inci_type <= 799 then 'False Alarm'
else Inci_type::varchar
end as Inci_collapsed, 
avg(date_part('minutes', (Arv_date + Arv_time) - (Alm_date + Alm_time))) as Resp_time, 
avg(Per_supp + Per_ems + Per_rescue + Per_other) as Responding, 
count(*) as Num_calls 
from Inc_main 
where year(alm_date) >= 2020 and year(alm_date) <= 2023 and Mutl_aid in ('3', '4', '5')
group by 1
order by 1;

-- number responding, total:

select (Per_supp + Per_ems + Per_rescue + Per_other) as responding,
count(*) as Num_calls 
from Inc_main 
where year(alm_date) >= 2020 and year(alm_date) <= 2023
group by 1
order by 1;

-- redo that with a join to the responding parties:

select Inc_main.Inci_no,
(Per_supp + Per_ems + Per_rescue + Per_other) as responding_inc,
Act_main.Activ_id,
Act_det.responding,
responding_inc=responding as match
from Inc_main 
left join Act_main on Inc_main.Inci_no = Act_main.Inci_no

where year(Inc_main.alm_date) >= 2020 and year(Inc_main.alm_date) <= 2023 and not match
order by 1;

-- same except for 2 calls which go from 3 -> 4 responding.

select 
    Inc_main.Inci_no,
    (Per_supp + Per_ems + Per_rescue + Per_other) as responding_inc,
    Act_main.Activ_id,
    Act_det.Staff_id
from Inc_main
left join Act_main 
    on Inc_main.Inci_no = Act_main.Inci_no
left join (
    select 
        Activ_id, 
        count(*) as responding
    from Act_det 
    group by 1
    where Unit != 'STAT'
    ) Act_det 
    on Act_main.Activ_id = Act_det.Activ_id
where 
    year(Inc_main.alm_date) >= 2020 
    and year(Inc_main.alm_date) <= 2023 
order by 1;

select hour(alm_time),
count(*) as Num_calls 
from Inc_main 
where year(alm_date) >= 2020 and year(alm_date) <= 2023
group by 1
order by 1; 