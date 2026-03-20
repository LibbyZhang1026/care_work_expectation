* =================================
* 02_Data cleaning ELSA wave 11
* =================================
* Author: Jingwen Zhang
* Version 1:
* Date: 19/12/2025
* Aim: Clean future work expectation and work characteristics



clear all
set more off
set maxvar 15000
use "$elsa11", clear

* Identifier
gen hhid = idahhw11*10 + perid
gen hhsid = idahhw11*10 + cpid
vlookup hhsid, generate(s11idauniq) key(hhid) value(idauniq)

*********************
**# Socio-demogrpahic *
*********************

* gender
gen ragender = indsex

* age 
gen r11agey=.
replace r11agey = indager if inrange(indager,10,90)
replace r11agey = 90 if indager==-7

* age categories
recode indager (16/54 = 1 "<=54") (55/59 = 2 "55-59") (60/64 =3 "60-64") (65/69 =4 "65-69") (70/90 -7 = 5 ">=70"), gen(r11age_cat)


* education
gen edqual = 1 if fqquadeg==1 | fqquanv5==1 | fqquanv4==1
replace edqual = 2 if (fqquatea==1 | fqquanur==1 | fqquahnc==1 | fqquacgf==1) & edqual==.
replace edqual = 3 if (fqquaonc==1 | fqquacga==1 | fqquaale==1 | fqquaasl==1 | fqquaslc==1 | fqquanv3==1) & edqual==.
replace edqual = 4 if (fqquacgo==1 | fqquaolp==1 | fqquaola==1 | fqquagca==1 | fqquacs1==1 | fqquasll==1 | fqquamat==1 | fqquanv2==1) & edqual==.
replace edqual = 5 if (fqquaold==1 | fqquagcd==1 | fqquacs2==1 | fqquasup==1 | fqquanv1==1| fqquatra==1) & edqual==.
replace edqual = 6 if (fqquacsu==1 | fqquacle==1 | fqqua95==1) & edqual==.
replace edqual = 7 if fqaqua==2


gen r11educ_e =.
replace r11educ_e = -15 if edqual == 6
replace r11educ_e = 1 if inlist(edqual,7,5)
replace r11educ_e = 3 if edqual == 4
replace r11educ_e = 4 if inlist(edqual, 2, 3)
replace r11educ_e = 5 if edqual == 1
label variable r11educ_e "r11educ_e: r education (categ)"


* race
gen r11racem=4 if fqethnmr==2
replace r11racem=1 if fqethnmr==1
// this needs to be imputed after merging with wave 10

* marital status
gen r11mstat=.
replace r11mstat = 1 if inlist(dimarr,2,3)
replace r11mstat = 4 if dimarr==4
replace r11mstat = 5 if dimarr==5
replace r11mstat = 7 if dimarr==6
replace r11mstat = 8 if dimarr == 1
replace r11mstat = 3 if (inlist(dimarr,1,5,6)) & couple==2
label variable r11mstat "r11mstat:w11 r marital status w/partners, filled"


* number of people in the household
gen h11hhres= hhtot


* living children: r10child
egen nchinhh=anycount(dhr*), values(8,9,10,11)
egen nchouthh= anycount(dhcs*), values(1,2)
gen r11child=nchinhh+nchouthh



* living parent: r10livpar
merge 1:1 idauniq using "${elsa}\wave_10_ifs_derived_variables.dta", keepusing(falive malive) gen(ifs10)
drop if ifs10==2
gen malive11=dinma
gen falive11=dinfa
replace malive11= 2 if malive==2 & dinma<0
replace falive11= 2 if falive==2 & dinfa<0
replace malive11= 1 if mainhh==1
replace falive11= 1 if painhh==1
egen r11livpar = anycount(malive11 falive11), values(1)
replace r11livpar = . if malive11<0 & falive11<0


*Nation
//gor

* respondent Live in Nursing home 
gen r11nhmliv = .
replace r11nhmliv = 0 if inlist(w11indout,11,13,21,23)
replace r11nhmliv = 1 if inlist(w11indout,24,25)
label variable r11nhmliv "r11nhmliv:w11 R Lives in institution at interview"



*********************
**# work expectations *
*********************

