* ================================================
* 03 Caregiving and Subjective health expectations
* ================================================
* Author: Jingwen Zhang
* Version 1:
* Date: 12/03/2026
* Aim: 
* (1) clean variables 
* (2) 
* compare onset of caregiving and future carer
* identification of onset of caregiving: never cared before (survey waves; care history)
* identification of future carer: never cared before but will care in the future (survey waves; care history)
* exact matching: based on survey waves bysort waves: have treated and control 
* entropy matching

* repeated carer and care exit
use "$g3", clear


keep idauniq r*agey inw* ragender raracem raeduc_e r*mstat r*shlt r*adltot6 r*iadltot2_e r*iadltot1_e h*hownrnt r*child r*livpar r*work r*liv10 r*workat r*workata r*workl65 r*gcare1m r*gcare1w r*gscare1w r*gccare1w r*gkcare1w r*gcarehpw r*gcaresck h*hhres r*lbrf_e r*soc2000 r*jhours r*jphysl r*jcpen r*pubpen h*atotf r*livsib r*region_e r*cesd 


drop inw*sc r*fagey r*ipubpen  r*ifpubpen

merge 1:1 idauniq using "${temp}\00_wave11_h.dta", update


reshape long  r@agey inw@ r@mstat r@shlt r@adltot6 r@iadltot2_e r@iadltot1_e h@hownrnt r@child r@livpar r@work r@liv10 r@workat r@workata r@workl65 r@gcare1m r@gcare1w r@gscare1w r@gccare1w r@gkcare1w r@gcarehpw r@gcaresck h@hhres r@lbrf_e r@soc2000 r@jhours r@jphysl r@jcpen r@pubpen  h@atotf r@livsib r@region_e r@cesd, i(idauniq) j(wave)  


// (variable	r1iadltot2_e not found)
// (variable	r1gcare1m not found)
// (variable	r1gcarehpw not found)
// (variable	r1rchilda not found)
// (variable	r2iadltot2_e not found)
// (variable	r2gcaresck not found)
// (variable	r2rchilda not found)
// (variable	r3shlt not found)
// (variable	r3iadltot2_e not found)
// (variable	r3gcaresck not found)


 
* future carer: 
* work status: working for at least 4 waves. 

*************************
**# encode missing values
*************************
count if inlist(hatotf, -18, -16, -14, -13, -4)
* wealth quintile
xtile hwealth_5 = hatotf, nq(5)
mvdecode _all, mv(-18 -9=.r \ -16 = .p \ -14 = .n \ -13 = .m \ -4 -8= .d)



****************************************
**# covariates cleaning
****************************************

fre ragey ragender raracem 
fre rchild rlivpar rlivsib
fre radltot6 riadltot2_e rshlt //riadltot2_e does not have wave 1-3; rshlt does not have wave 3


* marital status
gen partner = 1 if inlist(rmstat, 1,3)
replace partner = 0 if inlist(rmstat, 4, 5, 7, 8)

* education
recode raeduc_e (1 = 1 "no qualification") (2/5 = 2 "below degree") (6 = 3 "degree") (-15 = 4 "other"), gen(edu)

* age_cat
recode ragey (50/54 = 1) (55/59 = 2) (60/64 = 3) (else =.), gen(age_cat3)

global demographic "c.ragey i.ragender i.raracem i.partner"
global familynetwork " c.rchild c.rlivpar c.rlivsib"
global health "radltot6"
global ses "i.edu i.hwealth_5"
global work "i.rjphysl c.rjhours"

*********************************************
**# create treatement variable: informal care
*********************************************
xtset idauniq wave
* ever carer: have not cared in any previous available waves
gen rgcare1w_l1=L.rgcare1w
forvalues i=2(1)10{
	local j = `i'-1
	gen rgcare1w_l`i'=L.rgcare1w_l`j'
}
order rgcare1w_l*, after(rgcare1w)

gen rgcare1w_f1 = F.rgcare1w 
forvalues i=2(1)10{
	local j = `i'-1
	gen rgcare1w_f`i'=F.rgcare1w_f`j'
}
order rgcare1w_f*, after(rgcare1w)

egen evercarer=anymatch(rgcare1w_l*),values(1)
egen evercarer_miss = rowmiss(rgcare1w_l*)
replace evercarer=. if evercarer_miss==10
// we don't consider sample who do not have any previous waves

