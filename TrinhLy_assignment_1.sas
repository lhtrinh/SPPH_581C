/*****************************************
CLUSTERING
*****************************************/

*specify data location;
libname data '/home/u60658011/SPPH_581C/cluster_analysis/';
*options user=data;

/*import data;
(all column names changed in Excel before importing)*/
proc import datafile='/home/u60658011/SPPH_581C/cluster_analysis/Ontario_hospital_data.csv'
	out=data.hosp_data
	dbms=csv replace;
run;

*print the first 5 lines;
proc print data=data.hosp_data (obs=5);
run;

*summary statistics;
proc means data=data.hosp_data
	/*count, number of missing cells, mean, SD, and 5-number summary*/
	N Nmiss mean std min q1 median q3 max;
run;

/****************************
Exploratory plots
****************************/
*correlation of hosp characteristics;
proc sgscatter data=data.hosp_data;
	title "Pairwise Scatter Plots of Hospital Characteristics";
	 matrix avg_bed acute_day er_visit or_case;
run;
title;

*correlation plots of performance metrics;
proc sgscatter data=data.hosp_data;
	title "Pairwise Scatter Plots of Hospital Quality Indicators";
	 matrix smr infect_rate patient_quality cont_transition informed_care;
run;
title;
/*SMR and infection rate are positively correlated
patient quality, continuity and transition, 
and informed care are pairwise positively correlated
no apparent relationship between pairs of each group*/




/*ENGINEERING:
Low SMR and infection rate indicate high quality
Change to 1-smr and 1-infect_rate to minimize Euclidean distance
*/

*Use SQL queries to create a copy of the data;
proc sql;
   create table data.hosp_new like data.hosp_data;
   insert into data.hosp_new
   select * from data.hosp_data;

*Add new placeholders for inverted SMR and infection rate;   
proc sql;
	alter table data.hosp_new 
	add smr_inv int
	add infect_inv int;

*assign value to new variables from existing vars;
proc sql;
   update data.hosp_new
      set smr_inv=1-smr, infect_inv=1-infect_rate;
   select *
      from data.hosp_new;
quit;

*view new data;
proc print data=data.hosp_new (obs=5);
run;



*select variables for clustering;
%let hosp_clus = smr_inv infect_inv patient_quality cont_transition informed_care;

/***********************************************
K-MEANS CLUSTERING
(Clunky, need to figure out how to loop this part)
***********************************************/

*kmeans clustering function;
%macro kmeans(kval);
	proc fastclus data=data.hosp_new maxc=&kval. out=km_out&kval. outstat=clusstat&kval.;
		title "K-Means Clustering Solution";
		var &hosp_clus.;
	run;
%mend;

*run function on k from 1-10;
%kmeans(1);
%kmeans(2);
%kmeans(3);
%kmeans(4);
%kmeans(5);
%kmeans(6);
%kmeans(7);
%kmeans(8);
%kmeans(9);
%kmeans(10);

*extract diagnostic stats;
data kclus1;
	set clusstat1;
	nclust=1;
	if _type_ in ('CCC', 'PSEUDO_F', 'RSQ');
	keep nclust _type_ over_all;
run;

data kclus2;
	set clusstat2;
	nclust=2;
	if _type_ in ('CCC', 'PSEUDO_F', 'RSQ');
	keep nclust _type_ over_all;
run;

data kclus3;
	set clusstat3;
	nclust=3;
	if _type_ in ('CCC', 'PSEUDO_F', 'RSQ');
	keep nclust _type_ over_all;
run;

data kclus4;
	set clusstat4;
	nclust=4;
	if _type_ in ('CCC', 'PSEUDO_F', 'RSQ');
	keep nclust _type_ over_all;
run;

data kclus5;
	set clusstat5;
	nclust=5;
	if _type_ in ('CCC', 'PSEUDO_F', 'RSQ');
	keep nclust _type_ over_all;
run;

data kclus6;
	set clusstat6;
	nclust=6;
	if _type_ in ('CCC', 'PSEUDO_F', 'RSQ');
	keep nclust _type_ over_all;
run;

data kclus7;
	set clusstat7;
	nclust=7;
	if _type_ in ('CCC', 'PSEUDO_F', 'RSQ');
	keep nclust _type_ over_all;
run;

data kclus8;
	set clusstat8;
	nclust=8;
	if _type_ in ('CCC', 'PSEUDO_F', 'RSQ');
	keep nclust _type_ over_all;
run;

data kclus9;
	set clusstat9;
	nclust=9;
	if _type_ in ('CCC', 'PSEUDO_F', 'RSQ');
	keep nclust _type_ over_all;
run;

data kclus10;
	set clusstat10;
	nclust=10;
	if _type_ in ('CCC', 'PSEUDO_F', 'RSQ');
	keep nclust _type_ over_all;
run;


*combine r-squared stats into the same dataset;
data clus_plot;
	set kclus1 kclus2 kclus3 kclus4 kclus5 kclus6 kclus7 kclus8 kclus9 kclus10;
