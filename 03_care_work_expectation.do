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

* Date: 24/02/2025
* Aim:
* (1) change caregiving variable: parents as a category
* (2) adding new variables: 
****2.1) covariates: parents; siblings; health of people in the households; 
****2.2) mediators: full retirement age; total years worked; saving; expected LE
**** 

* (3) work after 60/65/70 -> DID & matching rather than fixed effects
* (4) health working expectancy -> matching. 
* (5) robustness check: with or without health



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

//merge 1:1 idauniq using "$g3", keepusing(r*gcare1w) gen(mh2)
//drop if mh2==2
//egen care_his = anymatch(r1gcare1w-r9gcare1w), values(1)
//egen care_his0 = anymatch(r1gcare1w-r9gcare1w), values(0)
//replace care_his= 2 if care_his==0 & care_his0==0
//label define care_his 0 "No caring before" 1 "previous carer" 2 "missing"
//label values care_his care_his

//reg r11workl65 i.care_his##i.r10gcare1w##i.r11gcare1w
//margins  care_his#r10gcare1w#r11gcare1w
//mplotoffset, xtitle("care history") ytitle("Pr(health limiting work)")  ///
//title("probability of health limiting work") plotopts(connect(none)) off(0.05)

//reg r11workat i.care_his##i.r10gcare1w##i.r11gcare1w if r11workata==60 & r10age_cat<=2 & r11age_cat<=2
//margins  care_his#r10gcare1w#r11gcare1w
//mplotoffset, xtitle("care history") ytitle("Pr(work expectation at 60)")  ///
//title("probability of working at 60") plotopts(connect(none)) off(0.05)

//reg r11workat70 i.care_his##i.r10gcare1w##i.r11gcare1w r10agey
//margins  care_his#r10gcare1w#r11gcare1w
//mplotoffset, xtitle("care history") ytitle("Pr(work expectation at 70)")  ///
//title("probability of working at 70") plotopts(connect(none)) off(0.05)



reshape long  r@agey inw@ r@mstat r@shlt r@iadltot2_e r@adltot6 r@iadltot1_e h@hownrnt r@child r@livpar r@disib r@work r@liv10 r@workat r@workata r@workl65 r@workat70 r@workat70f r@gcare1m r@gcare1w r@gscare1w r@gccare1w r@gkcare1w r@gpcare1w r@grcare1w r@gcareinhh1w r@gcarehpw r@gcaresck h@hhres r@lbrf_e r@soc2000 r@jhours r@jphysl r@pripen r@pubpen r@ngc r@le85 r@gor r@cesd r@going r@finan r@hwealth , i(idauniq) j(wave)
 
 
 
gen partner = 1 if inlist(rmstat, 1,3)
replace partner = 0 if inlist(rmstat, 4, 5, 7, 8)

replace rjphysl = 5 if rwork==0
replace rjhours = 0 if rwork==0

replace rdisib=. if rdisib<0

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

gen careint3cat = 0 if rgcarehpw == 0
replace careint3cat = 1 if rgcarehpw>0 & rgcarehpw<20
replace careint3cat = 2 if rgcarehpw>=20 & rgcarehpw<.

label define careint3cat 0 "no care" 1 "0-19 h" 2 "20+ h" 
label values careint3cat careint3cat

replace rworkat70 = 0 if ragey<65 & rworkat==0  // including those who won't work after an ealier age
 
gen rselfemp = 1 if rlbrf==2
replace rselfemp = 0 if rlbrf==1

replace rgcare1w=. if rgcare1w<0


* living grandchildren
replace rngc=0 if rngc==-1
replace rngc=. if rngc==-8

* education
gen edu =raeduc_e if raeduc_e >0
replace edu = 6 if raeduc_e==-15

* gor
gen rgor_n = substr(rgor, 8, 2)
destring rgor_n, replace
replace rgor_n = 11 if rgor == "S92000003"
replace rgor_n = 12 if rgor == "W92000004"

* home ownership 
replace hhownrnt = 2 if hhownrnt==3

