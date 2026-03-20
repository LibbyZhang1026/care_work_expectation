* =================================
* 01_Data cleaning ELSA wave 10
* =================================
* Author: Jingwen Zhang
* Version 1:
* Date: 18/11/2025
* Aim: Clean future work expectation and work characteristics

clear all
set more off
set maxvar 15000
use "$elsa10", clear

* Identifier
gen hhid = idahhw10*10 + perid
gen hhsid = idahhw10*10 + cpid
vlookup hhsid, generate(s10idauniq) key(hhid) value(idauniq)

*********************
* Socio-demogrpahic *
*********************

* gender
gen ragender = indsex

* age 
gen r10agey=.
replace r10agey = indager if inrange(indager,10,90)
replace r10agey = 90 if indager==-7

* age categories
recode indager (16/54 = 1 "<=54") (55/59 = 2 "55-59") (60/64 =3 "60-64") (65/69 =4 "65-69") (70/90 -7 = 5 ">=70"), gen(r10age_cat)

* education
merge 1:1 idauniq using "${elsa}\wave_10_ifs_derived_variables.dta", keepusing(edqual) gen(ifs0)

gen r10educ_e =.
replace r10educ_e = -15 if edqual == 6
replace r10educ_e = 1 if inlist(edqual,7,5)
replace r10educ_e = 3 if edqual == 4
replace r10educ_e = 4 if inlist(edqual, 2, 3)
replace r10educ_e = 5 if edqual == 1
label variable r10educ_e "r10educ_e: r education (categ)"


* race
gen raracem=4 if fqethnmr==2
replace raracem=1 if fqethnmr==1

* marital status
gen r10mstat=.
replace r10mstat = 1 if inlist(dimarr,2,3)
replace r10mstat = 4 if dimarr==4
replace r10mstat = 5 if dimarr==5
replace r10mstat = 7 if dimarr==6
replace r10mstat = 8 if dimarr == 1
replace r10mstat = 3 if (inlist(dimarr,1,5,6)) & couple==2
label variable r10mstat "r10mstat:w10 r marital status w/partners, filled"


* number of people in the household
gen h10hhres= hhtot

* number of children
// chinhh

* living children: r10child
merge 1:1 idauniq using "${elsa}\wave_10_ifs_derived_variables.dta", keepusing(pp_occ chsex* falive malive) gen(ifs1)
egen r10child = anycount(chsex*), values(1,2)
egen r10childm = anycount(chsex*), values(-8,-9)
replace r10child=. if r10childm!=0

* living parent: r10livpar
egen r10livpar = anycount(falive malive), values(1)
replace r10livpar = . if malive<0 & falive<0

*Nation
//gor

* respondent Live in Nursing home 
gen r10nhmliv = .
replace r10nhmliv = 0 if inlist(w10indout,11,13,21,23)
replace r10nhmliv = 1 if inlist(w10indout,24,25)
label variable r10nhmliv "r10nhmliv:w10 R Lives in institution at interview"



*********************
**# work expectations *
*********************

* wave 10 respondent probability of living to 75-120 
gen r10liv10 = .
replace r10liv10 = .m if exlo80 == -1
replace r10liv10 = .d if exlo80 == -8
replace r10liv10 = .r if exlo80 == -9
replace r10liv10 = .p if exlo80 == -1 & askpx == 1
replace r10liv10 = exlo80 if inrange(exlo80,0,100)
label variable r10liv10 "r10liv10:w10 R probability of living to 75-120"


* wave 10 respondent age used in live 75-120
gen r10liv10a = .
replace r10liv10a = 75 if indager > 0 & indager <= 65
replace r10liv10a = 80 if indager > 65 & indager <= 69
replace r10liv10a = 85 if indager > 69 & indager <= 74
replace r10liv10a = 90 if indager > 74 & indager <= 79
replace r10liv10a = 95 if indager > 79 & indager <= 84
replace r10liv10a = 100 if indager > 84 & indager <= 99
replace r10liv10a = 105 if indager > 99 & indager <= 104
replace r10liv10a = 110 if indager > 104 & indager <= 109
replace r10liv10a = 120 if indager > 109 & indager <= 119
label variable r10liv10a "r10liv10a:w10 R age used in live 75-120"