* future carer: 
//current and next wave not carer, but will care in the future m={2,3} 
gen futurecarer = 1 if evercarer==0 & rgcare1w==0 & rgcare1w_f1==0 & (rgcare1w_f2==1 | rgcare1w_f3 ==1) 
// no restriction on future waves m>1
egen anyfuture=anycount(rgcare1w_f2-rgcare1w_f10),values(1)
gen futurecarer2 = 1 if evercarer==0 & rgcare1w==0 & rgcare1w_f1==0 & anyfuture==1
// no restriction on next wave
egen anyfuture2=anycount(rgcare1w_f*),values(1)
gen futurecarer3 = 1 if evercarer==0 & rgcare1w==0 &  anyfuture2==1

* outcome variable: short-term impact
gen rworkl65_f1 = F.rworkl65
gen rworkl65_f2 = F.rworkl65_f1

* treatment variable
// restricted future carer
gen treated = 1 if rgcare1w==1 & evercarer==0
replace treated = 0 if futurecarer==1
// future carer no future wave restriction
gen treated2 = 1 if rgcare1w==1 & evercarer==0
replace treated2 = 0 if futurecarer2==1

// future carer no next wave restriction
gen treated3 = 1 if rgcare1w==1 & evercarer==0
replace treated3 = 0 if futurecarer3==1


*********************************************
**# create treatement variable: long-term care
*********************************************
tab wave rgcaresck
replace rgcaresck = . if wave==1
* ever carer: have not cared in any previous available waves
gen rgcaresck_l1=L.rgcaresck
forvalues i=2(1)7{
	local j = `i'-1
	gen rgcaresck_l`i'=L.rgcaresck_l`j'
}
order rgcaresck_l*, after(rgcaresck)

gen rgcaresck_f1 = F.rgcaresck
forvalues i=2(1)7{
	local j = `i'-1
	gen rgcaresck_f`i'=F.rgcaresck_f`j'
}
order rgcaresck_f*, after(rgcaresck)

egen eversckcarer=anymatch(rgcaresck_l*),values(1)
egen eversckcarer_miss = rowmiss(rgcaresck_l*)
replace eversckcarer=. if eversckcarer_miss==7
// we don't consider sample who do not have any previous waves

* future carer: 
//current and next wave not carer, but will care in the future m={2,3} 
gen futuresckcarer = 1 if eversckcarer==0 & rgcaresck==0 & rgcaresck_f1==0 & (rgcaresck_f2==1 | rgcaresck_f3 ==1) 
// no restriction on future waves m>1
egen anyfuturesck=anycount(rgcaresck_f2-rgcaresck_f7),values(1)
gen futuresckcarer2 = 1 if eversckcarer==0 & rgcaresck==0 & rgcaresck_f1==0 & anyfuturesck==1
// no restriction on next wave
egen anyfuturesck2=anycount(rgcaresck_f*),values(1)
gen futuresckcarer3 = 1 if eversckcarer==0 & rgcaresck==0 &  anyfuturesck2==1


* treatment variable
gen treated_sck = 1 if rgcaresck==1 & eversckcarer==0
replace treated_sck = 0 if futuresckcarer == 1

gen treated_sck2 = 1 if rgcaresck==1 & eversckcarer==0
replace treated_sck2 = 0 if futuresckcarer2 == 1

gen treated_sck3 = 1 if rgcaresck==1 & eversckcarer==0
replace treated_sck3 = 0 if futuresckcarer3 == 1

****************
**# Descriptive 
****************
// people who are older than 50; ragey>=50 & rage<65
* evercarer
binscatter evercarer wave if inrange(ragey, 50, 64), line(connect) xtitle(Wave) ytitle(Proportion of evercarer) 
binscatter eversckcarer wave if inrange(ragey, 50, 64), line(connect) xtitle(Wave) ytitle(Proportion of evercarer) 

* current employment status by wave
binscatter rwork wave if inrange(ragey, 50, 64), by(evercarer) line(connect) xtitle(Wave) ytitle(Proportion of in paid work) legend(lab(1 "Never carer") lab(2 "Ever carer"))
binscatter rwork wave if inrange(ragey, 50, 64), by(eversckcarer) line(connect) xtitle(Wave) ytitle(Proportion of in paid work) legend(lab(1 "Never carer") lab(2 "Ever carer"))