** missingness  and analytical sample
fre rworkat if ragey<60
// minimal missing 121 in total, 94 is due to proxy 
fre rworkat70 if ragey<60 //ragey<70

misstable summarize partner partner hhownrnt rhwealth riadltot2_e radltot6 rshlt rpripen rpubpen  rwork rjphysl rjhours rchild rlivpar rdisib rngc edu ragey ragender raracem rworkat rworkat70 rcesd rfinan if rworkata==60 & r10age_cat<=2 & r11age_cat<=2


global demographic " r10agey i.ragender i.raracem i.partner10 i.r10gor_n"
global familynetwork " c.r10child c.r10livpar c.r10disib c.r10ngc"
global work "i.r10work i.r10jphysl c.r10jhours"
global eco "i.edu i.r10pripen i.r10pubpen i.h10hownrnt c.r10hwealth"
global health "c.r10iadltot2_e c.r10adltot6 i.r10shlt"
global mediator "c.r10cesd c.r10finan"
 
*******************
**# Fixed effects
*******************

xtset idauniq wave

global sociodemographic "i.partner c.partner i.hhownrnt"
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


didregress (rworkat ) (rgcare1w ) if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, group(idauniq) time(wave)



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
xtreg rworkat i.rgpcare1w c.ragey  if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe
est store m171

xtreg rworkat i.rgpcare1w c.ragey  $sociodemographic $health $eco $work if rworkata==60 & r10age_cat<=2 & r11age_cat<=2, fe
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
xtreg rworkat i.rgpcare1w c.ragey  if rworkata==65 & r10age_cat==3 & r11age_cat==3, fe
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
xtreg rworkat70 i.rgpcare1w c.ragey  if r10age_cat<5 & r11age_cat<5, fe
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
xtreg rworkl65 i.rgpcare1w c.ragey $health if  r10age_cat<=3 & r11age_cat<=3, fe
est store m471
xtreg rworkl65 i.rgpcare1w c.ragey $sociodemographic $health $eco $work if  r10age_cat<=3 & r11age_cat<=3, fe
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



xtset idauniq wave

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

gen rgpcare1w_diff = D.rgpcare1w
gen rgpcare1w_pos = rgpcare1w_diff*(rgpcare1w_diff>0)
gen rgpcare1w_neg = -rgpcare1w_diff*(rgpcare1w_diff<0)

gen rgrcare1w_diff = D.rgrcare1w
gen rgrcare1w_pos = rgrcare1w_diff*(rgrcare1w_diff>0)
gen rgrcare1w_neg = -rgrcare1w_diff*(rgrcare1w_diff<0)

gen rgcaresck_diff = D.rgcaresck
gen rgcaresck_pos = rgcaresck_diff*(rgcaresck_diff>0)
gen rgcaresck_neg = -rgcaresck_diff*(rgcaresck_diff<0)


gen ragey_diff = D.ragey
gen partner_diff = D.partner 
gen rchild_diff = D.rchild
gen rlivpar_diff = D.rlivpar
gen rdisib_diff = D.rdisib
gen rngc_diff = D.rngc
gen rwork_diff = D.rwork
gen rpripen_diff = D.rpripen
gen rpubpen_diff = D.rpubpen
gen hhownrnt_diff = D.hhownrnt
gen rhwealth_diff = D.rhwealth
gen riadltot2_e_diff = D.riadltot2_e
gen radltot6_diff = D.radltot6
gen rshlt_diff = D.rshlt
gen rcesd_diff = D.rcesd
gen rfinan_diff = D.rfinan
gen rgoing_diff = D.rgoing

gen lag_careint3cat= L.careint3cat
gen no_low = lag_careint3cat ==0 & careint3cat==1 if (lag_careint3cat<. & careint3cat<.)
gen no_high = lag_careint3cat ==0 & careint3cat==2 if (lag_careint3cat<. & careint3cat<.)
gen low_no = lag_careint3cat ==1 & careint3cat==0 if (lag_careint3cat<. & careint3cat<.)
gen low_high = lag_careint3cat ==1 & careint3cat==2 if (lag_careint3cat<. & careint3cat<.)
gen high_low = lag_careint3cat ==2 & careint3cat==1 if (lag_careint3cat<. & careint3cat<.)
gen high_no = lag_careint3cat ==2 & careint3cat==0 if (lag_careint3cat<. & careint3cat<.)