* subjective life expectancy of people aged < 70: probability of age 85
gen r10le85 = exlo90 if exlo90>=0
replace r10le85 = 0 if exlo80==0 & r10agey<70
// missing: 110 don't know or refuse; 240 proxy


* wave 10 respondent probability of working after age
gen r10workat = .
replace r10workat = .m if expw == -1
replace r10workat = .d if expw == -8
replace r10workat = .r if expw == -9
replace r10workat = .p if expw == -1 & askpx == 1
replace r10workat = .i if indager >= 65
replace r10workat = expw if inrange(expw,0,100)
label variable r10workat "r10workat:w10 R probability of working after age"


* wave 10 respondent age used in probability of working 
gen r10workata = .
replace r10workata = .i if indager >= 65
replace r10workata = 60 if indager > 0 & indager <= 59
replace r10workata = 65 if indager >59 & indager <= 64
label variable r10workata "r10workata:w10 R age used in probability of working"


* work full-time after age
gen r10workatf = .m if  expwf == -1
replace r10workatf = .d if expwf == -8
replace r10workatf = .p if expwf == -1 & askpx == 1
replace r10workatf = .a if indager >= 65
replace r10workatf = .i if expwf == -1 & r10workat ==0
replace r10workatf = expwf if inrange(expwf,0,100)
label variable r10workatf "r10workatf:w10 R probability of working full time after age"

* work after 70

gen r10workat70= .m if   expw70 == -1
replace r10workat70 = .d if expw70 == -8
replace r10workat70 = .r if expw70 == -9
replace r10workat70 = .p if expw70 == -1 & askpx == 1
replace r10workat70 = expw70 if inrange(expw70,0,100) 
replace r10workat70 = .a if indager >= 70
replace r10workat70 = .i if expw70 == -1 & r10workat ==0

//replace r10workat70 = 0 if indager<65 & r10workat==0


* work after 70 full time

gen r10workat70f= .m if   expw70f == -1
replace r10workat70f = .d if expw70f == -8
replace r10workat70f = .r if expw70f == -9
replace r10workat70f = .p if expw70f == -1 & askpx == 1
replace r10workat70f = expw70f if inrange(expw70f,0,100) 
replace r10workat70f = .i if expw70f == -1 & r10workat70 ==0
replace r10workat70f = .i if expw70f == -1 & r10workat ==0
replace r10workat70f = .a if indager >= 70
//replace r10workat70 = 0 if indager<65 & r10workat==0

*wave 10 respondent work limit health problem before age 65
gen r10workl65 = .
replace r10workl65 = .m if exhlim == -1 
replace r10workl65 = .d if exhlim == -8
replace r10workl65 = .r if exhlim == -9
replace r10workl65 = .p if exhlim == -1 & askpx == 1
replace r10workl65 = .w if exhlim == -1 & (wpactpw ~= 1 & wpactse ~= 1 & wpaway ~= 1) // the respondents should be in paid work, self-employment, or temporarily away from paid work
replace r10workl65 = .i if exhlim == -1 & indager > 65
replace r10workl65 = exhlim if inrange(exhlim,0,100) 
label variable r10workl65 "r10workl65:w10 R probability of work limiting health problem"


* future financial concern
gen r10finan= exrslf if exrslf>=0


*******************
**# care provision  *
*******************

*wave 10 respondent provided any informal care last month
gen r10gcare1m = .
replace r10gcare1m = 0 if wpactca==0 | wpact96==1
replace r10gcare1m = 1 if wpactca==1
label variable r10gcare1m "r10gcare1m:w10 r provided any informal care last month"
label values r10gcare1m yesnocare