* wave 11 respondent probability of living to 75-120 
gen r11liv10 = .
replace r11liv10 = .m if exlo80 == -1
replace r11liv10 = .d if exlo80 == -8
replace r11liv10 = .r if exlo80 == -9
replace r11liv10 = .p if exlo80 == -1 & askpx == 1
replace r11liv10 = exlo80 if inrange(exlo80,0,100)
label variable r11liv10 "r11liv10:w11 R probability of living to 75-120"


* wave 11 respondent age used in live 75-120
gen r11liv10a = .
replace r11liv10a = 75 if indager > 0 & indager <= 65
replace r11liv10a = 80 if indager > 65 & indager <= 69
replace r11liv10a = 85 if indager > 69 & indager <= 74
replace r11liv10a = 90 if indager > 74 & indager <= 79
replace r11liv10a = 95 if indager > 79 & indager <= 84
replace r11liv10a = 100 if indager > 84 & indager <= 99
replace r11liv10a = 105 if indager > 99 & indager <= 104
replace r11liv10a = 110 if indager > 104 & indager <= 109
replace r11liv10a = 120 if indager > 109 & indager <= 119
label variable r11liv10a "r11liv10a:w10 R age used in live 75-120"


* subjective life expectancy of people aged < 70: probability of age 85
gen r11le85 = exlo90 if exlo90>=0
replace r11le85 = 0 if exlo80==0 & r11agey<70
// missing: 117 don't know or refuse; 275 proxy

* wave 11 respondent probability of working after age
gen r11workat = .
replace r11workat = .m if expw == -1
replace r11workat = .d if expw == -8
replace r11workat = .r if expw == -9
replace r11workat = .p if expw == -1 & askpx == 1
replace r11workat = .i if indager >= 65
replace r11workat = expw if inrange(expw,0,100)
label variable r11workat "r11workat:w11 R probability of working after age"


* wave 11 respondent age used in probability of working 
gen r11workata = .
replace r11workata = .i if indager >= 65
replace r11workata = 60 if indager > 0 & indager <= 59
replace r11workata = 65 if indager >59 & indager <= 64
label variable r11workata "r11workata:w11 R age used in probability of working"


* work full-time after age
gen r11workatf = .m if  expwf == -1
replace r11workatf = .d if expwf == -8
replace r11workatf = .p if expwf == -1 & askpx == 1
replace r11workatf = .a if indager >= 65
replace r11workatf = .i if expwf == -1 & r11workat ==0
replace r11workatf = expwf if inrange(expwf,0,100)
label variable r11workatf "r11workatf:w11 R probability of working full time after age"

* work after 70

gen r11workat70= .m if   expw70 == -1
replace r11workat70 = .d if expw70 == -8
replace r11workat70 = .r if expw70 == -9
replace r11workat70 = .p if expw70 == -1 & askpx == 1
replace r11workat70 = expw70 if inrange(expw70,0,100) 
replace r11workat70 = .a if indager >= 70
replace r11workat70 = .i if expw70 == -1 & r11workat ==0

//replace r11workat70 = 0 if indager<65 & r11workat==0


* work after 70 full time

gen r11workat70f= .m if   expw70f == -1
replace r11workat70f = .d if expw70f == -8
replace r11workat70f = .r if expw70f == -9
replace r11workat70f = .p if expw70f == -1 & askpx == 1
replace r11workat70f = expw70f if inrange(expw70f,0,100) 
replace r11workat70f = .i if expw70f == -1 & r11workat70 ==0
replace r11workat70f = .i if expw70f == -1 & r11workat ==0
replace r11workat70f = .a if indager >= 70
//replace r11workat70 = 0 if indager<65 & r11workat==0

*wave 11 respondent work limit health problem before age 65
gen r11workl65 = .
replace r11workl65 = .m if exhlim == -1 
replace r11workl65 = .d if exhlim == -8
replace r11workl65 = .r if exhlim == -9
replace r11workl65 = .p if exhlim == -1 & askpx == 1
replace r11workl65 = .w if exhlim == -1 & (wpactpw ~= 1 & wpactse ~= 1 & wpaway ~= 1) // the respondents should be in paid work, self-employment, or temporarily away from paid work
replace r11workl65 = .i if exhlim == -1 & indager > 65
replace r11workl65 = exhlim if inrange(exhlim,0,100) 
label variable r11workl65 "r11workl65:w11 R probability of work limiting health problem"


