/*===============================================================
  00_setup.sas
  Shared setup for Wellness tables (RTF only)
===============================================================*/

*Import Baseline survey data;
PROC IMPORT DATAFILE='/script/Base_DATA_synth.csv' /* <-- adjust if needed */
	OUT=WORK.base_survey
	DBMS=CSV replace;
	guessingrows=max;
RUN;

*Import Baseline measurements data;
PROC IMPORT DATAFILE='/script/Base_Measurement_Data_synth.xlsx' /* <-- adjust if needed */
	OUT=WORK.base_measures
	DBMS=XLSX replace;
	SHEET="Base_Measurement_Data";
	GETNAMES=YES;
RUN;

*Import Post-intervention survey data;
PROC IMPORT DATAFILE='/script/Post_DATA_synth.csv' /* <-- adjust if needed */
	OUT=WORK.post_survey
	DBMS=CSV replace;
	guessingrows=max;
RUN;

*Import Post-intervention measurements data;
PROC IMPORT DATAFILE='/script/Post_Measurement_Data_synth.xlsx' /* <-- adjust if needed */
	OUT=WORK.post_measures
	DBMS=XLSX replace;
	SHEET="Post_Measurement_Data";
	GETNAMES=YES;
RUN;


options mprint mlogic symbolgen;
ods listing;

/* ------------ Config ------------ */
%let idvar = employee_id;

/* ------------ Make ID a character in all inputs (simple, safe) ------------ */
%macro force_char_id(ds=, id=&idvar, len=64);
data &ds.;
  length __idc $&len.;
  set &ds.;
  __idc = strip(vvalue(&id));  /* works whether &id is numeric or char */
  drop &id;
  rename __idc=&id;
run;
%mend;

%force_char_id(ds=WORK.base_survey)
%force_char_id(ds=WORK.post_survey)
%force_char_id(ds=WORK.base_measures)
%force_char_id(ds=WORK.post_measures)

/* ------------ RAND-36 scoring helpers ------------ */
%macro rand_recode(invar, outvar, key);
  %if &key=A %then %do;        /* 1->100,2->75,3->50,4->25,5->0 */
    &outvar=.; if &invar in (1,2,3,4,5) then do;
      select(&invar); when(1) &outvar=100; when(2) &outvar=75; when(3) &outvar=50; when(4) &outvar=25; when(5) &outvar=0; otherwise &outvar=.; end; end;
  %end;
  %else %if &key=B %then %do;  /* 1->0,2->50,3->100 */
    &outvar=.; if &invar in (1,2,3) then do;
      select(&invar); when(1) &outvar=0; when(2) &outvar=50; when(3) &outvar=100; otherwise &outvar=.; end; end;
  %end;
  %else %if &key=C %then %do;  /* 1->0,2->100 */
    &outvar=.; if &invar in (1,2) then do;
      select(&invar); when(1) &outvar=0; when(2) &outvar=100; otherwise &outvar=.; end; end;
  %end;
  %else %if &key=D %then %do;  /* 1->100..6->0 */
    &outvar=.; if &invar in (1,2,3,4,5,6) then do;
      select(&invar); when(1) &outvar=100; when(2) &outvar=80; when(3) &outvar=60; when(4) &outvar=40; when(5) &outvar=20; when(6) &outvar=0; otherwise &outvar=.; end; end;
  %end;
  %else %if &key=E %then %do;  /* 1->0..6->100 */
    &outvar=.; if &invar in (1,2,3,4,5,6) then do;
      select(&invar); when(1) &outvar=0; when(2) &outvar=20; when(3) &outvar=40; when(4) &outvar=60; when(5) &outvar=80; when(6) &outvar=100; otherwise &outvar=.; end; end;
  %end;
  %else %if &key=F %then %do;  /* 1->0..5->100 */
    &outvar=.; if &invar in (1,2,3,4,5) then do;
      select(&invar); when(1) &outvar=0; when(2) &outvar=25; when(3) &outvar=50; when(4) &outvar=75; when(5) &outvar=100; otherwise &outvar=.; end; end;
  %end;
%mend;