*wave 10 respondent provided any informal care last week
gen r10gcare1w = .
replace r10gcare1w = .i if ercaa== -1
replace r10gcare1w = .n if askinst==1
replace r10gcare1w = .p if askpx==1
replace r10gcare1w = .r if ercaa== -9
replace r10gcare1w = .d if ercaa== -8

replace r10gcare1w = 0 if ercaa==2 
replace r10gcare1w = 1 if ercaa==1 
label variable r10gcare1w "r10gcare1w:w10 r provided any informal care last week"
label values r10gcare1w yesnocare

*wave 10 respondent give care to long-term sick/disabled
gen r10gcaresck = .
replace r10gcaresck = . if inlist(erresck, -9, -8, -1)
replace r10gcaresck = .n if askinst==1
replace r10gcaresck = .p if askpx==1
replace r10gcaresck = 0 if erresck==2 
replace r10gcaresck = 1 if erresck==1
label variable r10gcaresck "r10gcaresck:w10 r provides informal care to long-term sick/disabled person"
label values r10gcaresck yesnocare


* wave 10 respondent give care to spouse
gen r10gscare1w = .
replace r10gscare1w = 0 if inrange(r10mstat,4,8)
replace r10gscare1w = . if ercaa<0
replace r10gscare1w = .n if askinst==1
replace r10gscare1w = .p if askpx==1
replace r10gscare1w = 0 if inlist(r10mstat,1,3) & (ercaa==2)
replace r10gscare1w = 0 if inlist(r10mstat,1,3) & ercamsp==0
replace r10gscare1w = 1 if ercamsp==1
label variable r10gscare1w "r10gscare1w:w10 r provided informal care to spouse last week"
label values r10gscare1w yesnocare
// 5 missing due to r10mstat is missing

*wave 10 respondent provided care to children last week
gen r10gccare1w = .
replace r10gccare1w = 0 if r10child==0
replace r10gccare1w = . if ercaa<0
replace r10gccare1w = .n if askinst==1
replace r10gccare1w = .p if askpx==1
replace r10gccare1w = 0 if r10child!=0 & (ercaa==2)
replace r10gccare1w = 0 if r10child!=0 & ercamch==0
replace r10gccare1w = 1 if ercamch==1
label variable r10gccare1w "r10gccare1w:w10 r provided informal care to children last week"
label values r10gccare1w yesnocare


*wave 10 respondent provided care to grandchildren last week

gen r10gkcare1w = .
replace r10gkcare1w = 0 if dignmy==0 | dignmy==-1
replace r10gkcare1w = . if ercaa<0
replace r10gkcare1w = .n if askinst==1
replace r10gkcare1w = .p if askpx==1
replace r10gkcare1w = 0 if dignmy>0 & (ercaa==2)
replace r10gkcare1w = 0 if dignmy>0 & ercamgc==0 
replace r10gkcare1w = 1 if ercamgc==1
label variable r10gkcare1w "r10gkcare1w:w10 r provided informal care to grandchildren last week"
label values r10gkcare1w yesnocare
rename dignmy r10ngc
//dignmy has 6 missing

*wave 10 respondent provided care to parents last week
gen r10gpcare1w = .
replace r10gpcare1w = .n if askinst==1
replace r10gpcare1w = 0 if falive==2 & malive==2
replace r10gpcare1w = . if ercaa<0
replace r10gpcare1w = .p if askpx==1
replace r10gpcare1w = 0 if ercaa==2
replace r10gpcare1w = 0 if ercampa==0 
replace r10gpcare1w = 1 if ercampa==1 
label variable r10gpcare1w "r10gpcare1w:w10 r provided informal care to own parents last week"
label values r10gpcare1w yesnocare


*wave 10 respondent provided care to other relatives last week  
gen r10grcare1w = .
replace r10grcare1w = .n if askinst==1
replace r10grcare1w = .p if askpx==1
replace r10grcare1w = 0 if ercaa==2
replace r10grcare1w = 0 if ercampl==0 | ercamor==0 
replace r10grcare1w = 1 if ercampl==1 | ercamor==1
label variable r10grcare1w "r10grcare1w:w10 r provided informal care to relatives last week"
label values r10grcare1w yesnocare


