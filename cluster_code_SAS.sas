/*	********************************************************************

	This SAS code was written by Jason for SPPH 581C held January 2022

	The objective of this code is to:
		1) introduce some basic SAS commands for data manipulation
		2) import two sample datasets
		3) illustrate clustering methods using two appproaches using SAS

	********************************************************************	*/

	****specify the location of the data;
	libname data 'OneDrive - UBC/CLASSES/SPPH_581C';

	****import data;
	PROC IMPORT OUT= data.test_data_1
            DATAFILE= "OneDrive - UBC/CLASSES/SPPH_581C/test_data_1.csv" 
            DBMS=CSV REPLACE;
			GETNAMES=YES;
			RUN;

	proc contents data=data.test_data_1;		*dataset summary;
	run;

	proc print data=data.test_data_1 (obs=5);	*print a few observations;
		run;

	proc PLOT data=data.test_data_1 ;			*plot the data;
	    Plot cost * age;
		run;	
		quit;


/*	********************************************************************
	Cluster analysis using K-means
	********************************************************************	*/	
	proc fastclus data=data.test_data_1 maxc=2 out=clus2;					****what is k-means?;
	    title "K-Means Two-Cluster Solution";
	    var cost age;
		run;
	proc sort data=clus2;
   		by cluster;
		run;
	proc print data=clus2 (obs=5);
	   	var cluster cost age;
	   	by cluster;
		run;
	proc fastclus data=data.test_data_1 maxc=3 out=clus3;
    	title "K-Means Three-Cluster Solution";
    	var cost age;
		run;
	proc sort data=clus3;
   		by cluster;
		run;
	proc print data=clus3 (obs=15);
	   	var cluster cost age;
	   	by cluster;
		run;


 /*	********************************************************************
	Cluster analysis using hierarchical method
	********************************************************************	*/	
  	proc cluster data=data.test_data_1 outtree=tree method=centroid /*noprint*/;	****what is hierarchical clustering?;
		var cost age;
   		run;   
   	proc tree /*noprint*/ out=out n=3;
     	title "Hierarchical clustering method";
     	copy cost age;
   		run;




	****import data;
	PROC IMPORT OUT= test_data_2
            DATAFILE= "D:\Jason\UBC\teaching\SPPH_581\winter_2022\topics\lecture_1_cluster_analysis\data\test_data_2.csv" 
            DBMS=CSV REPLACE;
			GETNAMES=YES;
			RUN;
	proc print data=test_data_2 (obs=5);	*print a few observations;
		run;
	Proc PLOT data=test_data_2;
	    Plot cost * age;
		run;	
		quit;



  	proc cluster data=test_data_2 outtree=tree method=centroid /*noprint*/;	****what is hierarchical clustering?;
		var cost age;
   		run;   
   	proc tree /*noprint*/ out=out n=3;
     	title "Hierarchical clustering method";
     	copy cost age;
   		run;
