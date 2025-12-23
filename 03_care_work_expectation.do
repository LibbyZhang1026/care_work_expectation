* ===================================
* 03 Caregiving and work expectation
* ===================================
* Author: Jingwen Zhang
* Version 1:
* Date: 19/12/2025
* Aim: 
* (1) merge datasets
* (2) estimate fixed effects models
* (3) estimate asymmetric fixed effects models


clear all


*********************
**# merge across waves
*********************
use "${temp}\00_wave10.dta"
merge 1:1 idauniq using "${temp}\00_wave11.dta", gen(m11) update
keep if inlist(m11,3,4,5)

merge 1:1 idauniq using "$g3", keepusing(raeduc_e) gen(mh) update
drop if mh==2

replace raracem=r11racem if raracem<0 | raracem>=.
 

replace raeduc_e= r10educ_e if r10educ_e<.
replace raeduc_e= r11educ_e if raeduc_e>=. | (raeduc_e<0 & raeduc_e>-14) 

replace h11hownrnt=h10hownrnt if h11hownrnt==.

drop r*jcpen r11educ_e r10educ_e r11racem r9soc2000


reshape long  r@agey inw@ r@mstat r@shlt r@iadltot2_e r@adltot6 r@iadltot1_e h@hownrnt r@child r@livpar r@work r@liv10 r@workat r@workata r@workl65 r@workat70 r@workat70f r@gcare1m r@gcare1w r@gscare1w r@gccare1w r@gkcare1w r@grcare1w r@gcareinhh1w r@gcarehpw r@gcaresck h@hhres r@lbrf_e r@soc2000 r@jhours r@jphysl r@pripen r@pubpen, i(idauniq) j(wave)
 
gen partner = 1 if inlist(rmstat, 1,3)
replace partner = 0 if inlist(rmstat, 4, 5, 7, 8)

replace rjphysl = 5 if rwork==0
replace rjhours = 0 if rwork==0

gen careloc = 0 if rgcare1w==0
replace careloc = 1 if rgcareinhh1w==1
replace careloc = 2 if rgcareinhh1w==0 & rgcare1w==1
label define careloc 0 "no care" 1 "care in hh" 2 "care outside hh only" 
label values careloc careloc


gen careint = 0 if rgcarehpw == 0
replace careint = 1 if rgcarehpw>0 & rgcarehpw<20
replace careint = 2 if rgcarehpw>=20 & rgcarehpw<40
replace careint = 3 if rgcarehpw>=40 & rgcarehpw<.

label define careint 0 "no care" 1 "0-19 h" 2 "20-39 h" 3 "40+ h" 
label values careint careint

replace rworkat70 = 0 if ragey<65 & rworkat==0
 
gen rselfemp = 1 if rlbrf==2
replace rselfemp = 0 if rlbrf==1

 
*******************
**# Fixed effects
*******************

xtset idauniq wave

global sociodemographic "i.partner c.rchild i.hhownrnt"
global health "c.riadltot2_e c.radltot6 i.rshlt"
global eco "i.rpripen i.rpubpen"
global work "i.rwork i.rjphysl c.rjhours"


**# probability of working after age 60 (for people aged <60 in both waves)
* provide care last month (work status)
xtreg rworkat i.rgcare1m c.ragey  if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe

* provide care last week
xtreg rworkat i.rgcare1w c.ragey  if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe

xtreg rworkat i.rgcare1w c.ragey  $sociodemographic $health $eco $work if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe

* recipient: give care to long-term sick/disabled
xtreg rworkat i.rgcaresck c.ragey  if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe

xtreg rworkat i.rgcaresck c.ragey  $sociodemographic $health $eco $work if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe

* recipient: give care to spouse
xtreg rworkat i.rgscare1w c.ragey  if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe

* recipient: give care to children
xtreg rworkat i.rgccare1w c.ragey  if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe

* recipient: give care to grandchildren 
xtreg rworkat i.rgkcare1w c.ragey  if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe

* recipient: give care to other relatives (mainly parents) 
xtreg rworkat i.rgrcare1w c.ragey  if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe
xtreg rworkat i.rgrcare1w c.ragey  $sociodemographic $health $eco $work if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe

* location: provided care to someone in hh last week
xtreg rworkat i.careloc c.ragey  if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe
xtreg rworkat i.careloc c.ragey  $sociodemographic $health $eco $work if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe

* intensity: hours per week provided care
xtreg rworkat c.rgcarehpw c.ragey  if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe
xtreg rworkat c.rgcarehpw c.ragey  $sociodemographic $health $eco $work if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe

xtreg rworkat i.careint c.ragey  if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe
xtreg rworkat i.careint c.ragey  $sociodemographic $health $eco $work if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe



**# probability of working after age 65 (for people aged 60-64 in both waves) */
* provide care last month (work status)
xtreg rworkat i.rgcare1m c.ragey  if rworkata==65 & r10age_cat==3 & r11age_cat==3, fe

* provide care last week
xtreg rworkat i.rgcare1w c.ragey  if rworkata==65 & r10age_cat==3 & r11age_cat==3, fe

* recipient: give care to long-term sick/disabled
xtreg rworkat i.rgcaresck c.ragey  if rworkata==65 & r10age_cat==3 & r11age_cat==3, fe

* recipient: give care to spouse
xtreg rworkat i.rgscare1w c.ragey  if rworkata==65 & r10age_cat==3 & r11age_cat==3, fe
xtreg rworkat i.rgscare1w c.ragey  $sociodemographic $health $eco $work if rworkata==65 & r10age_cat==3 & r11age_cat==3, fe

* recipient: give care to children
xtreg rworkat i.rgccare1w c.ragey  if rworkata==65 & r10age_cat==3 & r11age_cat==3, fe

* recipient: give care to grandchildren 
xtreg rworkat i.rgkcare1w c.ragey  if rworkata==65 & r10age_cat==3 & r11age_cat==3, fe

* recipient: give care to other relatives (mainly parents) 
xtreg rworkat i.rgrcare1w c.ragey  if rworkata==65 & r10age_cat==3 & r11age_cat==3, fe

* location: provided care to someone in hh last week
xtreg rworkat i.careloc c.ragey  if rworkata==65 & r10age_cat==3 & r11age_cat==3, fe

* intensity: hours per week provided care
xtreg rworkat c.rgcarehpw c.ragey  if rworkata==65 & r10age_cat==3 & r11age_cat==3, fe

xtreg rworkat i.careint c.ragey  if rworkata==65 & r10age_cat==3 & r11age_cat==3, fe



**# probability of working after age 70 (for people aged < 70 in both waves) */
* provide care last month (work status)
xtreg rworkat70 i.rgcare1m c.ragey if r10age_cat<5 & r11age_cat<5, fe
xtreg rworkat70 i.rgcare1m c.ragey  $sociodemographic $health $eco $work if r10age_cat<5 & r11age_cat<5, fe

* provide care last week
xtreg rworkat70 i.rgcare1w c.ragey if r10age_cat<5 & r11age_cat<5 , fe
xtreg rworkat70 i.rgcare1w c.ragey if r10age_cat<5 & r11age_cat<5 , re
xtreg rworkat70 i.rgcare1w c.ragey  $sociodemographic $health $eco $work if r10age_cat<5 & r11age_cat<5, fe

* recipient: give care to long-term sick/disabled
xtreg rworkat70 i.rgcaresck c.ragey  if r10age_cat<5 & r11age_cat<5, fe

* recipient: give care to spouse
xtreg rworkat70 i.rgscare1w c.ragey  if r10age_cat<5 & r11age_cat<5, fe

* recipient: give care to children
xtreg rworkat70 i.rgccare1w c.ragey  if r10age_cat<5 & r11age_cat<5, fe

* recipient: give care to grandchildren 
xtreg rworkat70 i.rgkcare1w c.ragey  if r10age_cat<5 & r11age_cat<5, fe

* recipient: give care to other relatives (mainly parents) 
xtreg rworkat70 i.rgrcare1w c.ragey  if r10age_cat<5 & r11age_cat<5, fe

* location: provided care to someone in hh last week
xtreg rworkat70 i.careloc c.ragey  if r10age_cat<5 & r11age_cat<5, fe

* intensity: hours per week provided care
xtreg rworkat70 c.rgcarehpw c.ragey  if r10age_cat<5 & r11age_cat<5, fe

xtreg rworkat70 i.careint c.ragey  if r10age_cat<5 & r11age_cat<5, fe
xtreg rworkat70 i.careint c.ragey  $sociodemographic $health $eco $work if r10age_cat<5 & r11age_cat<5, fe




**# probability of healthy working at 65 (for people aged < 65 and currently working) */
global work "i.rselfemp i.rjphysl c.rjhours"

* provide care last month (work status)
xtreg rworkl65 i.rgcare1m c.ragey $sociodemographic $health if r10age_cat<=3 & r11age_cat<=3, fe

* provide care last week
xtreg rworkl65 i.rgcare1w c.ragey $sociodemographic $health  if r10age_cat<=3 & r11age_cat<=3, fe
xtreg rworkl65 i.rgcare1w c.ragey $sociodemographic $health $eco $work if r10age_cat<=3 & r11age_cat<=3, fe

* recipient: give care to long-term sick/disabled
xtreg rworkl65 i.rgcaresck c.ragey $sociodemographic $health if r10age_cat<=3 & r11age_cat<=3, fe