*wave 10 respondent provided care to someone in hh last week
gen r10gcareinhh1w = .
replace r10gcareinhh1w = .n if askinst==1
replace r10gcareinhh1w = .p if askpx==1
replace r10gcareinhh1w = 0 if ercaa==2
replace r10gcareinhh1w = 0 if ercalive==2
replace r10gcareinhh1w = 1 if ercalive==1
label variable r10gcareinhh1w "r10gcareinhh1w:w10 r provided care to someone in hhold last week"
label values r10gcareinhh1w yesnocare

* wave 10 respondent hours per week provided care
gen r10gcarehpw = .
replace r10gcarehpw = .n if askinst==1
replace r10gcarehpw = .p if askpx==1
replace r10gcarehpw = 0 if ercaa==2
replace r10gcarehpw = ercac if inrange(ercac,0,168)
label variable r10gcarehpw "r10gcarehpw:w10 # hours r provided care last week"

***********
**# Health  *
***********

** ADL IADL Mobility **
* ADL
gen r10walkra = headlwa if headlwa>=0
gen r10dressa = headldr if headldr>=0
gen r10batha = headlba if headlba>=0
gen r10eata = headlea if headlea>=0
gen r10beda = headlbe if headlbe>=0
gen r10toilta = headlwc if headlwc>=0
egen r10adltot6a = anymatch(r10walkra r10dressa r10batha r10eata r10beda r10toilta), values(1)
replace r10adltot6a = . if r10walkra==.
egen r10adltot6 = anycount(r10walkra r10dressa r10batha r10eata r10beda r10toilta), values(1)
replace r10adltot6 = . if r10walkra==.

* IADL 
gen r10moneya = headlmo if headlmo>=0
gen r10medsa = headlme if headlme>=0
gen r10shopa = headlsh if headlsh>=0
gen r10housewka = headlho if headlho>=0
gen r10communa = headlsp if headlsp>=0
gen r10phonea =  headlph if headlph>=0
gen r10mealsa = headlea if headlea>=0
gen r10dangera = headlda if headlda>=0
egen r10iadltot2_e= anycount(headlma headlda headlpr headlsh headlph ///
 headlsp headlme headlho headlmo), values(1)
replace r10iadltot2_e=. if headl96<0
egen r10iadltot2a_e= anymatch(headlma headlda headlpr headlsh headlph ///
 headlsp headlme headlho headlmo), values(1)
replace r10iadltot2a_e=. if headl96<0

egen r10iadltot1_e= anycount(headlph headlmo headlme headlsp headlpr headlma headlho), values(1)
replace r10iadltot1_e=. if headl96<0


* self rated Health
clonevar r10shlt = hehelf
replace r10shlt=.d if hehelf==-8
replace r10shlt=.p if hehelf==-1


* mental health
gen cesda = 2- psceda if psceda>=0
gen cesdb = 2- pscedb if pscedb>=0
gen cesdc = 2- pscedc if pscedc>=0
gen cesdd = pscedd-1 if pscedd>=0
gen cesde = 2- pscede if pscede>=0
gen cesdf = pscedf-1 if pscedf>=0
gen cesdg = 2- pscedg if pscedg>=0
gen cesdh = 2- pscedh if pscedh>=0


egen r10cesd = rowtotal(cesda - cesdh), missing
rename cesdh r10going


*******************
**# economic status *
*******************

* work status 

gen r10work = 1 if wpactse==1 | wpactpw==1
replace r10work = 0 if wpactse==0 & wpactpw==0

