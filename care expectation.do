**********************************************
*** Caregiving and Future work expectation ***
**********************************************
*** Version 1: 17/11/2025
*** Author: Jingwen Zhang
*** Aim
* (0) Data cleaning 
* (1) Transition into and out of informal care and future work expectation 
* (2) Relationship to care recipients and future work expectation
* (3) Location of care and future work expectation
* (4) Duration of care and future work expectation  

 

set maxvar 20000


* prepare data for merging 
use "C:\Users\j53735jz\OneDrive - The University of Manchester\Research\DATA\ELSA0_11\UKDA-5050-stata\stata\stata13_se\h_elsa_g3.dta", clear

keep idauniq r*agey inw* ragender raracem raeduc_e r*mstat r*shlt r*adltot6 r*iadltot1_e h*hownrnt r*child r*livpar r*work r*retemp r*pretwrk r*wretage r*liv10 r*workat r*workata r*workl65 r*pnhm5y r*gcare1m r*gcare1w r*gscare1w r*gccare1w r*gkcare1w r*grcare1w r*gcareinhh1w r*gcarehpw r*gcaresck r*gcaresat r*cesd h*hhres r*lbrf_e r*soc2000 r*slfemp r*jhours r*jphysl r*jcpen 

reshape long r@agey inw@ r@mstat r@shlt r@adltot6 r@iadltot1_e h@hownrnt r@child r@livpar r@work r@retemp r@pretwrk r@wretage r@liv10 r@workat r@workata r@workl65 r@pnhm5y r@gcare1m r@gcare1w r@gscare1w r@gccare1w r@gkcare1w r@grcare1w r@gcareinhh1w r@gcarehpw r@gcaresck r@gcaresat r@cesd h@hhres r@lbrf_e r@soc2000 r@slfemp r@jhours r@jphysl r@jcpen inw@sc, i(idauniq) j(wave)

drop inw?n inw3lh r?fagey

* Variables cleaning
* gender; work stataus; wealth; marital status; education; self-rated health; functional ability; pension; work demand; self-employed; part-time












tab rgcaresck if rworkata==65, sum(rworkat)
tab rgcaresck if rworkata==60, sum(rworkat)




xtset idauniq wave

gen rworkat100= 1 if rworkat==100
replace rworkat100= 0 if rworkat<100 & rworkat>=0
gen rworkat0= 1 if rworkat==0
replace rworkat0= 0 if rworkat<=100 & rworkat>0


gen rworkat50=1 if rworkat>=50 & rworkat<=100
replace rworkat50= 0 if rworkat<50

recode ragey (16/54 = 1) (55/59 = 2) (60/64 =3) (65/90 = 4) , gen(rage_cat)

replace rgcaresck=. if rgcaresck<0

xtreg rworkat i.rgcaresck i.rage_cat rshlt radltot6 rchild rcesd  if rworkata==65, fe

xtreg rworkat i.rgcaresck i.rage_cat rshlt radltot6 rchild rcesd  if rworkata==60, fe

xtreg rworkat i.rgccare1w i.rage_cat rshlt radltot6 rlivpar rchild i.rmstat if rworkata==65, fe

xtreg rworkat i.rgccare1w i.rage_cat rshlt radltot6 rlivpar rchild i.rmstat if rworkata==60, fe

xtreg rworkat i.rgcare1m i.rage_cat rshlt radltot6 rlivpar rchild i.rmstat if rworkata==65, fe

xtreg rworkat i.rgcare1m i.rage_cat rshlt radltot6 rlivpar rchild i.rmstat if rworkata==60, fe

xtreg rworkat i.rgscare1w i.rage_cat rshlt radltot6 rchild  rcesd if rworkata==65, fe

xtreg rworkat i.rgscare1w i.rage_cat rshlt radltot6 rchild  rcesd  if rworkata==60, fe

xtreg rworkat0 i.rgscare1w i.rage_cat rshlt radltot6 rlivpar rchild  if rworkata==65, fe

xtreg rworkat0 i.rgscare1w i.rage_cat rshlt radltot6 rlivpar rchild   if rworkata==60, fe

xtreg rworkat50 i.rgcaresck ragey rshlt radltot6 if rworkata==65, fe

xtreg rworkat50 i.rgcaresck ragey rshlt if rworkata==60, fe

xtreg rworkat i.rgrcare1w i.rage_cat rshlt radltot6 rchild i.hhownrnt rcesd  if rworkata==65, fe

xtreg rworkat i.rgrcare1w i.rage_cat rshlt radltot6 rchild i.hhownrnt rcesd  if rworkata==60, fe

xtreg rworkat i.rgcareinhh1w i.rage_cat rshlt radltot6 rchild i.hhownrnt rcesd  if rworkata==65, fe

xtreg rworkat i.rgcareinhh1w i.rage_cat rshlt radltot6 rchild i.hhownrnt rcesd  if rworkata==60, fe

xtreg rworkat rgcarehpw i.rage_cat rshlt radltot6 rchild  rcesd  if rworkata==65, fe

xtreg rworkat rgcarehpw i.rage_cat rshlt radltot6 rchild  rcesd  if rworkata==60, fe


replace rgscare1w=. if rgscare1w<0
replace rgcareinhh1w=. if rgcareinhh1w<0
xtreg rworkl65 i.rgcaresck ragey rshlt radltot6 rchild  rcesd if ragender==2, fe

xtreg rworkl65 i.rgscare1w ragey rshlt radltot6 rchild  rcesd , fe

xtreg rworkl65 i.rgcare1w ragey rshlt radltot6 rchild  rcesd , fe

xtreg rworkl65 i.rgcare1m ragey rshlt radltot6 rchild  rcesd , fe

xtreg rworkl65 i.rgcareinhh1w ragey rshlt radltot6 rchild  rcesd , fe

xtreg rworkl65 rgcarehpw ragey rshlt radltot6 rchild  rcesd , fe
