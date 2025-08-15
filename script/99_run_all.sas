/* 99_run_all.sas — Run all tables end-to-end */

options mprint mlogic symbolgen;
%put NOTE: === Running Wellness tables pipeline ===;

%macro include_if_exists(path);
  %local fileref rc;
  %let fileref = __inc;
  filename &fileref "&path";
  %let rc = %sysfunc(fexist(&fileref));
  %if &rc %then %do;
    %put NOTE: Including &path;
    %include "&path";
  %end;
  %else %do;
    %put WARNING: File not found -> &path;
  %end;
  filename &fileref clear;
%mend;

/* Order: setup -> T2 -> T3 -> T4 */
%include_if_exists(/script/00_setup.sas);
%include_if_exists(/script/01_table2_demographics.sas);
%include_if_exists(/script/02_table3_wilcoxon.sas);
%include_if_exists(/script/03_table4_ HotellingsT2.sas);


%put NOTE: === Pipeline complete ===;