{
* income 
merge 1:1 idauniq using "$finance10", nogen

* income from pension & annuity
gen r10itpena = .
replace r10itpena = .m if mi(ppinc_r_s) 
replace r10itpena = ppinc_r_s*52 if !mi(ppinc_r_s)
label variable r10itpena "r10itpena:w10 income: r pension + annuity (after tax)"

* main public pension
// respondent individual disability pension
gen r10issdi = .
replace r10issdi = .m if (mi(icb_r_i) | mi(sda_r_i) | mi(attall_r_i) | mi(dla_r_i) | ///
		mi(indinj_r_i) | mi(carers_r_i))
replace r10issdi = (icb_r_i + sda_r_i + attall_r_i + dla_r_i + indinj_r_i + carers_r_i)*52 ///
		if !mi(icb_r_i) & !mi(sda_r_i) & !mi(attall_r_i) & !mi(dla_r_i) & !mi(indinj_r_i) & !mi(carers_r_i)
replace r10issdi = .t if (r10issdi > 100000 & !missing(r10issdi))
label variable r10issdi "r10issdi:w10 income: r public disability pension" 

// income from public pension without disability
gen r10isret = .
replace r10isret = .m if (mi(spinc_r_s) | mi(widpen_r_i)) 
replace r10isret = (spinc_r_s + widpen_r_i)*52 if !mi(spinc_r_s) & !mi(widpen_r_i)
replace r10isret = .t if (r10isret > 100000 & !missing(r10isret))
label variable r10isret "r10isret:w10 income: r public old-age pension"


gen r10ipubpen = .
replace r10ipubpen = .m if r10issdi==.m | r10isret==.m 
replace r10ipubpen = .t if r10issdi==.t | r10isret==.t
replace r10ipubpen = r10issdi + r10isret if !mi(r10issdi) & !mi(r10isret)
label variable r10ipubpen "r10ipubpen:w10 income: r public pensions"

* other government transfers
// war pensions
gen r10ivet = .
replace r10ivet = .m if mi(war_r_i) 
replace r10ivet = war_r_i*52 if !mi(war_r_i)
label variable r10ivet "r10ivet:w10 income: r war pension"

// income support
gen r10iwelf = .
replace r10iwelf = .m if (mi(is_r_i) | mi(wtc_r_i) | mi(gall_r_i) | mi(cb_r_i) | ///
		mi(ctc_r_i) | mi(pc_r_i)) 
replace r10iwelf = (is_r_i + wtc_r_i + gall_r_i + cb_r_i + ctc_r_i + pc_r_i)*52 ///
		if !mi(is_r_i) & !mi(wtc_r_i) & !mi(gall_r_i) & !mi(cb_r_i) & !mi(ctc_r_i) & !mi(pc_r_i)
replace r10iwelf = .t if (r10iwelf > 100000 & !missing(r10iwelf))
label variable r10iwelf "r10iwelf:w10 income: r income support"

// worker's comp
gen r10iwcmp = .
replace r10iwcmp = .m if mi(ssp_r_i) 
replace r10iwcmp = ssp_r_i*52 if !mi(ssp_r_i)
label variable r10iwcmp "r10iwcmp:w10 income: r workers comp"

// unemployment transfers
gen r10iunem = .
replace r10iunem = .m if mi(jsa_r_i) 
replace r10iunem = jsa_r_i*52  if !mi(jsa_r_i)
replace r10iunem = .t if (r10iunem > 10000 & !missing(r10iunem))
label variable r10iunem "r10iunem:w10 income: r unemployment"

gen r10igxfr = .
replace r10igxfr = .m if r10ivet==.m | r10iwelf==.m | r10iwcmp==.m | r10iunem==.m
replace r10igxfr = .t if r10ivet==.t | r10iwelf==.t | r10iwcmp==.t | r10iunem==.t
replace r10igxfr = r10ivet + r10iwelf + r10iwcmp + r10iunem ///
		if !mi(r10ivet) & !mi(r10iwelf) & !mi(r10iwcmp) & !mi(r10iunem)
label variable r10igxfr "r10igxfr:w10 income: r other gov transfers"




** saving
gen h10atotf = save_bu_i+ cashisa_bu_i+ shisa_bu_i+ prbonds_bu_i+ nsav_bu_i+ shares_bu_i+ trusts_bu_i+ bonds_bu_i+ othsav_bu_i+ jntass_bu_i - ccard_bu_i - prdebt_bu_i - odebt_bu_i

gen r10saving = h10atotf if inlist(futype, 1, 2)
replace r10saving = h10atotf/2 if futype == 3
}