%macro score_rand36(in=, out=);
data &out.;
  set &in.;

  /* A: {1,2,20,22,34,36} */
  %rand_recode(rate_health               , r1 , A)
  %rand_recode(compare_health            , r2 , A)
  %rand_recode(extent_of_physical_health , r20, A)
  %rand_recode(pain_interferance         , r22, A)
  %rand_recode(healthy_as_anybody        , r34, A)
  %rand_recode(excellent_health          , r36, A)

  /* B: {3–12} */
  %rand_recode(vigorous                      , r3 , B)
  %rand_recode(moderate                      , r4 , B)
  %rand_recode(carrying_groceries            , r5 , B)
  %rand_recode(flights_of_stairs             , r6 , B)
  %rand_recode(climbing_one_flight_of_stairs , r7 , B)
  %rand_recode(bending_2                     , r8 , B)
  %rand_recode(walking_more_than_a_mile      , r9 , B)
  %rand_recode(walking_several_blocks        , r10, B)
  %rand_recode(walking_one_block             , r11, B)
  %rand_recode(bathing_or_dressing           , r12, B)

  /* C: {13–19} */
  %rand_recode(cut_down_work_time         , r13, C)
  %rand_recode(accomplished_less_than_you , r14, C)
  %rand_recode(limit_work                 , r15, C)
  %rand_recode(difficulty_performing_work , r16, C)
  %rand_recode(cut_down_time              , r17, C)
  %rand_recode(accomplish_less            , r18, C)
  %rand_recode(didnt_do_work_carefuly     , r19, C)

  /* D: {21,23,26,27,30} */
  %rand_recode(bodily_pain         , r21, D)
  %rand_recode(pep                 , r23, D)
  %rand_recode(calm_and_peacful    , r26, D)
  %rand_recode(a_lot_of_energy     , r27, D)
  %rand_recode(been_a_happy_person , r30, D)

  /* E: {24,25,28,29,31} */
  %rand_recode(very_nervous              , r24, E)
  %rand_recode(felt_dumps                , r25, E)
  %rand_recode(have_you_felt_downhearted , r28, E)
  %rand_recode(did_you_feel_worn_out     , r29, E)
  %rand_recode(did_you_feel_tired        , r31, E)

  /* F: {32,33,35} */
  %rand_recode(ph_interferance          , r32, F)
  %rand_recode(get_sick_a_little_easier , r33, F)
  %rand_recode(expect_worst_health      , r35, F)

  /* Scales */
  pf = mean(of r3-r12);
  rp = mean(of r13-r16);
  re = mean(of r17-r19);
  vt = mean(of r23 r27 r29 r31);
  mh = mean(of r24 r25 r26 r28 r30);
  sf = mean(of r20 r32);
  bp = mean(of r21 r22);
  gh = mean(of r1  r33 r34 r35 r36);

  keep &idvar pf rp re vt mh sf bp gh;
run;
%mend;

/* Score baseline/post surveys */
%score_rand36(in=WORK.base_survey, out=base_scored)
%score_rand36(in=WORK.post_survey, out=post_scored)

/* ------------ Keep extra survey vars (as-is) ------------ */
/* Edit this list only if names differ in your files */
%let survey_extras =
  using_stairs weekly_average_steps
  water_intake coffee_intake tea_intake soft_drinks_intake fast_food
  fruit_intake_2 vegetables_intake_2
  missed_hours actual_work_hours prodoctivity_wellness dailyactivites_wellness
  absenteeism_in_2016 energy_during_work stress_scale sleeping_hours meditate
  work_satisfaction besc_recommendation;

data base_extra; set WORK.base_survey(keep=&idvar &survey_extras); run;
data post_extra; set WORK.post_survey(keep=&idvar &survey_extras); run;

/* ------------ Harmonize measurements (incl. KACOLD vars) ------------ */
/* KACOLD_Floor and KACOLD_Duration are in the MEASUREMENTS datasets */
data base_meas_k;
  set WORK.base_measures(keep=&idvar Height_cm Weight_kg BMI Body_fat_percentage Muscle_percentage
                               KACOLD_Floor KACOLD_Duration);
  rename Height_cm=height_cm Weight_kg=weight_kg BMI=bmi
         Body_fat_percentage=fat_pct Muscle_percentage=muscle_pct
         KACOLD_Floor=kacold_floor KACOLD_Duration=kacold_duration;
run;

data post_meas_k;
  set WORK.post_measures(keep=&idvar Height_cm Weight_kg BMI Body_fat_percentage Muscle_percentage
                               KACOLD_Floor KACOLD_Duration);
  rename Height_cm=height_cm Weight_kg=weight_kg BMI=bmi
         Body_fat_percentage=fat_pct Muscle_percentage=muscle_pct
         KACOLD_Floor=kacold_floor KACOLD_Duration=kacold_duration;
run;

/* ------------ Sort & merge (completers only) ------------ */
proc sort data=base_scored;  by &idvar; run;
proc sort data=post_scored;  by &idvar; run;
proc sort data=base_extra;   by &idvar; run;
proc sort data=post_extra;   by &idvar; run;
proc sort data=base_meas_k;  by &idvar; run;
proc sort data=post_meas_k;  by &idvar; run;