global demographic "ragey_diff partner_diff"
global familynetwork "rchild_diff rlivpar_diff rdisib_diff rngc_diff"
global work "rwork_diff"
global eco "rpripen_diff rpubpen_diff hhownrnt_diff"
global health "riadltot2_e_diff radltot6_diff rshlt_diff"
global mediator "rgoing_diff rfinan_diff"

* sample
reg rworkat_diff i.rgcare1w_pos i.rgcare1w_neg $demographic $familynetwork $work $eco $health $mediator if r10age_cat<=2 & r11age_cat<=2
gen sample = e(sample)
 
**# probability of working after age 60 (for people aged <60 in both waves)
* provide care last week
reg rworkat_diff i.rgcare1w_pos i.rgcare1w_neg if r10age_cat<=2 & r11age_cat<=2 & sample
est store m511

reg rworkat_diff i.rgcare1w_pos i.rgcare1w_neg $demographic $familynetwork $work if r10age_cat<=2 & r11age_cat<=2 & sample
est store m512

reg rworkat_diff i.rgcare1w_pos i.rgcare1w_neg $demographic $familynetwork $work $eco $health  if r10age_cat<=2 & r11age_cat<=2 & sample
est store m513


reg rgoing_diff i.rgcare1w_pos i.rgcare1w_neg $demographic $familynetwork $work $eco $health  if r10age_cat<=2 & r11age_cat<=2 & sample
est store m91

reg rfinan_diff i.rgcare1w_pos i.rgcare1w_neg $demographic $familynetwork $work $eco $health  if r10age_cat<=2 & r11age_cat<=2 & sample
est store m92



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

* recipient: give care to other relatives 
reg rworkat_diff i.rgrcare1w_pos i.rgrcare1w_neg ragey_diff if r10age_cat<=2 & r11age_cat<=2
est store m57

* relationship to recipient

reg rworkat_diff i.rgscare1w_pos i.rgscare1w_neg i.rgccare1w_pos i.rgkcare1w_pos i.rgkcare1w_neg i.rgpcare1w_pos i.rgpcare1w_neg i.rgrcare1w_pos i.rgrcare1w_neg  if r10age_cat<=2 & r11age_cat<=2 & sample
est store m581

reg rworkat_diff i.rgscare1w_pos i.rgscare1w_neg i.rgccare1w_pos i.rgkcare1w_pos i.rgkcare1w_neg  i.rgpcare1w_pos i.rgpcare1w_neg i.rgrcare1w_pos i.rgrcare1w_neg $demographic $familynetwork $work if r10age_cat<=2 & r11age_cat<=2 & sample
est store m582

reg rworkat_diff i.rgscare1w_pos i.rgscare1w_neg i.rgccare1w_pos i.rgkcare1w_pos i.rgkcare1w_neg  i.rgpcare1w_pos i.rgpcare1w_neg i.rgrcare1w_pos i.rgrcare1w_neg $demographic $familynetwork $work $eco $health if r10age_cat<=2 & r11age_cat<=2 & sample
est store m583



* intensity
reg rworkat_diff i.no_low i.no_high i.low_no i.low_high i.high_low i.high_no  if r10age_cat<=2 & r11age_cat<=2 & sample
est store m591

reg rworkat_diff i.no_low i.no_high i.low_no i.low_high i.high_low i.high_no $demographic $familynetwork $work if r10age_cat<=2 & r11age_cat<=2 & sample 
est store m592

reg rworkat_diff i.no_low i.no_high i.low_no i.low_high i.high_low i.high_no $demographic $familynetwork $work $eco $health if r10age_cat<=2 & r11age_cat<=2 & sample 
est store m593

