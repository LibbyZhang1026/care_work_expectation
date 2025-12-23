* ===============
* Master do-file
* 00_globalsetup.do
* ===============

********************************************************************************
********************************************************************************

* ==============
* General setup
* ==============

version 19.5
set more off 
clear all // clear memory

capture log close // close open log files if need be


ssc install outreg2
ssc install coefplot, replace
ssc install psmatch2


********************************************************************************
********************************************************************************

* =======================================================
* Specify random-number seed to ensure identical results
* =======================================================

set seed 9999

********************************************************************************
********************************************************************************


* ========================
* define macros for paths
* ========================


// Working directory for the project
global workingDir 	"C:\Users\j53735jz\OneDrive - The University of Manchester\Research\Care_work_expectation"

// Folders for the datasets
global data			"${workingDir}\01_data" 				
	
// Original data --> never change these files 
global elsa	"C:\Users\j53735jz\OneDrive - The University of Manchester\Research\DATA\ELSA0_11\UKDA-5050-stata\stata\stata13_se"
global g3 "${elsa}\h_elsa_g3"
global elsa11 "${elsa}\wave_11_elsa_data_eul_v1.dta"
global elsa10 "${elsa}\wave_10_elsa_data_eul_v4.dta"
global elsa9 "${elsa}\wave_9_elsa_data_eul_v2.dta"
global elsa8 "${elsa}\wave_8_elsa_data_eul_v2.dta"
global elsa7 "${elsa}\wave_7_elsa_data.dta"
global elsa6 "${elsa}\wave_6_elsa_data_v2.dta"
global elsa5 "${elsa}\wave_5_elsa_data_v4.dta"
global elsa4 "${elsa}\wave_4_elsa_data_v3.dta"
global finance "${elsa}\wave_10_financial_derived_variables.dta"
global finance "${elsa}\wave_10_financial_derived_variables.dta"

	
	// temporary data files (usually to be deleted at the end of each do-file) 
	global temp 		"${data}\02_temp" 					
	
	// generated datasets ready to use in further do-files
	global posted		"${data}\03_posted"					
								

// do-files
global dofiles 		"${workingDir}\03_do-files"	

// r-scripts
global rscripts		"${workingDir}\04_r-scripts"	

// log-files
global log 			"${workingDir}\05_log-files"			

// tables
global tables 		"${workingDir}\06_tables" 	

// graphs
global graphs 		"${workingDir}\07_graphs" 				

********************************************************************************
********************************************************************************

* ============================================================
/*
Here you can also define other global macros you consider
useful for your data preperation 
*/ 
* ============================================================

********************************************************************************
********************************************************************************