** house tenure: h10hownrnt
*wave 10 respondent whether own home
gen hobas1 = hobas

gen r10hownrnt = .

gen owner1= howh1 // whether person 1 is owner
recode owner1 (-9=.) (-8=.) (-1=.) (-4=.) (-3=.) (-2=.)
gen owner2= howh2 // whether person 2 is owner
recode owner2 (-9=.) (-8=.) (-1=.) (-4=.) (-3=.) (-2=.)
gen owner3= howh3 // whether person 3 is owner
recode owner3 (-9=.) (-8=.) (-1=.) (-4=.) (-3=.) (-2=.)
gen owner4= howh4 // whether person 4 is owner
recode owner4 (-9=.) (-8=.) (-1=.) (-4=.) (-3=.) (-2=.)
gen owner5= howh5 // whether person 5 is owner
recode owner5 (-9=.) (-8=.) (-1=.) (-4=.) (-3=.) (-2=.)
gen owner6= howh6 // whether person 6 is owner
recode owner6 (-9=.) (-8=.) (-1=.) (-4=.) (-3=.) (-2=.)
gen owner7= howh7 // whether person 7 is owner
recode owner7 (-9=.) (-8=.) (-1=.) (-4=.) (-3=.) (-2=.)
gen owner8= howh8 // whether person 8 is owner
recode owner8 (-9=.) (-8=.) (-1=.) (-4=.) (-3=.) (-2=.)
gen owner9= howh9 // whether person 9 is owner
recode owner9 (-9=.) (-8=.) (-1=.) (-4=.) (-3=.) (-2=.)
gen owner10= howh10 // whether person 10 is owner
recode owner10 (-9=.) (-8=.) (-1=.) (-4=.) (-3=.) (-2=.)
gen owner11= howh11 // whether person 11 is owner
recode owner11 (-9=.) (-8=.) (-1=.) (-4=.) (-3=.) (-2=.)
gen owner12= howh12 // whether person 12 is owner
recode owner12 (-9=.) (-8=.) (-1=.) (-4=.) (-3=.) (-2=.)
gen owner13= howh13 // whether person 13 is owner
recode owner13 (-9=.) (-8=.) (-1=.) (-4=.) (-3=.) (-2=.)
gen owner14= howh14 // whether person 14 is owner
recode owner14 (-9=.) (-8=.) (-1=.) (-4=.) (-3=.) (-2=.)
gen owner15= howh15 // whether person 15 is owner
recode owner15 (-9=.) (-8=.) (-1=.) (-4=.) (-3=.) (-2=.)
gen owner16= howh16 // whether person 16 is owner
recode owner16 (-9=.) (-8=.) (-1=.) (-4=.) (-3=.) (-2=.)


