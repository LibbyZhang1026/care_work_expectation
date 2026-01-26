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


reshape long  r@agey inw@ r@mstat r@shlt r@iadltot2_e r@adltot6 r@iadltot1_e h@hownrnt r@child r@livpar r@work r@liv10 r@workat r@workata r@workl65 r@workat70 r@workat70f r@gcare1m r@gcare1w r@gscare1w r@gccare1w r@gkcare1w r@grcare1w r@gcareinhh1w r@gcarehpw r@gcaresck h@hhres r@lbrf_e r@soc2000 r@jhours r@jphysl r@pripen r@pubpen r@ngc, i(idauniq) j(wave)
 
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

replace rworkat70 = 0 if ragey<65 & rworkat==0  // including those who won't work after an ealier age
 
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
est store m11

* provide care last week
xtreg rworkat i.rgcare1w c.ragey  if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe
est store m121

xtreg rworkat i.rgcare1w c.ragey  $sociodemographic $health $eco $work if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe
est store m122

* recipient: give care to long-term sick/disabled
xtreg rworkat i.rgcaresck c.ragey  if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe
est store m13

xtreg rworkat i.rgcaresck c.ragey  $sociodemographic $health $eco $work if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe
est store m132

* recipient: give care to spouse
xtreg rworkat i.rgscare1w c.ragey  if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe
est store m14

* recipient: give care to children
xtreg rworkat i.rgccare1w c.ragey  if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe
est store m15

* recipient: give care to grandchildren 
xtreg rworkat i.rgkcare1w c.ragey  if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe
est store m16

* recipient: give care to other relatives (mainly parents) 
xtreg rworkat i.rgrcare1w c.ragey  if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe
est store m171

xtreg rworkat i.rgrcare1w c.ragey  $sociodemographic $health $eco $work if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe
est store m172

* location: provided care to someone in hh last week
xtreg rworkat i.careloc c.ragey  if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe
est store m181
xtreg rworkat i.careloc c.ragey  $sociodemographic $health $eco $work if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe
est store m182

* intensity: hours per week provided care
xtreg rworkat c.rgcarehpw c.ragey  if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe
xtreg rworkat c.rgcarehpw c.ragey  $sociodemographic $health $eco $work if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe

xtreg rworkat i.careint c.ragey  if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe
est store m191
xtreg rworkat i.careint c.ragey  $sociodemographic $health $eco $work if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe
est store m192

outreg2 [m1 m121 m122 m181 m182 m191 m192] using "${tables}/model_result", word alpha(0.001,0.01,0.05, 0.1) symbol(***, **, *, +) dec(3) replace

outreg2 [m13 m132 m14 m15 m16 m171 m172] using "${tables}/model_result", word alpha(0.001,0.01,0.05, 0.1) symbol(***, **, *, +) dec(3) replace


**# probability of working after age 65 (for people aged 60-64 in both waves) */
* provide care last month (work status)
xtreg rworkat i.rgcare1m c.ragey  if rworkata==65 & r10age_cat==3 & r11age_cat==3, fe
est store m21

* provide care last week
xtreg rworkat i.rgcare1w c.ragey  if rworkata==65 & r10age_cat==3 & r11age_cat==3, fe
est store m22

* recipient: give care to long-term sick/disabled
xtreg rworkat i.rgcaresck c.ragey  if rworkata==65 & r10age_cat==3 & r11age_cat==3, fe
est store m23

* recipient: give care to spouse
xtreg rworkat i.rgscare1w c.ragey  if rworkata==65 & r10age_cat==3 & r11age_cat==3, fe
est store m241
xtreg rworkat i.rgscare1w c.ragey  $sociodemographic $health $eco $work if rworkata==65 & r10age_cat==3 & r11age_cat==3, fe
est store m242

* recipient: give care to children
xtreg rworkat i.rgccare1w c.ragey  if rworkata==65 & r10age_cat==3 & r11age_cat==3, fe
est store m25

* recipient: give care to grandchildren 
xtreg rworkat i.rgkcare1w c.ragey  if rworkata==65 & r10age_cat==3 & r11age_cat==3, fe
est store m26