data analytic;
  merge base_scored (in=a rename=(pf=pf_b rp=rp_b re=re_b vt=vt_b mh=mh_b sf=sf_b bp=bp_b gh=gh_b))
        post_scored (in=p rename=(pf=pf_p rp=rp_p re=re_p vt=vt_p mh=mh_p sf=sf_p bp=bp_p gh=gh_p))
        base_extra  (rename=(
          using_stairs=using_stairs_b weekly_average_steps=weekly_average_steps_b
          water_intake=water_intake_b coffee_intake=coffee_intake_b tea_intake=tea_intake_b
          soft_drinks_intake=soft_drinks_intake_b fast_food=fast_food_b
          fruit_intake_2=fruit_intake_2_b vegetables_intake_2=vegetables_intake_2_b
          missed_hours=missed_hours_b actual_work_hours=actual_work_hours_b
          prodoctivity_wellness=prodoctivity_wellness_b dailyactivites_wellness=dailyactivites_wellness_b
          absenteeism_in_2016=absenteeism_in_2016_b energy_during_work=energy_during_work_b
          stress_scale=stress_scale_b sleeping_hours=sleeping_hours_b meditate=meditate_b
          work_satisfaction=work_satisfaction_b besc_recommendation=besc_recommendation_b))
        post_extra  (rename=(
          using_stairs=using_stairs_p weekly_average_steps=weekly_average_steps_p
          water_intake=water_intake_p coffee_intake=coffee_intake_p tea_intake=tea_intake_p
          soft_drinks_intake=soft_drinks_intake_p fast_food=fast_food_p
          fruit_intake_2=fruit_intake_2_p vegetables_intake_2=vegetables_intake_2_p
          missed_hours=missed_hours_p actual_work_hours=actual_work_hours_p
          prodoctivity_wellness=prodoctivity_wellness_p dailyactivites_wellness=dailyactivites_wellness_p
          absenteeism_in_2016=absenteeism_in_2016_p energy_during_work=energy_during_work_p
          stress_scale=stress_scale_p sleeping_hours=sleeping_hours_p meditate=meditate_p
          work_satisfaction=work_satisfaction_p besc_recommendation=besc_recommendation_p))
        base_meas_k (rename=(bmi=bmi_b fat_pct=fat_b muscle_pct=muscle_b
                             height_cm=height_b weight_kg=weight_b
                             kacold_floor=kacold_floor_b kacold_duration=kacold_duration_b))
        post_meas_k (rename=(bmi=bmi_p fat_pct=fat_p muscle_pct=muscle_p
                             height_cm=height_p weight_kg=weight_p
                             kacold_floor=kacold_floor_p kacold_duration=kacold_duration_p));
  by &idvar;
  if a and p; /* completers only */
run;

/* ------------ Paired differences (for Table 3) ------------ */
data analytic_dif;
  set analytic;

  /* body composition */
  dbmi   = bmi_p   - bmi_b;
  dfat   = fat_p   - fat_b;
  dmuscl = muscle_p- muscle_b;

  /* RAND-36 */
  dpf=pf_p-pf_b; drp=rp_p-rp_b; dre=re_p-re_b; dvt=vt_p-vt_b;
  dmh=mh_p-mh_b; dsf=sf_p-sf_b; dbp=bp_p-bp_b; dgh=gh_p-gh_b;

  /* physical activity at work */
  d_using_stairs         = using_stairs_p         - using_stairs_b;
  d_weekly_average_steps = weekly_average_steps_p - weekly_average_steps_b;
  d_KACOLD_Floor         = kacold_floor_p         - kacold_floor_b;      /* from measures */
  d_KACOLD_Duration      = kacold_duration_p      - kacold_duration_b;   /* from measures */

  /* diet */
  d_water_intake         = water_intake_p         - water_intake_b;
  d_coffee_intake        = coffee_intake_p        - coffee_intake_b;
  d_tea_intake           = tea_intake_p           - tea_intake_b;
  d_soft_drinks_intake   = soft_drinks_intake_p   - soft_drinks_intake_b;
  d_fast_food            = fast_food_p            - fast_food_b;
  d_fruit_intake_2       = fruit_intake_2_p       - fruit_intake_2_b;
  d_vegetables_intake_2  = vegetables_intake_2_p  - vegetables_intake_2_b;

  /* workplace characteristics */
  d_missed_hours             = missed_hours_p             - missed_hours_b;
  d_actual_work_hours        = actual_work_hours_p        - actual_work_hours_b;
  d_prodoctivity_wellness    = prodoctivity_wellness_p    - prodoctivity_wellness_b;
  d_dailyactivites_wellness  = dailyactivites_wellness_p  - dailyactivites_wellness_b;
  d_absenteeism_in_2016      = absenteeism_in_2016_p      - absenteeism_in_2016_b;
  d_energy_during_work       = energy_during_work_p       - energy_during_work_b;
  d_stress_scale             = stress_scale_p             - stress_scale_b;
  d_sleeping_hours           = sleeping_hours_p           - sleeping_hours_b;
  d_meditate                 = meditate_p                 - meditate_b;
  d_work_satisfaction        = work_satisfaction_p        - work_satisfaction_b;
  d_besc_recommendation      = besc_recommendation_p      - besc_recommendation_b;
run;

/* ------------ Quick checks (optional) ------------ */
title "Pair count (analytic)"; proc sql; select count(*) as N_pairs from analytic; quit;
title "Non-missing counts (key diffs)"; proc means data=analytic_dif n nmiss; var dbmi dpf d_using_stairs d_KACOLD_Floor; run;