* % expectation of work limiting health problem
binscatter rworkl65 wave if inrange(ragey, 50, 64), by(evercarer) line(connect) xtitle(Wave) ytitle(% work limiting health problem at 65) legend(lab(1 "Never carer") lab(2 "Ever carer"))
binscatter rworkl65 wave if inrange(ragey, 50, 64), by(eversckcarer) line(connect) xtitle(Wave) ytitle(% work limiting health problem at 65) legend(lab(1 "Never carer") lab(2 "Ever carer"))

* work transitions 
gen work_l1 = L.rwork 
gen work_f1 = F.rwork 
gen work_f2 = F.work_f1 
order work_l1 work_f1 work_f2, after(rwork)

tab work_l1 rwork if inrange(ragey, 50, 65) & rgcare1w==1 & evercarer==0, cell
tab work_f1 work_f2 if inrange(ragey, 50, 65) & rgcare1w==1 & evercarer==0 & work_l1==1 & rwork==1, cell


tab work_l1 rwork if inrange(ragey, 50, 65) & rgcaresck==1 & eversckcarer==0, cell
tab work_f1 work_f2 if inrange(ragey, 50, 65) & rgcaresck==1 & eversckcarer==0 & work_l1==1 & rwork==1, cell

* caregiving trajectory
tab rgcaresck_f1 if rgcaresck==1 & eversckcarer==0
tab rgcaresck_f2 rgcaresck_f1 if rgcaresck==1 & eversckcarer==0




***********************
**# Baseline regression 
***********************
reg rworkl65 i.rgcare1w i.wave if wave<10 & inrange(ragey, 50, 64) & evercarer==0
reg rworkl65 i.rgcare1w i.wave $demographic $familynetwork $health $eco $work if wave<10 & inrange(ragey, 50, 64) & evercarer==0

xtreg rworkl65  i.rgcare1w $demographic $familynetwork $health i.hwealth_5 if  inrange(ragey, 50, 64) , fe
xtreg rworkl65  i.rgcaresck ragey i.partner $familynetwork $health  if  inrange(ragey, 50, 64) , fe



***********************
** matching
***********************
* katch 
kmatch em treated2 wave (rworkl65), att
kmatch em treated2 wave (rworkl65 =  $demographic $familynetwork $health $eco) if wave<10 , eb(  $demographic $familynetwork $health $eco ) att 
kmatch em treated2 wave (rworkl65_f1 = ragender raracem raeduc_e hhhres) if inrange(ragey, 50, 64), eb(ragender raracem raeduc_e hhhres) att 
kmatch em treated2 wave (rworkl65_f2 = ragender raracem raeduc_e hhhres) if inrange(ragey, 50, 64), eb(ragender raracem raeduc_e hhhres) att 


kmatch em treated_sck3 wave (rworkl65) if inrange(ragey, 50, 64), att
kmatch em treated_sck3 wave (rworkl65 =  $demographic $familynetwork $health $eco) if inrange(ragey, 50, 64), eb(  $demographic $familynetwork $health $eco ) att

kmatch summarize
kmatch em treated_sck3 wave (rworkl65_f1 =  $demographic $familynetwork $health $eco) if inrange(ragey, 50, 64), eb(  $demographic $familynetwork $health $eco ) att 
kmatch em treated_sck3 wave (rworkl65_f2 =  $demographic $familynetwork $health $eco) if inrange(ragey, 50, 64), eb(  $demographic $familynetwork $health $eco ) att 

* cem + ebalance
keep if treated_sck3<. & inrange(ragey, 50, 64)
imb wave, treatment(treated_sck3)
cem wave, treatment(treated_sck3) k2k
reg rworkl65 i.treated_sck3 if cem_matched==1
est store m0

ebalance treated_sck3 $demographic $familynetwork $health  if cem_matched==1
reg rworkl65 treated_sck3  $demographic $familynetwork $health [pw=_webal]  if cem_matched==1
est store m1

outreg2 [m0 m1] using "${tables}/model_result", word alpha(0.001,0.01,0.05, 0.1) symbol(***, **, *, +) dec(3) replace