* recipient: give care to other relatives (mainly parents) 
xtreg rworkat i.rgrcare1w c.ragey  if rworkata==65 & r10age_cat==3 & r11age_cat==3, fe
est store m27

* location: provided care to someone in hh last week
xtreg rworkat i.careloc c.ragey  if rworkata==65 & r10age_cat==3 & r11age_cat==3, fe
est store m28

* intensity: hours per week provided care
xtreg rworkat c.rgcarehpw c.ragey  if rworkata==65 & r10age_cat==3 & r11age_cat==3, fe
est store m291

xtreg rworkat i.careint c.ragey  if rworkata==65 & r10age_cat==3 & r11age_cat==3, fe
est store m292
outreg2 [m21 m22 m28 m291 m292 m23 m241 m242 m25 m26 m27] using "${tables}/model_result", word alpha(0.001,0.01,0.05, 0.1) symbol(***, **, *, +) dec(3) replace



**# probability of working after age 70 (for people aged < 70 in both waves) */
* provide care last month (work status)
xtreg rworkat70 i.rgcare1m c.ragey if r10age_cat<5 & r11age_cat<5, fe
est store m311
xtreg rworkat70 i.rgcare1m c.ragey  $sociodemographic $health $eco $work if r10age_cat<5 & r11age_cat<5, fe
est store m312

* provide care last week
xtreg rworkat70 i.rgcare1w c.ragey if r10age_cat<5 & r11age_cat<5 , fe
est store m321
xtreg rworkat70 i.rgcare1w c.ragey  $sociodemographic $health $eco $work if r10age_cat<5 & r11age_cat<5, fe
est store m322

* recipient: give care to long-term sick/disabled
xtreg rworkat70 i.rgcaresck c.ragey  if r10age_cat<5 & r11age_cat<5, fe
est store m33

* recipient: give care to spouse
xtreg rworkat70 i.rgscare1w c.ragey  if r10age_cat<5 & r11age_cat<5, fe
est store m34

* recipient: give care to children
xtreg rworkat70 i.rgccare1w c.ragey  if r10age_cat<5 & r11age_cat<5, fe
est store m35

* recipient: give care to grandchildren 
xtreg rworkat70 i.rgkcare1w c.ragey  if r10age_cat<5 & r11age_cat<5, fe
est store m36

* recipient: give care to other relatives (mainly parents) 
xtreg rworkat70 i.rgrcare1w c.ragey  if r10age_cat<5 & r11age_cat<5, fe
est store m37

* location: provided care to someone in hh last week
xtreg rworkat70 i.careloc c.ragey  if r10age_cat<5 & r11age_cat<5, fe
est store m38

* intensity: hours per week provided care
xtreg rworkat70 c.rgcarehpw c.ragey  if r10age_cat<5 & r11age_cat<5, fe

xtreg rworkat70 i.careint c.ragey  if r10age_cat<5 & r11age_cat<5, fe
est store m391
xtreg rworkat70 i.careint c.ragey  $sociodemographic $health $eco $work if r10age_cat<5 & r11age_cat<5, fe
est store m392

outreg2 [m311 m312 m321 m322 m38 m391 m392 m33 m34 m35 m36 m37] using "${tables}/model_result", word alpha(0.001,0.01,0.05, 0.1) symbol(***, **, *, +) dec(3) replace



**# probability of healthy working at 65 (for people aged < 65 and currently working) */
global work "i.rselfemp i.rjphysl c.rjhours"

* provide care last month (work status)
xtreg rworkl65 i.rgcare1m c.ragey $health if r10age_cat<=3 & r11age_cat<=3, fe
est store m41

* provide care last week
xtreg rworkl65 i.rgcare1w c.ragey $health  if r10age_cat<=3 & r11age_cat<=3, fe
est store m421
xtreg rworkl65 i.rgcare1w c.ragey $sociodemographic $health $eco $work if r10age_cat<=3 & r11age_cat<=3, fe
est store m422

