/* ========= 02_table3_wilcoxon.sas (robust) =========
   Input: ANALYTIC_DIF from 00_setup.sas
   Output: Table3 (Median change + Wilcoxon signed-rank p-value)
*/

/* ---- RTF export added ---- */
ods rtf close; /* in case a session left it open */
ods _all_ close;
options nodate nonumber;
ods escapechar='^';
ods rtf file="/results/Table3_Wilcoxon.rtf" style=journal startpage=no bodytitle;
title "Table 3. Paired changes - Median and Wilcoxon signed-rank p-values";



ods exclude all;

/* Initialize output tables so downstream SORT/MERGE never fail */
data Table3_basic; length var $64 label $120 Median 8.; stop; run;
data Table3_tests; length var $64 label $120 P_Wilcoxon 8.; stop; run;

/* Core producer: runs Wilcoxon for one paired-difference variable */
%macro wilcox_pair(var=, label=);
  ods output BasicMeasures=_b TestsForLocation=_t;

  proc univariate data=analytic_dif mu0=0;
    var &var.;
  run;

  /* Median row from BasicMeasures */
  data _b; length var $64 label $120;
    set _b;
    if upcase(LocMeasure)='MEDIAN';
    var="&var."; label="&label.";
    keep var label LocValue; rename LocValue=Median;
  run;

  /* Signed-Rank test row from TestsForLocation */
  data _t; length var $64 label $120;
    set _t;
    /* handle label variants like 'Signed Rank', 'Sign M' across SAS versions */
    if index(upcase(Test),'SIGNED RANK')>0 or index(upcase(Test),'SIGN M')>0;
    var="&var."; label="&label.";
    keep var label pValue; rename pValue=P_Wilcoxon;
  run;

  /* Append (bases were pre-created above) */
  proc append base=Table3_basic data=_b force; run;
  proc append base=Table3_tests data=_t force; run;

  proc datasets nolist; delete _b _t; quit;
%mend;

/* Guard: only run if the variable exists in ANALYTIC_DIF */
%macro wilcox_if_exists(dvar=, label=);
  %local dsid pos rc;
  %let dsid = %sysfunc(open(analytic_dif,i));
  %let pos  = %sysfunc(varnum(&dsid,&dvar));
  %let rc   = %sysfunc(close(&dsid));
  %if &pos > 0 %then %do;
    %wilcox_pair(var=&dvar, label=&label);
  %end;
%mend;

/* -------- Body composition -------- */
%wilcox_if_exists(dvar=dbmi   , label=BMI)
%wilcox_if_exists(dvar=dfat   , label=Body fat percentage)
%wilcox_if_exists(dvar=dmuscl , label=Muscle percentage)

/* -------- RAND-36 scales -------- */
%wilcox_if_exists(dvar=dpf , label=Physical functioning)
%wilcox_if_exists(dvar=drp , label=Role limitations (physical))
%wilcox_if_exists(dvar=dre , label=Role limitations (emotional))
%wilcox_if_exists(dvar=dvt , label=Energy/Fatigue (vitality))
%wilcox_if_exists(dvar=dmh , label=Emotional well-being (mental health))
%wilcox_if_exists(dvar=dsf , label=Social functioning)
%wilcox_if_exists(dvar=dbp , label=Pain)
%wilcox_if_exists(dvar=dgh , label=General health)

/* -------- Physical activity at work -------- */
%wilcox_if_exists(dvar=d_using_stairs         , label=Using stairs at work)
%wilcox_if_exists(dvar=d_weekly_average_steps , label=Weekly average steps)
%wilcox_if_exists(dvar=d_KACOLD_Floor         , label=19-story building floors climbed)
%wilcox_if_exists(dvar=d_KACOLD_Duration      , label=Duration to climb 19-story building (min))

/* ---------------- Diet ---------------- */
%wilcox_if_exists(dvar=d_water_intake         , label=Liters of water per day)
%wilcox_if_exists(dvar=d_coffee_intake        , label=Cups of coffee per day)
%wilcox_if_exists(dvar=d_tea_intake           , label=Cups of tea per day)
%wilcox_if_exists(dvar=d_soft_drinks_intake   , label=Soft drinks per week)
%wilcox_if_exists(dvar=d_fast_food            , label=Fast food consumption)
%wilcox_if_exists(dvar=d_fruit_intake_2       , label=Fruit intake)
%wilcox_if_exists(dvar=d_vegetables_intake_2  , label=Vegetable intake)

/* -------- Workplace characteristics -------- */
%wilcox_if_exists(dvar=d_missed_hours             , label=Missed hours)
%wilcox_if_exists(dvar=d_actual_work_hours        , label=Actual work hours)
%wilcox_if_exists(dvar=d_prodoctivity_wellness    , label=Productivity (wellness))
%wilcox_if_exists(dvar=d_dailyactivites_wellness  , label=Daily activities (wellness))
%wilcox_if_exists(dvar=d_absenteeism_in_2016      , label=Absenteeism in 2016)
%wilcox_if_exists(dvar=d_energy_during_work       , label=Energy during work)
%wilcox_if_exists(dvar=d_stress_scale             , label=Stress scale)
%wilcox_if_exists(dvar=d_sleeping_hours           , label=Sleeping hours)
%wilcox_if_exists(dvar=d_meditate                 , label=Meditation)
%wilcox_if_exists(dvar=d_work_satisfaction        , label=Work satisfaction)
%wilcox_if_exists(dvar=d_besc_recommendation      , label=Recommend program (BESC))

/* -------- Combine & report -------- */
ods exclude none;

proc sort data=Table3_basic; by var; run;
proc sort data=Table3_tests; by var; run;

data Table3; merge Table3_basic Table3_tests; by var; run;

title "Table 3: Paired changes — Median and Wilcoxon signed-rank p-values";
proc report data=Table3 nowd split='*';
  columns label Median P_Wilcoxon;
  define label / display "Measure";
  define Median / display "Median change";
  define P_Wilcoxon / display "P (Wilcoxon)";
run;

/* (Optional) descriptive stats on differences */
title "Supplement: Mean and SD of paired differences";
proc means data=analytic_dif mean std maxdec=2;
  var dbmi dfat dmuscl
      dpf drp dre dvt dmh dsf dbp dgh
      d_using_stairs d_weekly_average_steps d_KACOLD_Floor d_KACOLD_Duration
      d_water_intake d_coffee_intake d_tea_intake d_soft_drinks_intake d_fast_food
      d_fruit_intake_2 d_vegetables_intake_2
      d_missed_hours d_actual_work_hours d_prodoctivity_wellness d_dailyactivites_wellness
      d_absenteeism_in_2016 d_energy_during_work d_stress_scale d_sleeping_hours d_meditate
      d_work_satisfaction d_besc_recommendation;
run;

/* ---- end RTF export ---- */
footnote; title; ods rtf close; ods listing;