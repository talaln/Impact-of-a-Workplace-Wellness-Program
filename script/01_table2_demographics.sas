/* ---- RTF export added ---- */
ods rtf close; /* in case a session left it open */
ods _all_ close;
options nodate nonumber;
ods escapechar='^';
ods rtf file="/results/Table2_Demographics.rtf" style=journal startpage=no bodytitle;
title "Table 2. Demographic and Clinical Characteristics";

/* ========= 01_table2_demographics.sas ========= */
/* Formats */
proc format;
  value $yn   '1'='Yes' '0'='No';
  value gender 1='Male' 2='Female';
  value marital 1='Single' 2='Married' 3='Divorced' 4='Separated' 5='Engaged';
  value Agefmt 21-29='21-29' 30-39='30-39' 40-49='40-49' 50-59='50-59' 60-High='60 and older';
  
/* Baseline sample (all) */
title "Table 2. Demographic and Clinical Characteristics - Baseline";
proc freq data=WORK.base_survey;
  /* Replace the variables below with those in your file (age, gender, etc.) */
  tables age gender marital smoker / missing;
  format gender gender. age agefmt.;
run;

/* Post sample (completers only) */
proc sql;
  create table _ids as
  select distinct &idvar. from analytic;
quit;

proc sort data=_ids; by &idvar.; run;
proc sort data=post_survey; by &idvar.; run;

data post_completers;
  merge WORK.post_survey(in=p) _ids(in=k);
  by &idvar.;
  if p and k;
run;

title "Table 2. Demographic and Clinical Characteristics - Post (Completers)";
proc freq data=post_completers;
  tables age gender marital smoker / missing;
  format gender gender. age agefmt.;
run;

/* Example for checkbox tallies (edit prefix/names to your data):
   Suppose chronic disease checkboxes are chronic___1, chronic___2, ...
*/
proc sql;
  title "Baseline Chronic Conditions (counts)";
  select
    sum(chronic_diseases___1=0 and chronic_diseases___2=0 and chronic_diseases___3=0 and chronic_diseases___4=0 and chronic_diseases___5=0 and chronic_diseases___6=0 and chronic_diseases___7=0) as None,
    sum(chronic_diseases___1=1) as Diabetes,
    sum(chronic_diseases___2=1) as Hypertension,
    sum(chronic_diseases___3=1) as Asthma,
    sum(chronic_diseases___5=1) as Arthiritis,
    sum(chronic_diseases___4=1 and chronic_diseases___6=1 and chronic_diseases___7=1) as Other
  from WORK.base_survey;

  title "Post (Completers) Chronic Conditions (counts)";
  select
  	sum(chronic_diseases___1=0 and chronic_diseases___2=0 and chronic_diseases___3=0 and chronic_diseases___4=0 and chronic_diseases___5=0 and chronic_diseases___6=0 and chronic_diseases___7=0) as None,
    sum(chronic_diseases___1=1) as Diabetes,
    sum(chronic_diseases___2=1) as Hypertension,
    sum(chronic_diseases___3=1) as Asthma,
    sum(chronic_diseases___5=1) as Arthiritis,
    sum(chronic_diseases___4=1 and chronic_diseases___6=1 and chronic_diseases___7=1) as Other
  from post_completers;
quit;

/* Optional N checks */
title "Sample sizes";
proc sql;
  select count(*) as N_baseline from WORK.base_survey;
  select count(*) as N_post     from WORK.post_survey;
  select count(*) as N_pairs    from analytic;
quit;


/* ---- end RTF export ---- */
footnote; title; ods rtf close; ods listing;