outreg2 [m511 m512 m513 m581 m582 m583 m591 m592 m593] using "${tables}/model_result", word alpha(0.001,0.01,0.05, 0.1) symbol(***, **, *, +) dec(3) replace




**# probability of working after age 70 (for people aged < 70 in both waves) 
* provide care last week
reg rworkat70_diff i.rgcare1w_pos i.rgcare1w_neg if r10age_cat<=2 & r11age_cat<=2 & sample
est store m711

reg rworkat70_diff i.rgcare1w_pos i.rgcare1w_neg $demographic $familynetwork $work if r10age_cat<=2 & r11age_cat<=2 & sample
est store m712

reg rworkat70_diff i.rgcare1w_pos i.rgcare1w_neg $demographic $familynetwork $work $eco $health  if r10age_cat<=2 & r11age_cat<=2 & sample
est store m713


reg rgoing_diff i.rgcare1w_pos i.rgcare1w_neg $demographic $familynetwork $work  if r10age_cat<=2 & r11age_cat<=2 & sample

reg rfinan_diff i.rgcare1w_pos i.rgcare1w_neg $demographic $familynetwork $work $eco $health  if r10age_cat<=2 & r11age_cat<=2 & sample



* recipient: give care to long-term sick/disabled
reg rworkat70_diff i.rgcaresck_pos i.rgcaresck_neg ragey_diff if r10age_cat<=2 & r11age_cat<=2
est store m73


* recipient: give care to spouse
reg rworkat70_diff i.rgscare1w_pos i.rgscare1w_neg ragey_diff if r10age_cat<=2 & r11age_cat<=2
est store m74

* recipient: give care to children
reg rworkat70_diff i.rgccare1w_pos i.rgccare1w_neg ragey_diff if r10age_cat<=2 & r11age_cat<=2
est store m75

* recipient: give care to grandchildren 
reg rworkat70_diff i.rgkcare1w_pos i.rgkcare1w_neg ragey_diff if r10age_cat<=2 & r11age_cat<=2
est store m76

* recipient: give care to other relatives 
reg rworkat70_diff i.rgrcare1w_pos i.rgrcare1w_neg ragey_diff if r10age_cat<=2 & r11age_cat<=2
est store m77

* relationship to recipient

reg rworkat70_diff i.rgscare1w_pos i.rgscare1w_neg i.rgccare1w_pos i.rgkcare1w_pos i.rgkcare1w_neg i.rgpcare1w_pos i.rgpcare1w_neg i.rgrcare1w_pos i.rgrcare1w_neg  if r10age_cat<=2 & r11age_cat<=2 & sample
est store m781

reg rworkat70_diff i.rgscare1w_pos i.rgscare1w_neg i.rgccare1w_pos i.rgkcare1w_pos i.rgkcare1w_neg  i.rgpcare1w_pos i.rgpcare1w_neg i.rgrcare1w_pos i.rgrcare1w_neg $demographic $familynetwork $work if r10age_cat<=2 & r11age_cat<=2 & sample
est store m782

reg rworkat70_diff i.rgscare1w_pos i.rgscare1w_neg i.rgccare1w_pos i.rgkcare1w_pos i.rgkcare1w_neg  i.rgpcare1w_pos i.rgpcare1w_neg i.rgrcare1w_pos i.rgrcare1w_neg $demographic $familynetwork $work $eco $health if r10age_cat<=2 & r11age_cat<=2 & sample
est store m783

reg rgoing_diff i.rgscare1w_pos i.rgscare1w_neg i.rgccare1w_pos i.rgkcare1w_pos i.rgkcare1w_neg  i.rgpcare1w_pos i.rgpcare1w_neg i.rgrcare1w_pos i.rgrcare1w_neg $demographic $familynetwork $work $eco $health  if r10age_cat<=2 & r11age_cat<=2 & sample
est store m93

reg rfinan_diff i.rgscare1w_pos i.rgscare1w_neg i.rgccare1w_pos i.rgkcare1w_pos i.rgkcare1w_neg  i.rgpcare1w_pos i.rgpcare1w_neg i.rgrcare1w_pos i.rgrcare1w_neg $demographic $familynetwork $work $eco $health  if r10age_cat<=2 & r11age_cat<=2 & sample
est store m94