* recipient: give care to spouse
xtreg rworkl65 i.rgscare1w c.ragey $sociodemographic $health if r10age_cat<=3 & r11age_cat<=3, fe

* recipient: give care to children
xtreg rworkl65 i.rgccare1w c.ragey $sociodemographic $health if  r10age_cat<=3 & r11age_cat<=3, fe

* recipient: give care to grandchildren 
xtreg rworkl65 i.rgkcare1w c.ragey $sociodemographic $health if  r10age_cat<=3 & r11age_cat<=3, fe

* recipient: give care to other relatives (mainly parents) 
xtreg rworkl65 i.rgrcare1w c.ragey $sociodemographic $health if  r10age_cat<=3 & r11age_cat<=3, fe
xtreg rworkl65 i.rgrcare1w c.ragey $sociodemographic $health $eco $work if  r10age_cat<=3 & r11age_cat<=3, fe

* location: provided care to someone in hh last week
xtreg rworkl65 i.careloc c.ragey $sociodemographic $health  if r10age_cat<=3 & r11age_cat<=3, fe

* intensity: hours per week provided care
xtreg rworkl65 c.rgcarehpw c.ragey $sociodemographic $health  if r10age_cat<=3 & r11age_cat<=3, fe

xtreg rworkl65 i.careint c.ragey $sociodemographic $health if r10age_cat<=3 & r11age_cat<=3, fe
xtreg rworkl65 i.careint c.ragey  $sociodemographic $health $eco $work if r10age_cat<=3 & r11age_cat<=3, fe





************************************************
**# Asymmetric Fixed effects for Two-period Data
************************************************
//reshape wide  r@agey inw@ r@mstat r@shlt r@iadltot2_e r@adltot6 r@iadltot1_e h@hownrnt r@child r@livpar r@work r@liv10 r@workat r@workata r@workl65 r@workat70 r@workat70f r@gcare1m r@gcare1w r@gscare1w r@gccare1w r@gkcare1w r@grcare1w r@gcareinhh1w r@gcarehpw r@gcaresck h@hhres r@lbrf_e r@soc2000 r@jhours r@jphysl r@pripen r@pubpen partner@ r@selfemp careint@ careloc@, i(idauniq) j(wave)

gen rworkat_diff = D.rworkat
gen rworkl65_diff = D.rworkl65
gen rworkat70_diff = D.rworkat70

gen rgcare1m_diff = D.rgcare1m
gen rgcare1m_pos = rgcare1m_diff*(rgcare1m_diff>0)
gen rgcare1m_neg = -rgcare1m_diff*(rgcare1m_diff<0)

gen rgcare1w_diff = D.rgcare1w
gen rgcare1w_pos = rgcare1w_diff*(rgcare1w_diff>0)
gen rgcare1w_neg = -rgcare1w_diff*(rgcare1w_diff<0)

gen rgscare1w_diff = D.rgscare1w
gen rgscare1w_pos = rgscare1w_diff*(rgscare1w_diff>0)
gen rgscare1w_neg = -rgscare1w_diff*(rgscare1w_diff<0)

gen rgccare1w_diff = D.rgccare1w
gen rgccare1w_pos = rgccare1w_diff*(rgccare1w_diff>0)
gen rgccare1w_neg = -rgccare1w_diff*(rgccare1w_diff<0)

gen rgkcare1w_diff = D.rgkcare1w
gen rgkcare1w_pos = rgkcare1w_diff*(rgkcare1w_diff>0)
gen rgkcare1w_neg = -rgkcare1w_diff*(rgkcare1w_diff<0)

gen rgrcare1w_diff = D.rgrcare1w
gen rgrcare1w_pos = rgrcare1w_diff*(rgrcare1w_diff>0)
gen rgrcare1w_neg = -rgrcare1w_diff*(rgrcare1w_diff<0)

gen rgcaresck_diff = D.rgcaresck
gen rgcaresck_pos = rgcaresck_diff*(rgcaresck_diff>0)
gen rgcaresck_neg = -rgcaresck_diff*(rgcaresck_diff<0)

gen ragey_diff = D.ragey
 
 
 
 
**# probability of working after age 60 (for people aged <60 in both waves)
* provide care last month (work status)
reg rworkat_diff i.rgcare1m_pos i.rgcare1m_neg ragey_diff if r10age_cat<=2 & r11age_cat<=2

* provide care last week
reg rworkat_diff i.rgcare1w_pos i.rgcare1w_neg ragey_diff if r10age_cat<=2 & r11age_cat<=2

* recipient: give care to long-term sick/disabled
reg rworkat_diff i.rgcaresck_pos i.rgcaresck_neg ragey_diff if r10age_cat<=2 & r11age_cat<=2