* recipient: give care to long-term sick/disabled
xtreg rworkl65 i.rgcaresck c.ragey $health if r10age_cat<=3 & r11age_cat<=3, fe
est store m43

* recipient: give care to spouse
xtreg rworkl65 i.rgscare1w c.ragey $health if r10age_cat<=3 & r11age_cat<=3, fe
est store m44

* recipient: give care to children
xtreg rworkl65 i.rgccare1w c.ragey $health if  r10age_cat<=3 & r11age_cat<=3, fe
est store m45

* recipient: give care to grandchildren 
xtreg rworkl65 i.rgkcare1w c.ragey $health if  r10age_cat<=3 & r11age_cat<=3, fe
est store m46

* recipient: give care to other relatives (mainly parents) 
xtreg rworkl65 i.rgrcare1w c.ragey $health if  r10age_cat<=3 & r11age_cat<=3, fe
est store m471
xtreg rworkl65 i.rgrcare1w c.ragey $sociodemographic $health $eco $work if  r10age_cat<=3 & r11age_cat<=3, fe
est store m472

* location: provided care to someone in hh last week
xtreg rworkl65 i.careloc c.ragey $health  if r10age_cat<=3 & r11age_cat<=3, fe
est store m48

* intensity: hours per week provided care
xtreg rworkl65 c.rgcarehpw c.ragey $health  if r10age_cat<=3 & r11age_cat<=3, fe

xtreg rworkl65 i.careint c.ragey $health if r10age_cat<=3 & r11age_cat<=3, fe
est store m491
xtreg rworkl65 i.careint c.ragey  $sociodemographic $health $eco $work if r10age_cat<=3 & r11age_cat<=3, fe
est store m492

outreg2 [m41 m421 m422 m48 m491 m492 m43 m44 m45 m46 m471 m472] using "${tables}/model_result", word alpha(0.001,0.01,0.05, 0.1) symbol(***, **, *, +) dec(3) replace


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
est store m51

* provide care last week
reg rworkat_diff i.rgcare1w_pos i.rgcare1w_neg ragey_diff if r10age_cat<=2 & r11age_cat<=2
est store m52

* recipient: give care to long-term sick/disabled
reg rworkat_diff i.rgcaresck_pos i.rgcaresck_neg ragey_diff if r10age_cat<=2 & r11age_cat<=2
est store m53


* recipient: give care to spouse
reg rworkat_diff i.rgscare1w_pos i.rgscare1w_neg ragey_diff if r10age_cat<=2 & r11age_cat<=2
est store m54

* recipient: give care to children
reg rworkat_diff i.rgccare1w_pos i.rgccare1w_neg ragey_diff if r10age_cat<=2 & r11age_cat<=2
est store m55

* recipient: give care to grandchildren 
reg rworkat_diff i.rgkcare1w_pos i.rgkcare1w_neg ragey_diff if r10age_cat<=2 & r11age_cat<=2
est store m56

* recipient: give care to other relatives (mainly parents) 
reg rworkat_diff i.rgrcare1w_pos i.rgrcare1w_neg ragey_diff if r10age_cat<=2 & r11age_cat<=2
est store m57

outreg2 [m51 m52 m53 m54 m55 m56 m57] using "${tables}/model_result", word alpha(0.001,0.01,0.05, 0.1) symbol(***, **, *, +) dec(3) replace

**# probability of working after age 65 (for people aged 60-64 in both waves)
* provide care last month (work status)
reg rworkat_diff i.rgcare1m_pos i.rgcare1m_neg ragey_diff if r10age_cat==3 & r11age_cat==3
est store m61

* provide care last week
reg rworkat_diff i.rgcare1w_pos i.rgcare1w_neg ragey_diff if r10age_cat==3 & r11age_cat==3
est store m62

* recipient: give care to long-term sick/disabled
reg rworkat_diff i.rgcaresck_pos i.rgcaresck_neg ragey_diff if r10age_cat==3 & r11age_cat==3
est store m63

* recipient: give care to spouse
reg rworkat_diff i.rgscare1w_pos i.rgscare1w_neg ragey_diff if r10age_cat==3 & r11age_cat==3
est store m64

