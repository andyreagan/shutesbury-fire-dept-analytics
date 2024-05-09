-- .read load.sql

CREATE TABLE Act_det AS SELECT * FROM read_csv(
    'firehouse-exports/Act_det.TXT', 
    header=false, 
    names=['Activ_id', 'Staff_id', 'Hours', 'Act_code', 'Hrs_paid', 'Unit']
    -- auto-detect good enough here
    -- varchar   │ varchar  │ double │ varchar  │  double
    -- types=['VARCHAR', 'VARCHAR', 'FLOAT', 'VARCHAR', 'FLOAT']
);
CREATE TABLE Act_main AS SELECT * FROM read_csv(
    'firehouse-exports/Act_main.TXT',
    header=false,
    names=['Fdid', 'Inci_no', 'Alm_date', 'Activ_id']
    -- int64 │  varchar   │    date    │  varchar
    -- types=[]
);
CREATE TABLE Inc_main AS SELECT * FROM read_csv(
    'firehouse-exports/Inc_main.TXT',
    header=false,
    names=[
        'Inci_id', 
        'Fdid', 
        'Alm_date', 
        'Alm_time', 
        'Alm_dttm', 
        'Inci_no', 
        'Arv_date',
        'Arv_time',
        'Arv_same',
        'Arv_dttm',
        'Ctrl_date', 
        'Ctrl_same',         
        'Ctrl_time', 
        'Ctrl_dttm', 
        'Clr_date', 
        'Clr_same',         
        'Clr_time', 
        'Clr_dttm', 
        'App_supp',
        'Per_supp',
        'App_ems', 
        'Per_ems', 
        'App_rescue',
        'Per_rescue',
        'App_other',
        'Per_other',
        'Inci_type',
        'Mutl_aid',
        'Disp_date',  
        'Disp_same',          
        'Disp_time',  
        'Disp_dttm'
    ]
    -- nullstr='null',
    -- the default parse needed some varchar -> date
    -- but specifying it here caused an error
    -- firehouse was putting `/  /` for empty dates and `/  /       :  :` for empty dttm
    -- so a find-replace of these in the export and it parses correctly automatically 
    -- types=[
    --     'varchar', -- Inci_id, example: _3SB13WG9K
    --     'int64', -- Fdid, example: 11272
    --     'date', -- Alm_date, example: 2013-05-16
    --     'time', -- Alm_time, example: 14:41:00
    --     'varchar', -- Alm_dttm, example: 05/16/2013 14:41:00
    --     'varchar', -- Inci_no, example: 13-0000106
    --     'date', -- 'varchar', -- Arv_date, example: 05/16/2013
    --     'time', --  , example: 14:51:00
    --     'boolean', -- Arv_same, example: true
    --     'varchar', -- Arv_dttm, example: 05/16/2013 14:51:00
    --     'date', -- 'varchar', -- Ctrl_date, example: /  /
    --     'boolean', -- Ctrl_same, example: false
    --     'time', -- Ctrl_time, example:
    --     'varchar', -- Ctrl_dttm, example: /  /       :  :
    --     'date', -- Clr_date, example: 2013-05-16
    --     'boolean', -- Clr_same, example: true
    --     'time', -- Clr_time, example: 15:09:00
    --     'varchar', -- Clr_dttm, example: 05/16/2013 15:09:00
    --     'int64', -- App_supp, example: 0
    --     'int64', -- Per_supp, example: 0
    --     'int64', -- App_ems, example: 0
    --     'int64', -- Per_ems, example: 3
    --     'int64', -- App_rescue, example: 1
    --     'int64', -- Per_rescue, example: 0
    --     'int64', -- App_other, example: 0
    --     'int64', -- Per_other, example: 0
    --     'int64', -- Inci_type, example: 320
    --     'varchar', -- Mutl_aid, example: N
    --     'date', -- 'varchar', -- Disp_date, example: /  /
    --     'boolean', -- Disp_same, example: false
    --     'time', -- Disp_time, example:
    --     'varchar', -- Disp_dttm, example: /  /       :  :
    -- ]
);
CREATE TABLE Inc_unit AS SELECT * FROM read_csv(
    'firehouse-exports/Inc_unit.TXT',
    header=false,
    names=[
        'Unit',
        'Inci_no',
        'Alm_date',
        'Fdid',
        'Unit_id',
        'Resp_code',
        'Arv_date',
        'Arv_same',        
        'Arv_time',
        'Arv_dttm'
    ]
    -- same find-replace as above
    -- fixed the auto-detect on Arv_date
    -- types=[]
);
CREATE TABLE Lkp_inci AS SELECT * FROM read_csv(
    'firehouse-exports/Lkp_inci.TXT',
    header=false,
    names=['Category', 'Code', 'Descript']
    -- types=[]
);
CREATE TABLE Lkp_stf AS SELECT * FROM read_csv(
    'firehouse-exports/Lkp_stf.TXT',
    header=false,
    names=['Category', 'Code', 'Descript']
    -- types=[]
);
CREATE TABLE Stf_main AS SELECT * FROM read_csv(
    'firehouse-exports/Stf_main.TXT',
    header=false,
    names=[
        'Staff_id',
        'Alt_id',
        'Fdid',
        'Service',
        'Last',
        'Hire_date',
        'Adj_date',
        'End_serice',
        'Rank',
        'Rank_date',
        'Status',
        'Stat_date',
        'Career',
        'Station',
        'Shift',
        'Unit',
        'Ins_code',
        'Hide',
        'Miles_stn',
        'DOB',
        'Export_dt',
        'Notes',
        'P_stf_main'
    ]
    -- same trick
    -- DOB should be a date
    -- but I cleared it, so it's varchar (fine)
    -- types=[]
);