forvalues j = 1 / 16 {
        replace r10hownrnt = 1 if (inlist(hotenu,1,2,3) & !inlist(hobas`j',1,2, 3)) & owner`j'==1 & perid==`j' // *own it
        replace r10hownrnt = 2 if hotenu==4 | (inlist(hobas`j',1,2) & perid==`j') // *rent it
        replace r10hownrnt = 3 if hotenu==5 | (hobas`j'==3 & perid==`j') & !inlist(r10hownrnt,1,2) // *others
}

forvalues i = 1 / 9 {
    replace r10hownrnt = 3 if inlist(hotenu,1,2,3) & owner`i'==1 & cpid== `i' & r10hownrnt==.
}
label variable r10hownrnt "r10hownrnt:w10 whether r owns home"
label define homeown 1 "owned home" 2 "rented home" 3 "other arrangement"
label values r10hownrnt homeown

drop hobas1

*wave 10 spouse whether own home
capture program drop spouse
program define spouse
syntax varname, result(varname) wave(integer)
	replace `result' = .u if w`wave'spouse==0 & s`wave'idauniq==0
	replace `result' = .v if w`wave'spouse==1 & s`wave'idauniq==0
	bysort idahhw10: replace `result' = `varlist'[_n+1] if  `varlist'[_n+1] !=. 
	bysort idahhw10: replace `result' = `varlist'[_n-1] if  `varlist'[_n-1] !=.
end

gen w10spouse =1 if inlist(couple, 1,2 )
replace w10spouse = 0 if couple==3
gen s10hownrnt =.
spouse r10hownrnt, result(s10hownrnt) wave(10)
label variable s10hownrnt "s10hownrnt:w10 whether s owns home"
label values s10hownrnt homeown

*wave 10 household whether own home
gen h10hownrnt = .
replace h10hownrnt = min(r10hownrnt, s10hownrnt) if !mi(r10hownrnt) | !mi(s10hownrnt)
label variable h10hownrnt "h10hownrnt:w10 whether own home"
label values h10hownrnt homeown

*drop intermediate variables
drop owner? owner1?  


* work, labour market participation, occupational class, self-employed, hours of work, physical demand, occupational pension
gen r10lbrf_e=.
replace r10lbrf_e = .m if wpdes == 86
replace r10lbrf_e = .o if inlist(wpdes,95,85)
replace r10lbrf_e = 1 if wpdes == 2
replace r10lbrf_e = 2 if wpdes == 3
replace r10lbrf_e = 3 if wpdes == 4
replace r10lbrf_e = 4 if wpdes == 96
replace r10lbrf_e = 5 if wpdes == 1
replace r10lbrf_e = 6 if wpdes == 5
replace r10lbrf_e = 7 if wpdes == 6

label define lbrf_e ///
	.o ".o:Other" ///
   1 "1.employed" ///
   2 "2.self-employed" ///
   3 "3.unemployed" ///
   4 "4.partly ret" ///
   5 "5.retired" ///
   6 "6.disabled" ///
   7 "7.looking after home or family" ///
   .x ".x:Not in the labor force" ///
   .r ".r:Refuse" ///
	 .m ".m:Oth missing" ///
	 .d ".d:DK"
label values r10lbrf_e lbrf_e


* occupational clss
gen r10soc2000 = .
replace r10soc2000 = 1 if w10soc2000r==11
replace r10soc2000 = 2 if w10soc2000r==12
replace r10soc2000 = 3 if w10soc2000r==21
replace r10soc2000 = 4 if w10soc2000r==22
replace r10soc2000 = 5 if w10soc2000r==23
replace r10soc2000 = 6 if w10soc2000r==24
replace r10soc2000 = 7 if w10soc2000r==31
replace r10soc2000 = 8 if w10soc2000r==32
replace r10soc2000 = 9 if w10soc2000r==33
replace r10soc2000 = 10 if w10soc2000r==34
replace r10soc2000 = 11 if w10soc2000r==35
replace r10soc2000 = 12 if w10soc2000r==41
replace r10soc2000 = 13 if w10soc2000r==42
replace r10soc2000 = 14 if w10soc2000r==51
replace r10soc2000 = 15 if w10soc2000r==52
replace r10soc2000 = 16 if w10soc2000r==53
replace r10soc2000 = 17 if w10soc2000r==54
replace r10soc2000 = 18 if w10soc2000r==61
replace r10soc2000 = 19 if w10soc2000r==62
replace r10soc2000 = 20 if w10soc2000r==71
replace r10soc2000 = 21 if w10soc2000r==72
replace r10soc2000 = 22 if w10soc2000r==81
replace r10soc2000 = 23 if w10soc2000r==82
replace r10soc2000 = 24 if w10soc2000r==91
replace r10soc2000 = 25 if w10soc2000r==92

merge 1:1 idauniq using "${elsa}\gh_elsa_h.dta", keepusing (r9soc2000) gen(merge_h1)
drop if merge_h1==2
replace r10soc2000 = r9soc2000 if r10soc2000==. & r10work==1 & wpstj==1 & inrange(r9soc2000,1,25)
replace r10soc2000 = .w if r10work==0
label variable r10soc2000 "r10soc2000:w10 r cur job occup/2000 soc coding"
label values r10soc2000 r9soc2000

* working hours
gen r10jhours=.
replace r10jhours = .w if (wpactpw == 0 & wpactse == 0)
replace r10jhours = .p if askpx == 1
replace r10jhours = wphjob if inrange(wphjob,1,168) & wpes == 1
replace r10jhours = wphwrk if inrange(wphwrk,1,168) & wpes == 2
label variable r10jhours "r10jhours:w10 r Hours worked/week main job"

* job demand
gen r10jphysl=.
replace r10jphysl = .w if (wpactpw == 0 & wpactse == 0)
replace r10jphysl = .p if askpx == 1
replace r10jphysl =1 if wpjact == 1
replace r10jphysl =2 if wpjact == 2
replace r10jphysl =3 if wpjact == 3
replace r10jphysl =4 if wpjact == 4
label variable r10jphysl "r10jphysl:w10 r Level of phys effort required in cur job"


* receiving pension
* receive any pension from current job
gen r10jcpen = pp_occ if inrange(pp_occ,0,1)
replace r10jcpen = .w if pp_occ==0 & inlist(wpdes,1,4,5,6)

* financial respondent receives public pension
gen r10pubpen = .
replace r10pubpen = 0 if perid == iapid & ///
                        ((iaspen == 2 | (iaspen == 1 & iaspw == 2 )) & ///
                        iabenmwp != 1)                  
replace r10pubpen = 1 if perid == iapid & ///
                        ((iaspen == 1 & (inlist(iaspw,1,3) | iaask == 2)) | ///
                         iabenmwp == 1)
replace r10pubpen = 1 if perid != iapid & askpx==1 & ///
												(iaspen == 1 & inlist(iaspw,1,3) & iaask == 1) 
label variable r10pubpen "r10pubpen:w10 r receives public pension"
label values r10pubpen yesnopen

*wave 10 financial respondent's spouse receives public pension
gen s10pubpen = .
replace s10pubpen = 0 if perid == iapid & ///
                       (iaspen == 2 | (iaspen == 1 & iaspw == 1))
replace s10pubpen = 1 if perid == iapid & ///
                        (iaspen == 1 & inlist(iaspw,2,3)) 
label variable s10pubpen "s10pubpen:w10 s receives public pension"  
label values s10pubpen yesnopen

bysort idahhw10: replace r10pubpen = s10pubpen[_n-1] if perid[_n-1] == iapid & mi(r10pubpen)
bysort idahhw10: replace r10pubpen = s10pubpen[_n+1] if perid[_n+1] == iapid & mi(r10pubpen)


* enrolled in private pension 
gen r10pripen= .p if askpx==1
replace r10pripen = 0 if wpnpens == 0
replace r10pripen = 1 if wpnpens >0 & wpnpens<.
label variable r10pripen "Enrolled in private pension (receiving or not receiving)"


* non pension wealth
merge 1:1 idauniq using "$finance10", keepusing(nettotw_bu_s) nogen
gen r10hwealth = nettotw_bu_s



gen inw10 = 1


keep idauniq r10agey inw10 ragender raracem r10educ_e r*mstat r*age_cat r*shlt r*adltot6 r*iadltot2_e r*iadltot1_e h*hownrnt r*child r*livpar r*work r*liv10 r*workat r*workata r*workl65 r*workat70 r*workat70f r*gcare1m r*gcare1w r*gscare1w r*gccare1w r*gkcare1w r*grcare1w r*gpcare1w r*gcareinhh1w r*gcarehpw r*gcaresck h*hhres r*lbrf_e r*soc2000 r*jhours r*jphysl r*jcpen r*pripen r*pubpen r*ngc r*hwealth r*le85 r*disib r*gor r*cesd r*going r*psagf r*finan
 

save "${temp}\00_wave10.dta", replace


