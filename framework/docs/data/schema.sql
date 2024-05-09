


CREATE TABLE Act_det(Activ_id VARCHAR, Staff_id VARCHAR, "Hours" DOUBLE, Act_code VARCHAR, Hrs_paid DOUBLE, Unit VARCHAR);
CREATE TABLE Act_det_extended(Activ_id VARCHAR, Staff_id VARCHAR, "Hours" DOUBLE, Act_code VARCHAR, Hrs_paid DOUBLE, Unit VARCHAR, LastName VARCHAR);
CREATE TABLE Act_det_extended_firstcall(Activ_id VARCHAR, Staff_id VARCHAR, "Hours" DOUBLE, Act_code VARCHAR, Hrs_paid DOUBLE, Unit VARCHAR, First_Call DATE);
CREATE TABLE Act_main(Fdid BIGINT, Inci_no VARCHAR, Alm_date DATE, Activ_id VARCHAR);
CREATE TABLE Inc_main(Inci_id VARCHAR, Fdid BIGINT, Alm_date DATE, Alm_time TIME, Alm_dttm VARCHAR, Inci_no VARCHAR, Arv_date DATE, Arv_time TIME, Arv_same BOOLEAN, Arv_dttm VARCHAR, Ctrl_date DATE, Ctrl_same BOOLEAN, Ctrl_time TIME, Ctrl_dttm VARCHAR, Clr_date DATE, Clr_same BOOLEAN, Clr_time TIME, Clr_dttm VARCHAR, App_supp BIGINT, Per_supp BIGINT, App_ems BIGINT, Per_ems BIGINT, App_rescue BIGINT, Per_rescue BIGINT, App_other BIGINT, Per_other BIGINT, Inci_type BIGINT, Mutl_aid VARCHAR, Disp_date DATE, Disp_same BOOLEAN, Disp_time TIME, Disp_dttm VARCHAR);
CREATE TABLE Inc_main_extended(Inci_id VARCHAR, Fdid BIGINT, Alm_date DATE, Alm_time TIME, Alm_dttm VARCHAR, Inci_no VARCHAR, Arv_date DATE, Arv_time TIME, Arv_same BOOLEAN, Arv_dttm VARCHAR, Ctrl_date DATE, Ctrl_same BOOLEAN, Ctrl_time TIME, Ctrl_dttm VARCHAR, Clr_date DATE, Clr_same BOOLEAN, Clr_time TIME, Clr_dttm VARCHAR, App_supp BIGINT, Per_supp BIGINT, App_ems BIGINT, Per_ems BIGINT, App_rescue BIGINT, Per_rescue BIGINT, App_other BIGINT, Per_other BIGINT, Inci_type BIGINT, Mutl_aid VARCHAR, Disp_date DATE, Disp_same BOOLEAN, Disp_time TIME, Disp_dttm VARCHAR, Descript VARCHAR, Inci_collapsed VARCHAR, Resp_time INTERVAL, Resp_time_minutes DOUBLE, NumRespondingBase BIGINT, NumRespondingPersonnel BIGINT, NumRespondingPersonnelScene BIGINT, In_town BOOLEAN, Activ_id VARCHAR);
CREATE TABLE Inc_unit(Unit VARCHAR, Inci_no VARCHAR, Alm_date DATE, Fdid BIGINT, Unit_id VARCHAR, Resp_code VARCHAR, Arv_date DATE, Arv_same BOOLEAN, Arv_time TIME, Arv_dttm VARCHAR);
CREATE TABLE Lkp_inci(Category VARCHAR, Code VARCHAR, Descript VARCHAR);
CREATE TABLE Lkp_stf(Category VARCHAR, Code VARCHAR, Descript VARCHAR);
CREATE TABLE Stf_main(Staff_id VARCHAR, Alt_id VARCHAR, Fdid BIGINT, Service VARCHAR, "Last" VARCHAR, Hire_date DATE, Adj_date DATE, End_serice DATE, Rank VARCHAR, Rank_date DATE, Status VARCHAR, Stat_date DATE, Career BIGINT, Station VARCHAR, Shift VARCHAR, Unit VARCHAR, Ins_code VARCHAR, Hide BOOLEAN, Miles_stn DOUBLE, DOB VARCHAR, Export_dt DATE, Notes VARCHAR);