* future financial concern
gen r11finan= exrslf if exrslf>=0


*******************
**# care provision *
*******************

*wave 11 respondent provided any informal care last month
gen r11gcare1m = .
replace r11gcare1m = 0 if wpactca==0 | wpact96==1
replace r11gcare1m = 1 if wpactca==1
label variable r11gcare1m "r11gcare1m:w11 r provided any informal care last month"
label values r11gcare1m yesnocare

*wave 11 respondent provided any informal care last week
gen r11gcare1w = .
replace r11gcare1w = .i if ercaa== -1
replace r11gcare1w = .n if askinst==1
replace r11gcare1w = .p if askpx==1
replace r11gcare1w = .r if ercaa== -9
replace r11gcare1w = .d if ercaa== -8

replace r11gcare1w = 0 if ercaa==2 
replace r11gcare1w = 1 if ercaa==1 
label variable r11gcare1w "r11gcare1w:w11 r provided any informal care last week"
label values r11gcare1w yesnocare

*wave 11 respondent give care to long-term sick/disabled
gen r11gcaresck = .
replace r11gcaresck = . if inlist(erresck, -9, -8, -1)
replace r11gcaresck = .n if askinst==1
replace r11gcaresck = .p if askpx==1
replace r11gcaresck = 0 if erresck==2 
replace r11gcaresck = 1 if erresck==1
label variable r11gcaresck "r11gcaresck:w11 r provides informal care to long-term sick/disabled person"
label values r11gcaresck yesnocare


* wave 11 respondent give care to spouse
gen r11gscare1w = .
replace r11gscare1w = 0 if inrange(r11mstat,4,8)
replace r11gscare1w = . if ercaa<0
replace r11gscare1w = .n if askinst==1
replace r11gscare1w = .p if askpx==1
replace r11gscare1w = 0 if inlist(r11mstat,1,3) & (ercaa==2)
replace r11gscare1w = 0 if inlist(r11mstat,1,3) & ercamsp==0
replace r11gscare1w = 1 if ercamsp==1
label variable r11gscare1w "r11gscare1w:w11 r provided informal care to spouse last week"
label values r11gscare1w yesnocare


*wave 11 respondent provided care to children last week
gen r11gccare1w = .
replace r11gccare1w = 0 if r11child==0
replace r11gccare1w = . if ercaa<0
replace r11gccare1w = .n if askinst==1
replace r11gccare1w = .p if askpx==1
replace r11gccare1w = 0 if r11child!=0 & (ercaa==2)
replace r11gccare1w = 0 if r11child!=0 & ercamch==0
replace r11gccare1w = 1 if ercamch==1
label variable r11gccare1w "r11gccare1w:w11 r provided informal care to children last week"
label values r11gccare1w yesnocare


*wave 11 respondent provided care to grandchildren last week

gen r11gkcare1w = .
replace r11gkcare1w = 0 if dignmy==0 | dignmy==-1
replace r11gkcare1w = . if ercaa<0
replace r11gkcare1w = .n if askinst==1
replace r11gkcare1w = .p if askpx==1
replace r11gkcare1w = 0 if dignmy>0 & (ercaa==2)
replace r11gkcare1w = 0 if dignmy>0 & ercamgc==0 
replace r11gkcare1w = 1 if ercamgc==1
label variable r11gkcare1w "r11gkcare1w:w11 r provided informal care to grandchildren last week"
label values r11gkcare1w yesnocare
rename dignmy r11ngc


*wave 11 respondent provided care to parents last week
gen r11gpcare1w = .
replace r11gpcare1w = .n if askinst==1
replace r11gpcare1w = 0 if falive==2 & malive==2
replace r11gpcare1w = . if ercaa<0
replace r11gpcare1w = .p if askpx==1
replace r11gpcare1w = 0 if ercaa==2
replace r11gpcare1w = 0 if ercampa==0 
replace r11gpcare1w = 1 if ercampa==1 
label variable r11gpcare1w "r11gpcare1w:w11 r provided informal care to own parents last week"
label values r11gpcare1w yesnocare