run;


*plot each statistic by no. clusters;
proc sgpanel data=clus_plot;
	title 'Cluster Size Evaluation Methods';
	panelby _type_ / rows=3 columns=1 uniscale=column;
	series x=nclust y=over_all;
run;
title;
/*K-means yields k=3 as the optimal number of clusters*/


/********************************
Explore hospital characteristics
********************************/
/*sort data by id variable*/
proc sort data=km_out3 out=km_sorted; 
      by org_name;
run;
/*transform data, row = per patient per metric*/
proc transpose data=km_sorted 
	out=km_long(rename=(Col1=value)) 
	name=indicator;
	var &hosp_clus.;
	by org_name cluster;
run;
/*sort transformed data by cluster*/
proc sort data=km_long out=km_long2; 
	by cluster;
run;

*plot histograms of quality indictors by cluster;
proc sgpanel data=km_long;
	title "Distributions of Hospital Quality Scores";
	panelby indicator / rows=5 columns=1 uniscale=column;
	density value / group=cluster;
run;
title;
*either clus 2 or 3;


/*Hospital characteristics for each cluster*/
proc sort data=km_out3 out=km_out3_sorted;
      by cluster;
run;
*summary statistics;
proc means data=km_out3_sorted
	alpha=0.05 clm mean std min median max;
	var avg_bed acute_day er_visit or_case;
	by cluster;
run;


/*Select hospitals in the top 25%
(Cheat code in R, need to translate to SAS)*/
/*R code in dplyr:
> km_out3 %>% 
>  	filter_at(vars(one_of(names(hosp_clus))), 
>  	all_vars(.>=quantile(., prob=.75)))
  */





*test: k=6;
/*sort data by id variable*/
proc sort data=km_out6 out=km6_sorted; 
      by org_name;
run;
/*transform data, row = per patient per metric*/
proc transpose data=km6_sorted 
	out=km6_long(rename=(Col1=value)) 
	name=indicator;
	var &hosp_clus.;
	by org_name cluster;
run;
/*sort transformed data by cluster*/
proc sort data=km6_long out=km6_long2; 
	by cluster;
run;

*plot histograms of quality indictors by cluster;
proc sgpanel data=km6_long;
	title "Distributions of Hospital Quality Scores";
	panelby indicator / rows=5 columns=1 uniscale=column;
	density value / group=cluster;
run;
title;
*either clus 2 or 3;


/*Hospital characteristics for each cluster*/
proc sort data=km_out6 out=km_out6_sorted;
      by cluster;
run;
*summary statistics;
proc means data=km_out6_sorted
	alpha=0.05 clm mean std min median max;
	var avg_bed acute_day er_visit or_case;
	by cluster;
run;
/*clusters started to pair up
no difference from k=3
but larger CIs because of smaller group size.
Choose k=3*/





/*****************************
EXTRA: HIERARCHICAL CLUSTERING
******************************/


*clustering process;
proc cluster data=data.hosp_new outtree=tree 
	method=ward pseudo ccc rsq plots=(ccc psf);
	title "Hierarchical Clustering Method using Ward Linkage";
	var &hosp_clus.;
	id org_name;
run;

*prune dendrogram at 4 branches;
proc tree data=tree out=out(rename=(_NAME_=org_name)) n=4;
	title "Hierarchical clustering method";
    copy &hosp_clus.;
run;


*How do hospitals in each cluster perform?
Plot histogram overlays for each perf metric;

*Get data in the right format for sgpanel;
proc sort data=out out=out_sorted; /*sort data by id variable*/
      by org_name;
run;
proc transpose data=out_sorted /*transform data, row = per patient per metric*/
	out=out_long(rename=(Col1=value)) 
	name=indicator;
	var &hosp_clus.;
	by org_name cluster;
run;
proc sort data=out_long out=out_long2; /*sort transformed data by cluster*/
	by cluster;
run;

*plot histograms of quality indictors by cluster;
proc sgpanel data=out_long2;
	panelby indicator / rows=5 columns=1 uniscale=column;
	density value / group=cluster;
run;
/*cluster 2 scores high on infect_inv and smr_inv, medium on the other 3*/


/******************************************
explore hospital characteristics of cluster 2
******************************************/

*append to hosp_new;
data hosp_combined;
	merge data.hosp_new out;
run;

proc sort data=hosp_combined out=hosp_combined_sorted;
      by cluster;
run;

proc means data=hosp_combined_sorted
	N mean std min q1 median q3 max;
	var avg_bed acute_day er_visit or_case;
	by cluster;
run;

proc sgplot data=hosp_combined;
	density avg_bed / group=cluster;
run;

proc sgplot data=hosp_combined;
	density acute_day / group=cluster;
run;

proc sgplot data=hosp_combined;
	density er_visit / group=cluster;
run;

proc sgplot data=hosp_combined;
	density or_case / group=cluster;
run;