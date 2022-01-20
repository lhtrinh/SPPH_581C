*specify data location;
libname data 'D:\Jason\UBC\teaching\SPPH_581\winter_2022\topics\lecture_1_cluster_analysis\data';
*options user=data;

*import data;
*(all column names were changed in Excel before importing);
proc import datafile='D:\Jason\UBC\teaching\SPPH_581\winter_2022\topics\lecture_1_cluster_analysis\data\Ontario_hospital_data.csv'
	out=data.hosp_data
	dbms=csv replace;
run;

*print the first 5 lines;
proc print data=data.hosp_data (obs=5);
run;

*data summary;
proc contents data=data.hosp_data;
run;

*descriptive statistics;
proc means data=data.hosp_data
	N Nmiss mean std min median max;
run;


****maybe for presenting the results, you'll consider running the same proc means, though stratified by cluster?;

/****************************
Exploratory plots
****************************/

*plot pairs of performance metrics;
proc sgscatter data=data.hosp_data;
	title "Pairwise Scatter Plots of Hospital Quality Indicators";
	 matrix smr infect_rate patient_quality cont_transition informed_care;
run;
title;

****I see you changed the variable titles! confused me for a couple of minutes!;
****I inserted this code;
data data.hosp_data;
	set data.hosp_data;
	rename
	Standardized_Mortality_Ratio=smr Infection_Rate=infect_rate Patient_Quality_Positive=patient_quality 
	Continuity_and_Transition_Positi=cont_transition Informed_Care_Positive=informed_care;
	run;

/*Low SMR and infection rate indicate high quality
change to 1-smr and 1-infect_rate to minimize Euclidean distance*/
proc sql;
   create table data.hosp_new like data.hosp_data;
   insert into data.hosp_new
   select * from data.hosp_data;
   
proc sql;
	alter table data.hosp_new 
	add smr_inv int
	add infect_inv int;
   
proc sql;
   update data.hosp_new
      set smr_inv=1-smr, infect_inv=1-infect_rate;
   select *
      from data.hosp_new;
quit;




/*SMR and infection rate are positively correlated
patient quality, continuity and transition, 
and informed care are pairwise positively correlated
no apparent relationship between pairs of each group*/


/*Hierarchical clustering
*/
*select variables for clustering;
%let hosp_clus = smr_inv infect_inv patient_quality cont_transition informed_care;


*clustering process;
proc cluster data=data.hosp_new outtree=tree method=average pseudo ccc rsq plots=all;
	title "Hierarchical Clustering Method using Ward Linkage";
	var &hosp_clus.;
run;

proc tree data=tree out=out n=5;
	title "Hierarchical clustering method";
    copy &hosp_clus.;
run;

*plot quality indictors by cluster;
proc sgplot data=out;
	vbox smr / group=cluster;
run;
proc sgplot data=out;
	vbox infect_rate / group=cluster;
run;
proc sgplot data=out;
	vbox patient_quality / group=cluster;
run;
proc sgplot data=out;
	vbox cont_transition / group=cluster;
run;
proc sgplot data=out;
	vbox informed_care / group=cluster;
run;