*wave 11 respondent provided care to other relatives last week  
gen r11grcare1w = .
replace r11grcare1w = .n if askinst==1
replace r11grcare1w = .p if askpx==1
replace r11grcare1w = 0 if ercaa==2
replace r11grcare1w = 0 if ercampl==0 | ercamor==0 
replace r11grcare1w = 1 if ercampl==1 | ercamor==1
label variable r11grcare1w "r11grcare1w:w11 r provided informal care to relatives last week"
label values r11grcare1w yesnocare


*wave 11 respondent provided care to someone in hh last week
gen r11gcareinhh1w = .
replace r11gcareinhh1w = .n if askinst==1
replace r11gcareinhh1w = .p if askpx==1
replace r11gcareinhh1w = 0 if ercaa==2
replace r11gcareinhh1w = 0 if ercalive==2
replace r11gcareinhh1w = 1 if ercalive==1
label variable r11gcareinhh1w "r11gcareinhh1w:w11 r provided care to someone in hhold last week"
label values r11gcareinhh1w yesnocare

* wave 11 respondent hours per week provided care
gen r11gcarehpw = .
replace r11gcarehpw = .n if askinst==1
replace r11gcarehpw = .p if askpx==1
replace r11gcarehpw = 0 if ercaa==2
replace r11gcarehpw = ercac if inrange(ercac,0,168)
label variable r11gcarehpw "r11gcarehpw:w11 # hours r provided care last week"


***********
**# Health *
***********

** ADL IADL Mobility **
* ADL
gen r11walkra = headlwa if headlwa>=0
gen r11dressa = headldr if headldr>=0
gen r11batha = headlba if headlba>=0
gen r11eata = headlea if headlea>=0
gen r11beda = headlbe if headlbe>=0
gen r11toilta = headlwc if headlwc>=0
egen r11adltot6a = anymatch(r11walkra r11dressa r11batha r11eata r11beda r11toilta), values(1)
replace r11adltot6a = . if r11walkra==.
egen r11adltot6 = anycount(r11walkra r11dressa r11batha r11eata r11beda r11toilta), values(1)
replace r11adltot6 = . if r11walkra==.

* IADL 
gen r11moneya = headlmo if headlmo>=0
gen r11medsa = headlme if headlme>=0
gen r11shopa = headlsh if headlsh>=0
gen r11housewka = headlho if headlho>=0
gen r11communa = headlsp if headlsp>=0
gen r11phonea =  headlph if headlph>=0
gen r11mealsa = headlea if headlea>=0
gen r11dangera = headlda if headlda>=0
egen r11iadltot2_e= anycount(headlma headlda headlpr headlsh headlph ///
 headlsp headlme headlho headlmo), values(1)
replace r11iadltot2_e=. if headl96<0
egen r11iadltot2a_e= anymatch(headlma headlda headlpr headlsh headlph ///
 headlsp headlme headlho headlmo), values(1)
replace r11iadltot2a_e=. if headl96<0

egen r11iadltot1_e= anycount(headlph headlmo headlme headlsp headlpr headlma headlho), values(1)
replace r11iadltot1_e=. if headl96<0



*Self rated Health
clonevar r11shlt = hehelf
replace r11shlt=.d if hehelf==-8
replace r11shlt=.p if hehelf==-1


* mental health
gen cesda = 2- psceda if psceda>=0
gen cesdb = 2- pscedb if pscedb>=0
gen cesdc = 2- pscedc if pscedc>=0
gen cesdd = pscedd-1 if pscedd>=0
gen cesde = 2- pscede if pscede>=0
gen cesdf = pscedf-1 if pscedf>=0
gen cesdg = 2- pscedg if pscedg>=0
gen cesdh = 2- pscedh if pscedh>=0


egen r11cesd = rowtotal(cesda - cesdh), missing
rename cesdh r11going


*******************
**# economic status *
*******************

* work status 

gen r11work = 1 if wpactse==1 | wpactpw==1
replace r11work = 0 if wpactse==0 & wpactpw==0



** house tenure: h11hownrnt
*wave 11 respondent whether own home
gen hobas1 = hobas