* recipient: give care to spouse
reg rworkat_diff i.rgscare1w_pos i.rgscare1w_neg ragey_diff if r10age_cat<=2 & r11age_cat<=2

* recipient: give care to children
reg rworkat_diff i.rgccare1w_pos i.rgccare1w_neg ragey_diff if r10age_cat<=2 & r11age_cat<=2

* recipient: give care to grandchildren 
reg rworkat_diff i.rgkcare1w_pos i.rgkcare1w_neg ragey_diff if r10age_cat<=2 & r11age_cat<=2

* recipient: give care to other relatives (mainly parents) 
reg rworkat_diff i.rgrcare1w_pos i.rgrcare1w_neg ragey_diff if r10age_cat<=2 & r11age_cat<=2



**# probability of working after age 65 (for people aged 60-64 in both waves)
* provide care last month (work status)
reg rworkat_diff i.rgcare1m_pos i.rgcare1m_neg ragey_diff if r10age_cat==3 & r11age_cat==3

* provide care last week
reg rworkat_diff i.rgcare1w_pos i.rgcare1w_neg ragey_diff if r10age_cat==3 & r11age_cat==3

* recipient: give care to long-term sick/disabled
reg rworkat_diff i.rgcaresck_pos i.rgcaresck_neg ragey_diff if r10age_cat==3 & r11age_cat==3

* recipient: give care to spouse
reg rworkat_diff i.rgscare1w_pos i.rgscare1w_neg ragey_diff if r10age_cat==3 & r11age_cat==3

* recipient: give care to children
reg rworkat_diff i.rgccare1w_pos i.rgccare1w_neg ragey_diff if r10age_cat==3 & r11age_cat==3

* recipient: give care to grandchildren 
reg rworkat_diff i.rgkcare1w_pos i.rgkcare1w_neg ragey_diff if r10age_cat==3 & r11age_cat==3

* recipient: give care to other relatives (mainly parents) 
reg rworkat_diff i.rgrcare1w_pos i.rgrcare1w_neg ragey_diff if r10age_cat==3 & r11age_cat==3



**# probability of working after age 70 (for people aged < 70 in both waves) 
* provide care last month (work status)
reg rworkat70_diff i.rgcare1m_pos i.rgcare1m_neg ragey_diff if r10age_cat<5 & r11age_cat<5

* provide care last week
reg rworkat70_diff i.rgcare1w_pos i.rgcare1w_neg ragey_diff if r10age_cat<5 & r11age_cat<5

* recipient: give care to long-term sick/disabled
reg rworkat70_diff i.rgcaresck_pos i.rgcaresck_neg ragey_diff if r10age_cat<5 & r11age_cat<5

* recipient: give care to spouse
reg rworkat70_diff i.rgscare1w_pos i.rgscare1w_neg ragey_diff if r10age_cat<5 & r11age_cat<5

* recipient: give care to children
reg rworkat70_diff i.rgccare1w_pos i.rgccare1w_neg ragey_diff if r10age_cat<5 & r11age_cat<5

* recipient: give care to grandchildren 
reg rworkat70_diff i.rgkcare1w_pos i.rgkcare1w_neg ragey_diff if r10age_cat<5 & r11age_cat<5

* recipient: give care to other relatives (mainly parents) 
reg rworkat70_diff i.rgrcare1w_pos i.rgrcare1w_neg ragey_diff if r10age_cat<5 & r11age_cat<5



**# probability of healthy working at 65 (for people aged < 65 and currently working) */
* provide care last month (work status)
reg rworkl65_diff i.rgcare1m_pos i.rgcare1m_neg ragey_diff if r10age_cat<=3 & r11age_cat<=3

* provide care last week
reg rworkl65_diff i.rgcare1w_pos i.rgcare1w_neg ragey_diff if r10age_cat<=3 & r11age_cat<=3

* recipient: give care to long-term sick/disabled
reg rworkl65_diff i.rgcaresck_pos i.rgcaresck_neg ragey_diff if r10age_cat<=3 & r11age_cat<=3

* recipient: give care to spouse
reg rworkl65_diff i.rgscare1w_pos i.rgscare1w_neg ragey_diff if r10age_cat<=3 & r11age_cat<=3

* recipient: give care to children
reg rworkl65_diff i.rgccare1w_pos i.rgccare1w_neg ragey_diff if r10age_cat<=3 & r11age_cat<=3

* recipient: give care to grandchildren 
reg rworkl65_diff i.rgkcare1w_pos i.rgkcare1w_neg ragey_diff if r10age_cat<=3 & r11age_cat<=3

* recipient: give care to other relatives (mainly parents) 
reg rworkl65_diff i.rgrcare1w_pos i.rgrcare1w_neg ragey_diff if r10age_cat<=3 & r11age_cat<=3