* intensity
reg rworkat70_diff i.no_low i.no_high i.low_no i.low_high i.high_low i.high_no  if r10age_cat<=2 & r11age_cat<=2 & sample
est store m791

reg rworkat70_diff i.no_low i.no_high i.low_no i.low_high i.high_low i.high_no $demographic $familynetwork $work if r10age_cat<=2 & r11age_cat<=2 & sample 
est store m792

reg rworkat70_diff i.no_low i.no_high i.low_no i.low_high i.high_low i.high_no $demographic $familynetwork $work $eco $health if r10age_cat<=2 & r11age_cat<=2 & sample 
est store m793

reg rgoing_diff i.no_low i.no_high i.low_no i.low_high i.high_low i.high_no $demographic $familynetwork $work $eco $health  if r10age_cat<=2 & r11age_cat<=2 & sample
est store m95

reg rfinan_diff i.no_low i.no_high i.low_no i.low_high i.high_low i.high_no $demographic $familynetwork $work $eco $health  if r10age_cat<=2 & r11age_cat<=2 & sample
est store m96

outreg2 [m711 m712 m713 m781 m782 m783 m791 m792 m793] using "${tables}/model_result", word alpha(0.001,0.01,0.05, 0.1) symbol(***, **, *, +) dec(3) replace


outreg2 [m91 m92 m93 m94 m95 m96] using "${tables}/model_result", word alpha(0.001,0.01,0.05, 0.1) symbol(***, **, *, +) dec(3) replace



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

outreg2 [m91 m92] using "${tables}/model_result", word alpha(0.001,0.01,0.05, 0.1) symbol(***, **, *, +) dec(3) replace


*******************************
**# OLS regression (wide data)
*******************************
* run code before "Fixed effect" section

reshape wide r@agey inw@ r@mstat r@shlt r@iadltot2_e r@adltot6 r@iadltot1_e h@hownrnt r@child r@livpar r@disib r@work r@liv10 r@workat r@workata r@workl65 r@workat70 r@workat70f r@gcare1m r@gcare1w r@gscare1w r@gccare1w r@gkcare1w r@gpcare1w r@grcare1w r@gcareinhh1w r@gcarehpw r@gcaresck h@hhres r@lbrf_e r@soc2000 r@jhours r@jphysl r@pripen r@pubpen r@ngc partner@ careloc@ careint@ careint3cat@ r@selfemp r@le85 r@hwealth r@gor r@gor_n r@cesd r@going r@finan, i(idauniq) j(wave)

//drop r1agey-r9hwealth
global demographic " r10agey i.ragender i.raracem i.partner10 i.edu"
global familynetwork " c.r10child c.r10livpar c.r10disib c.r10ngc"
global work "i.r10work i.r10jphysl c.r10jhours"
global health "c.r10iadltot2_e c.r10adltot6 c.r10shlt"
global eco "i.r10pripen i.r10pubpen i.h10hownrnt c.r10hwealth"


global mechanism ""

reg r11workat i.r10gcare1w#i.r11gcare1w r10workat $demographic  $familynetwork $health $eco $work if r11workata==60 & r10age_cat<=2 & r11age_cat<=2
gen sample = e(sample)


**# probability of working after age 60 (for people aged < 60 in both waves) 

* provide care last week
reg r11workat i.r10gcare1w#i.r11gcare1w r10workat  if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample
est store m11

reg r11workat i.r10gcare1w#i.r11gcare1w r10workat $demographic $familynetwork $health $eco $work if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample
est store m12


* recipient: give care to long-term sick/disabled
reg r11workat i.r10gcaresck#i.i.r11gcaresck r10workat  if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample

reg r11workat i.r10gcaresck#i.i.r11gcaresck r10workat  $demographic $familynetwork $health $eco $work if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample


* recipient: give care to spouse
reg r11workat i.r10gscare1w#i.r11gscare1w   if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample

reg r11workat i.r10gscare1w#i.r11gscare1w r10workat  $demographic $familynetwork $health $eco $work if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample


* recipient: give care to children
reg r11workat i.r10gccare1w#i.r11gccare1w r10workat  if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample

reg r11workat i.r10gccare1w#i.r11gccare1w r10workat  $demographic $familynetwork $health $eco $work if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample

* recipient: give care to grandchildren 
reg r11workat i.r10gkcare1w#i.r11gkcare1w r10workat  if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample

reg r11workat i.r10gkcare1w#i.r11gkcare1w r10workat  $demographic $familynetwork $health $eco $work  if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample

* recipient: give care to parents
reg r11workat i.r10gpcare1w#i.r11gpcare1w r10workat  if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample

reg r11workat i.r10gpcare1w#i.r11gpcare1w r10workat  $demographic $familynetwork $health $eco $work if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample



* all recipient
reg r11workat r10workat i.r10gscare1w#i.r11gscare1w i.r10gccare1w#i.r11gccare1w  i.r10gkcare1w#i.r11gkcare1w i.r10gpcare1w#i.r11gpcare1w i.r10grcare1w#i.r11grcare1w    if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample 
est store m21
reg r11workat r10workat i.r10gscare1w#i.r11gscare1w i.r10gccare1w#i.r11gccare1w  i.r10gkcare1w#i.r11gkcare1w i.r10gpcare1w#i.r11gpcare1w i.r10grcare1w#i.r11grcare1w  $demographic  $familynetwork $health $eco $work if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample
est store m22
  
* location: provided care to someone in hh last week
reg r11workat i.careloc10#i.careloc11 r10workat  if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample
est store m31
reg r11workat i.careloc10#i.careloc11 r10workat $demographic $familynetwork $health $eco $work if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample
est store m32

* intensity: hours per week provided care
reg r11workat i.careint3cat10 r10agey r10workat  if r11workata==60 & r10age_cat<=2 & r11age_cat<=2

reg r11workat i.careint3cat10#i.careint3cat11 r10workat  if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample
est store m41
reg r11workat i.careint3cat10#i.careint3cat11 r10workat $demographic  $familynetwork $health $eco $work if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample
est store m42

outreg2 [m11 m12 m21 m22 m31 m32 m41 m42] using "${tables}/model_result", word alpha(0.001,0.01,0.05, 0.1) symbol(***, **, *, +) dec(3) replace
outreg2 [m13 m14 m23 m24 m33 m34 m43 m44] using "${tables}/model_result", word alpha(0.001,0.01,0.05, 0.1) symbol(***, **, *, +) dec(3) replace


**# probability of working after age 70 (for people aged < 70 in both waves) 
* provide care last week
reg r11workat70 i.r10gcare1w#i.r11gcare1w r10agey r10workat70  if r10age_cat<=2 & r11age_cat<=2 & sample
est store m13
reg r11workat70 i.r10gcare1w#i.r11gcare1w r10agey r10workat70 $demographic $familynetwork $health $eco $wor if r10age_cat<=2 & r11age_cat<=2 & sample
est store m14

* recipient: give care to long-term sick/disabled
reg r11workat70 i.r10gcare1w#i.r11gcare1w r10workat70  if r10age_cat<=2 & r11age_cat<=2 
reg r11workat70 i.r10gcaresck#i.r11gcaresck r10workat70 $demographic $familynetwork $health $eco $wor if r10age_cat<=2 & r11age_cat<=2


* recipient: give care to spouse
reg r11workat70 i.r10gscare1w#i.r11gscare1w r10workat70  if r10age_cat<=2 & r11age_cat<=2
reg r11workat70 i.r10gscare1w#i.r11gscare1w r10workat70 $demographic $familynetwork $health $eco $wor if r10age_cat<=2 & r11age_cat<=2

