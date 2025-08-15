/* ========= 03_table4.sas (final, minimal IML) =========
   Hotelling’s T² on paired-difference blocks from ANALYTIC_DIF
   Output: WORK.Table4 with Block, N, P, T2, F, df1, df2, p_value
*/

/* ---- RTF export added ---- */
ods rtf close; /* in case a session left it open */
ods _all_ close;
options nodate nonumber;
ods escapechar='^';
ods rtf file="/results/Table4_Hotelling.rtf" style=journal startpage=no bodytitle;
title "Table 4. Multivariate tests of paired changes (Hotelling's T^{super 2})";



/* Block definitions (use the d_* names you actually created) */
%let blk1 = dbmi dfat dmuscl;
%let blk2 = dpf drp dre dvt dmh dsf dbp dgh;
%let blk3 = d_using_stairs d_weekly_average_steps d_KACOLD_Floor d_KACOLD_Duration;
%let blk4 = d_water_intake d_coffee_intake d_tea_intake d_soft_drinks_intake d_fast_food d_fruit_intake_2 d_vegetables_intake_2;
%let blk5 = d_missed_hours d_actual_work_hours d_prodoctivity_wellness d_dailyactivites_wellness
            d_absenteeism_in_2016 d_energy_during_work d_stress_scale d_sleeping_hours d_meditate
            d_work_satisfaction d_besc_recommendation;

proc iml;
/* Read numeric data and column names once */
use analytic_dif;
  read all var _num_ into D;
  read all var _all_  into _dummy[colname=CN];
close analytic_dif;

/* Output dataset */
Block   = repeat(" ", 1, 1);
N = .; P = .; T2 = .; F = .; df1 = .; df2 = .; p_value = .;
create Table4 var {"Block" "N" "P" "T2" "F" "df1" "df2" "p_value"};

/* Helper: select existing columns by name (case-insensitive) */
start TakeCols(D, CN, want);
  have = upcase(CN);
  idx = {};
  do i = 1 to ncol(want);
    pos = loc(have = upcase(want[i]));
    if ncol(pos)>0 then idx = idx || pos;
  end;
  if ncol(idx)=0 then return( J(nrow(D), 0, .) );
  return( D[, idx] );
finish;

/* Helper: compute T², F, dfs, p for a block */
start T2calc(X);
  good = loc(countmiss(X,"row")=0);
  if type(good)='U' then do; n=0; p=ncol(X); return(n||p||.||.||p||0||.); end;
  Y = X[good,]; n = nrow(Y); p = ncol(Y);
  S = cov(Y); m = Y[:,];                    /* mean row vector */
  if n<=p | det(S)<=1e-12 then return(n||p||.||.||p||max(n-p,0)||.);
  T2 = n * m * inv(S) * m`; F = ((n-p)/(p*(n-1))) # T2; df1=p; df2=n-p; pval = 1 - probf(F, df1, df2);
  return(n||p||T2||F||df1||df2||pval);
finish;

/* Macro lists -> IML character row vectors */
w1 = {&blk1};
w2 = {&blk2};
w3 = {&blk3};
w4 = {&blk4};
w5 = {&blk5};

/* ---- Block 1 ---- */
X = TakeCols(D, CN, w1);
if ncol(X)>0 then do; r=T2calc(X); Block="Body composition"; N=r[1]; P=r[2]; T2=r[3]; F=r[4]; df1=r[5]; df2=r[6]; p_value=r[7]; append; end;

/* ---- Block 2 ---- */
X = TakeCols(D, CN, w2);
if ncol(X)>0 then do; r=T2calc(X); Block="Overall health (RAND-36)"; N=r[1]; P=r[2]; T2=r[3]; F=r[4]; df1=r[5]; df2=r[6]; p_value=r[7]; append; end;

/* ---- Block 3 ---- */
X = TakeCols(D, CN, w3);
if ncol(X)>0 then do; r=T2calc(X); Block="Physical activity at work"; N=r[1]; P=r[2]; T2=r[3]; F=r[4]; df1=r[5]; df2=r[6]; p_value=r[7]; append; end;

/* ---- Block 4 ---- */
X = TakeCols(D, CN, w4);
if ncol(X)>0 then do; r=T2calc(X); Block="Diet"; N=r[1]; P=r[2]; T2=r[3]; F=r[4]; df1=r[5]; df2=r[6]; p_value=r[7]; append; end;

/* ---- Block 5 ---- */
X = TakeCols(D, CN, w5);
if ncol(X)>0 then do; r=T2calc(X); Block="Workplace characteristics"; N=r[1]; P=r[2]; T2=r[3]; F=r[4]; df1=r[5]; df2=r[6]; p_value=r[7]; append; end;

close Table4;
quit;

/* Print */
title "Table 4: Multivariate tests of paired changes (Hotelling’s T²)";
proc print data=Table4 label noobs;
  label Block="Block" N="N (complete)" P="Variables"
        T2="Hotelling T²" F="F" df1="df1" df2="df2" p_value="p-value";
  format T2 F 8.3 p_value pvalue6.4;
run;

/* ---- end RTF export ---- */
footnote; title; ods rtf close; ods listing;