* recipient: give care to children
reg rworkat_diff i.rgccare1w_pos i.rgccare1w_neg ragey_diff if r10age_cat==3 & r11age_cat==3
est store m65

* recipient: give care to grandchildren 
reg rworkat_diff i.rgkcare1w_pos i.rgkcare1w_neg ragey_diff if r10age_cat==3 & r11age_cat==3
est store m66

* recipient: give care to other relatives (mainly parents) 
reg rworkat_diff i.rgrcare1w_pos i.rgrcare1w_neg ragey_diff if r10age_cat==3 & r11age_cat==3
est store m67

outreg2 [m61 m62 m63 m64 m65 m66 m67] using "${tables}/model_result", word alpha(0.001,0.01,0.05, 0.1) symbol(***, **, *, +) dec(3) replace


**# probability of working after age 70 (for people aged < 70 in both waves) 
* provide care last month (work status)
reg rworkat70_diff i.rgcare1m_pos i.rgcare1m_neg ragey_diff if r10age_cat<5 & r11age_cat<5
est store m71

* provide care last week
reg rworkat70_diff i.rgcare1w_pos i.rgcare1w_neg ragey_diff if r10age_cat<5 & r11age_cat<5
est store m72

* recipient: give care to long-term sick/disabled
reg rworkat70_diff i.rgcaresck_pos i.rgcaresck_neg ragey_diff if r10age_cat<5 & r11age_cat<5
est store m73

* recipient: give care to spouse
reg rworkat70_diff i.rgscare1w_pos i.rgscare1w_neg ragey_diff if r10age_cat<5 & r11age_cat<5
est store m74

* recipient: give care to children
reg rworkat70_diff i.rgccare1w_pos i.rgccare1w_neg ragey_diff if r10age_cat<5 & r11age_cat<5
est store m75

* recipient: give care to grandchildren 
reg rworkat70_diff i.rgkcare1w_pos i.rgkcare1w_neg ragey_diff if r10age_cat<5 & r11age_cat<5
est store m76

* recipient: give care to other relatives (mainly parents) 
reg rworkat70_diff i.rgrcare1w_pos i.rgrcare1w_neg ragey_diff if r10age_cat<5 & r11age_cat<5
est store m77
outreg2 [m71 m72 m73 m74 m75 m76 m77] using "${tables}/model_result", word alpha(0.001,0.01,0.05, 0.1) symbol(***, **, *, +) dec(3) replace

**# probability of healthy working at 65 (for people aged < 65 and currently working) */
* provide care last month (work status)
reg rworkl65_diff i.rgcare1m_pos i.rgcare1m_neg ragey_diff if r10age_cat<=3 & r11age_cat<=3
est store m81

* provide care last week
reg rworkl65_diff i.rgcare1w_pos i.rgcare1w_neg ragey_diff if r10age_cat<=3 & r11age_cat<=3
est store m82

* recipient: give care to long-term sick/disabled
reg rworkl65_diff i.rgcaresck_pos i.rgcaresck_neg ragey_diff if r10age_cat<=3 & r11age_cat<=3
est store m83

* recipient: give care to spouse
reg rworkl65_diff i.rgscare1w_pos i.rgscare1w_neg ragey_diff if r10age_cat<=3 & r11age_cat<=3
est store m84

* recipient: give care to children
reg rworkl65_diff i.rgccare1w_pos i.rgccare1w_neg ragey_diff if r10age_cat<=3 & r11age_cat<=3
est store m85

* recipient: give care to grandchildren 
reg rworkl65_diff i.rgkcare1w_pos i.rgkcare1w_neg ragey_diff if r10age_cat<=3 & r11age_cat<=3
est store m86

* recipient: give care to other relatives (mainly parents) 
reg rworkl65_diff i.rgrcare1w_pos i.rgrcare1w_neg ragey_diff if r10age_cat<=3 & r11age_cat<=3
est store m87

outreg2 [m81 m82 m83 m84 m85 m86 m87] using "${tables}/model_result", word alpha(0.001,0.01,0.05, 0.1) symbol(***, **, *, +) dec(3) replace