* recipient: give care to children
reg r11workat70 i.r10gccare1w#i.r11gccare1w r10workat70  if r10age_cat<=2 & r11age_cat<=2
reg r11workat70 i.r10gccare1w#i.r11gccare1w r10workat70 $demographic $familynetwork $health $eco $wor if r10age_cat<=2 & r11age_cat<=2

* recipient: give care to grandchildren 
reg r11workat70 i.r10gkcare1w#i.r11gkcare1w r10workat70  if r10age_cat<=2 & r11age_cat<=2
reg r11workat70 i.r10gkcare1w#i.r11gkcare1w r10workat70 $demographic $familynetwork $health $eco $wor if r10age_cat<=2 & r11age_cat<=2

* recipient: give care to other relatives (mainly parents) 
reg r11workat70 i.r10gpcare1w#i.r11gpcare1w r10workat70  if r10age_cat<=2 & r11age_cat<=2
reg r11workat70 i.r10gpcare1w#i.r11gpcare1w r10workat70 $demographic $familynetwork $health $eco $wor if r10age_cat<=2 & r11age_cat<=2


* all recipient
reg r11workat70 r10workat70 i.r10gscare1w#i.r11gscare1w i.r10gccare1w#i.r11gccare1w  i.r10gkcare1w#i.r11gkcare1w i.r10gpcare1w#i.r11gpcare1w i.r10grcare1w#i.r11grcare1w    if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample 
est store m23
reg r11workat70 r10workat70 i.r10gscare1w#i.r11gscare1w i.r10gccare1w#i.r11gccare1w  i.r10gkcare1w#i.r11gkcare1w i.r10gpcare1w#i.r11gpcare1w i.r10grcare1w#i.r11grcare1w  $demographic  $familynetwork $health $eco $work if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample
est store m24


* location: provided care to someone in hh last week
reg r11workat70 i.careloc10#i.careloc11 r10workat70  if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample
est store m33
reg r11workat70 i.careloc10#i.careloc11 r10workat70 $demographic $familynetwork $health $eco $work if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample
est store m34

* intensity: hours per week provided care
reg r11workat70 i.careint3cat10 r10workat70  if r11workata==60 & r10age_cat<=2 & r11age_cat<=2

reg r11workat70 i.careint3cat10#i.careint3cat11 r10workat70  if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample
est store m43
reg r11workat70 i.careint3cat10#i.careint3cat11 r10workat70 $demographic $familynetwork $health $eco $work if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & sample
est store m44




****************
* matching:CEM *
****************

gen trincare = 1 if r10gcare1w==0 & r11gcare1w==1
replace trincare = 0 if r10gcare1w==0 & r11gcare1w==0

gen troutcare = 1 if r10gcare1w==1 & r11gcare1w==0
replace troutcare = 0 if r10gcare1w==0 & r11gcare1w==0

gen concare = 1 if r10gcare1w==1 & r11gcare1w==1
replace concare = 0 if r10gcare1w==0 & r11gcare1w==0

global cov " r10agey ragender partner10 r10gor_n r10workat"

global familynetwork " c.r10child c.r10livpar c.r10disib c.r10ngc"
global health "c.r10iadltot2_e c.r10adltot6 i.r10shlt"
global eco "i.edu i.r10pripen i.r10pubpen i.h10hownrnt r10hwealth"
global work "i.r10work i.r10jphysl c.r10jhours"
global demographic " r10agey i.ragender i.raracem i.partner10 i.r10gor_n"



reg r11workat i.trincare 
imb ragender raracem if r11workata==60 & r10age_cat<=2 & r11age_cat<=2, treatment(trincare)
cem $cov if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & trincare<., tr(trincare)
 
reg r11workat i.trincare [weight=cem_weights] if r11workata==60 & r10age_cat<=2 & r11age_cat<=2


reg r11workat i.troutcare

imb $cov if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & troutcare<.
cem $cov if r11workata==60 & r10age_cat<=2 & r11age_cat<=2 & troutcare<., tr(troutcare)

reg r11workat i.troutcare [weight=cem_weights] if r11workata==60 & r10age_cat<=2 & r11age_cat<=2