gen r11hownrnt = .

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
        replace r11hownrnt = 1 if (inlist(hotenu,1,2,3) & !inlist(hobas`j',1,2, 3)) & owner`j'==1 & perid==`j' // *own it
        replace r11hownrnt = 2 if hotenu==4 | (inlist(hobas`j',1,2) & perid==`j') // *rent it
        replace r11hownrnt = 3 if hotenu==5 | (hobas`j'==3 & perid==`j') & !inlist(r11hownrnt,1,2) // *others
}

forvalues i = 1 / 7 {
    replace r11hownrnt = 3 if inlist(hotenu,1,2,3) & owner`i'==1 & cpid== `i' & r11hownrnt==.
}
label variable r11hownrnt "r11hownrnt:w11 whether r owns home"
label define homeown 1 "owned home" 2 "rented home" 3 "other arrangement"
label values r11hownrnt homeown

drop  hobas1

*wave 11 spouse whether own home
capture program drop spouse
program define spouse
syntax varname, result(varname) wave(integer)
	replace `result' = .u if w`wave'spouse==0 & s`wave'idauniq==0
	replace `result' = .v if w`wave'spouse==1 & s`wave'idauniq==0
	bysort idahhw11: replace `result' = `varlist'[_n+1] if  `varlist'[_n+1] !=. 
	bysort idahhw11: replace `result' = `varlist'[_n-1] if  `varlist'[_n-1] !=.
end

gen w11spouse =1 if inlist(couple, 1,2 )
replace w11spouse = 0 if couple==3
gen s11hownrnt =.
spouse r11hownrnt, result(s11hownrnt) wave(11)
label variable s11hownrnt "s11hownrnt:w11 whether s owns home"
label values s11hownrnt homeown

*wave 11 household whether own home
gen h11hownrnt = .
replace h11hownrnt = min(r11hownrnt, s11hownrnt) if !mi(r11hownrnt) | !mi(s11hownrnt)
label variable h11hownrnt "h11hownrnt:w11 whether own home"
label values h11hownrnt homeown

*drop intermediate variables
drop owner? owner1?  


* work, labour market participation, occupational class, self-employed, hours of work, physical demand, occupational pension
gen r11lbrf_e=.
replace r11lbrf_e = .m if wpdes == 86
replace r11lbrf_e = .o if inlist(wpdes,95,85)
replace r11lbrf_e = 1 if wpdes == 2
replace r11lbrf_e = 2 if wpdes == 3
replace r11lbrf_e = 3 if wpdes == 4
replace r11lbrf_e = 4 if wpdes == 96
replace r11lbrf_e = 5 if wpdes == 1
replace r11lbrf_e = 6 if wpdes == 5
replace r11lbrf_e = 7 if wpdes == 6

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
label values r11lbrf_e lbrf_e


* occupational clss
gen r11soc2000 = .
replace r11soc2000 = 1 if w11soc2000r==11
replace r11soc2000 = 2 if w11soc2000r==12
replace r11soc2000 = 3 if w11soc2000r==21
replace r11soc2000 = 4 if w11soc2000r==22
replace r11soc2000 = 5 if w11soc2000r==23
replace r11soc2000 = 6 if w11soc2000r==24
replace r11soc2000 = 7 if w11soc2000r==31
replace r11soc2000 = 8 if w11soc2000r==32
replace r11soc2000 = 9 if w11soc2000r==33
replace r11soc2000 = 10 if w11soc2000r==34
replace r11soc2000 = 11 if w11soc2000r==35
replace r11soc2000 = 12 if w11soc2000r==41
replace r11soc2000 = 13 if w11soc2000r==42
replace r11soc2000 = 14 if w11soc2000r==51
replace r11soc2000 = 15 if w11soc2000r==52
replace r11soc2000 = 16 if w11soc2000r==53
replace r11soc2000 = 17 if w11soc2000r==54
replace r11soc2000 = 18 if w11soc2000r==61
replace r11soc2000 = 19 if w11soc2000r==62
replace r11soc2000 = 20 if w11soc2000r==71
replace r11soc2000 = 21 if w11soc2000r==72
replace r11soc2000 = 22 if w11soc2000r==81
replace r11soc2000 = 23 if w11soc2000r==82
replace r11soc2000 = 24 if w11soc2000r==91
replace r11soc2000 = 25 if w11soc2000r==92

merge 1:1 idauniq using "${temp}\00_wave10.dta", keepusing (r10soc2000) gen(merge_w10)
drop if merge_w10==2
replace r11soc2000 = r10soc2000 if r11soc2000==. & r11work==1 & wpstj==1 & inrange(r10soc2000,1,25)
replace r11soc2000 = .w if r11work==0
label variable r11soc2000 "r11soc2000:w11 r cur job occup/2000 soc coding"
label values r11soc2000 r9soc2000

* working hours
gen r11jhours=.
replace r11jhours = .w if (wpactpw == 0 & wpactse == 0)
replace r11jhours = .p if askpx == 1
replace r11jhours = wphjob if inrange(wphjob,1,168) & wpes == 1
replace r11jhours = wphwrk if inrange(wphwrk,1,168) & wpes == 2
label variable r11jhours "r11jhours:w11 r Hours worked/week main job"

* job demand
gen r11jphysl=.
replace r11jphysl = .w if (wpactpw == 0 & wpactse == 0)
replace r11jphysl = .p if askpx == 1
replace r11jphysl =1 if wpjact == 1
replace r11jphysl =2 if wpjact == 2
replace r11jphysl =3 if wpjact == 3
replace r11jphysl =4 if wpjact == 4
label variable r11jphysl "r11jphysl:w11 r Level of phys effort required in cur job"



* receiving pension

*wave 11 financial respondent receives public pension
gen r11pubpen = .
replace r11pubpen = 0 if perid == iapid & ///
                        ((iaspen == 2 | (iaspen == 1 & iaspw == 2 )) & ///
                        iabenmwp != 1)                  
replace r11pubpen = 1 if perid == iapid & ///
                        ((iaspen == 1 & (inlist(iaspw,1,3) | iaask == 2)) | ///
                         iabenmwp == 1)
replace r11pubpen = 1 if perid != iapid & askpx==1 & ///
												(iaspen == 1 & inlist(iaspw,1,3) & iaask == 1) 
label variable r11pubpen "r11pubpen:w11 r receives public pension"
label values r11pubpen yesnopen

*wave 11 financial respondent's spouse receives public pension
gen s11pubpen = .
replace s11pubpen = 0 if perid == iapid & ///
                       (iaspen == 2 | (iaspen == 1 & iaspw == 1))
replace s11pubpen = 1 if perid == iapid & ///
                        (iaspen == 1 & inlist(iaspw,2,3)) 
label variable s11pubpen "s11pubpen:w11 s receives public pension"  
label values s11pubpen yesnopen

bysort idahhw11: replace r11pubpen = s11pubpen[_n-1] if perid[_n-1] == iapid & mi(r11pubpen)
bysort idahhw11: replace r11pubpen = s11pubpen[_n+1] if perid[_n+1] == iapid & mi(r11pubpen)


* enrolled in private pension 
gen r11pripen= .p if askpx==1
replace r11pripen = 0 if wpnpens == 0
replace r11pripen = 1 if wpnpens >0 & wpnpens<.
label variable r11pripen "Enrolled in private pension (receiving or not receiving)"


* non pension wealth
merge 1:1 idauniq using "$finance11", keepusing(nettotw_bu_s) nogen
gen r11hwealth = nettotw_bu_s



renvars disib gor , prefix(r11)


gen inw11 = 1


keep idauniq r*agey inw* ragender r11racem r11educ_e r*mstat r*age_cat r*shlt r*adltot6 r*iadltot2_e r*iadltot1_e h*hownrnt r*child r*livpar r*work r*liv10 r*workat r*workata r*workl65  r*workat70 r*workat70f  r*gcare1m r*gcare1w r*gscare1w r*gccare1w r*gkcare1w r*grcare1w r*gpcare1w r*gcareinhh1w r*gcarehpw r*gcaresck h*hhres r*lbrf_e r*soc2000 r*jhours r*jphysl r*pripen r*pubpen r*ngc r*hwealth r*le85  r*disib r*gor r*cesd r*going r*finan

save "${temp}\00_wave11.dta", replace