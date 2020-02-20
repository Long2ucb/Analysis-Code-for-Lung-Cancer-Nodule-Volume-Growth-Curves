/********************************************
Program growth_pattern2.sas
Date: 05.30.2019
Author: L Ngo
Purpose: Analysis of growth pattern data for Alex Bankier -- looking specifically at rate of growth

Input:
Output:
Modification: 

Our questions to the data are as follows:
1) Is the growth of these cancers linear or exponential? Or are there subgroups that are better fitted by either a linear or an exponential model?
2) Does any of the following factors determine or influence the growth pattern?
    a) Age
    b) Sex
    c) Smoking status
    d) History of previous lung cancer
    e) Duration of follow-up
    f) Volume on first CT exam
    g) Volume on last CT exam
    h) CT morphology on first CT exam
    i) CT morphology on last CT exam
    j) Relative growth
    k) Histology
    l) Presence of solid or micropapillary component
    m) Presence of STAS
3) Is the growth of the solid component, if present, linear or exponential? Is there any impact on growth of this solid components of factors a) to m)?
4) Is the goodness of fit of the models related to the number of CT examinations or the duration of follow-up, i.e., do longer follow-up periods or more 
observations provide a more robust model?


ID								Identification number
AGE								Age in years
SEX								Sex; 1: man, 2: woman
SMOKING_STATUS					Smoking status; 0: never smoker, 1: former or current smoker
HX_LUNG_CANCER					History of previous lung cancer; 0: no, 1: yes
NB_OF_CTS						total number of CT examinations that are available per patient 
OVERALL_FOLLOWUP_TIME			overall follow-up time in days from the first to the last available CT examination
TIME_DAYS						time elapsed (in days) since the first CT for each individuable volume 
OVERALL_VOLUME_ON_CT			overall nodule volume (mm3) for the corresponding time
SOLID_COMPONENT_VOLUME_ON_CT	volume of the nodule's solid component (mm3) for the corresponding time
CT_MORPHOLOGY_FIRST_CT	CT 		morphology on first CT examination (1: ground glass nodule, 2: part solid nodule). This and the next column are necessary 
								because some nodules change in CT morphology from ground glass nodules to part solid solid nodules between examinations
CT_MORPHOLOGY_LAST_CT	CT 		morphology on last CT examination (1: ground glass nodule, 2: part solid nodule). This and the next column are necessary 
								because some nodules change in CT morphology from ground glass nodules to part solid solid nodules between examinations
OVERALL_VOLUME_ON_FIRST_CT		overall nodule volume (mm3) on the first CT examination
OVERALL_VOLUME_ON_LAST_CT		overall nodule volume (mm3) on the last CT examination
RELATIVE_GROWTH					relative growth of the overall nodule (percentage) from the first to the last available CT examination, expressed as percentage
HISTOLOGY						final histology; 1: adenocarcinoma (ACA) in situ, 2: lepedic predominant ACA , 3: minimally invasive ACA, 4: Invasive mucinous ACA, 5: invasive ACA
SOLID_OR_MICROPAPILLARY_COMP	Solid or micropapillary component on histology; 0: no, 1: yes
STAS							Histological tumor spread through airspaces; 0: no, 1: yes
	

--

Here are the additional analyses we talked about

1.	Use a logarithmic function to express the volume (as done in Mets and al, the paper we sent you)

2.	Study the effect of different parameters on growth rate for both the 
overall volume and the solid component volume (the later only for the 34 nodules with at least 3 solid 
component volumes that were included in the second analysis that you performed)
a.	Gender
b.	Age
c.	Smoking status
d.	History of lung cancer
e.	CT morphology on first CT
f.	Overall follow-up time
g.	Overall volume on first CT
h.	Overall volume on last CT
i.	Volume of the solid component on first CT (only for nodules with a solid component volume ? 0)
j.	Histology (for this analysis it makes sense to group 2,4 and 5 together as the “invasive group”,  1 being the in-situ group and 3 the minimally invasive group).
k.	Presence of STAS
l.	Presence of a solid or micropapillary component


I have also 2 additional question about our model

From my understanding, we have defined a quadratic function (that could be also called parabolic) to obtain the volume at a given time “t” that could be expressed like this

f(t) = intercept + at - bt2

Where t is time, a the estimate for the linear contribution, and b the estimate for the nonlinear contribution.

1.	This formula means that at a certain point, when “bt2” becomes superior to “at”, the volume decreases. 
However, it is not what we see when examining the growth curves, and the decrease is unlikely from a clinical point of view. 
Is it due to the fact that the observation period is different for each nodule and that smaller nodules tend to have a longer observation time? 

2.	These data are not similar with what was found by Mets et al.  
They state in the article that they fitted linear, quadratic and exponential models to their longitudinal
data and they finally conclude that the growth pattern was best explained by an exponential model like this I suppose

f(t) = et

For me, it is indeed nonlinear (as our model) but it is still different from a quadratic model like the one we found.

Exponential versus quadratic makes a difference here because in clinical practice we use a parameter 
called “volume doubling time” to assess the probability of malignancy of a given nodule. 
The formula used to obtain the volume doubling time assumes the exponential growth of the nodule. 
The initial aim of the study was to figure out whether this assumption of an exponential growth was true in our cohort.



Age: 3 categories (based on the distribution)
•	<65
•	65 to 75
•	>75
Number of CTs: 2 categories (based on the distribution)
•	3 or 4
•	5, 6 or 7 
Follow-up duration: 2 categories (based on the distribution)
•	<20 months (605 days)
•	20 to 40 months ( 605 to 1210 days)
•	=40 months (1210 days)
Volume on 1st CT: 2 categories (based on the distribution and clinical recommendations)
•	<500 mm3
•	=500 mm3
Volume of the solid component on 1st CT (based on the threshold for invasiveness in pathology: 5mm, corresponding to a volume of 65mm3)
•	<65 mm3
•	=65 mm3



*********************************************/


*libname ab 'S:\General Medicine\common\Ngo & Quaden\Radiology Authorship'; 
*libname ab 'H:\alex_bankier'; 
libname ab 'H:\Constance DeMargerie'; 
options ls=80 ps=2000 nodate;


%macro conv(file,var1,var2); *file excel, sheet name, sas dataset name;
proc import
datafile="H:\alex_bankier\&file"
out=ab.&var2
dbms=xlsx    /*make sure this is same as excel file extension*/
replace;
sheet="&var1";
*DATAROW=2;
getnames=yes;
run;
%mend;
%conv(growth_pattern.xlsx,Data,growth_pattern);
%conv(solid_components.xlsx,sheet1,solid_components);

/*
proc contents data=ab.growth_pattern position;
run;

ID                          
AGE                         
SEX                         
SMOKING_STATUS              
HX_LUNG_CANCER              
NB_OF_CTS                   
OVERALL_FOLLOWUP_TIME       
TIME_DAYS                   
OVERALL_VOLUME_ON_CT        
SOLID_COMPONENT_VOLUME_ON_CT
CT_MORPHOLOGY_FIRST_CT      
CT_MORPHOLOGY_LAST_CT       
OVERALL_VOLUME_ON_FIRST_CT  
OVERALL_VOLUME_ON_LAST_CT   
RELATIVE_GROWTH             
HISTOLOGY                   
SOLID_OR_MICROPAPILLARY_COMP
STAS                        
*/

data a1;
   set ab.growth_pattern;
   *recode histology; 
   /*
   Histology (for this analysis it makes sense to group 2,4 and 5 together as the “invasive group”,  
   1 being the in-situ group and 3 the minimally invasive group).
   */

   /*
   if histology in (1)      then histology_group=1; else
   if histology in (3)      then histology_group=2; else
   if histology in (2,4,5)  then histology_group=3; 
   */

   if histology in (1,3)      then histology_group=1; else
   if histology in (2,4,5)  then histology_group=2; 


   label histology_group ='HISTOLOGY 1:In Situ/Min Inv 2: Invasive'; 

   *age;
   if . < age <= 65    then age_group=1; else
   if 65 < age <= 75   then age_group=2; else
   if 75 < age         then age_group=3; 

   label age_group='1:Age<65, 2:65-75, 3:<75';

   if NB_OF_CTS in (3,4)   then number_ct=1; else
   if NB_OF_CTS in (5,6,7) then number_ct=2; 

   label number_ct = '1:#CTs 3-4 2:#CTs 5-7'; 

   if . < OVERALL_FOLLOWUP_TIME <= 605     then total_followup_time=1; else
   if 605 < OVERALL_FOLLOWUP_TIME <= 1210  then total_followup_time=2; else
   if 1210 < OVERALL_FOLLOWUP_TIME        then total_followup_time=3;

   label total_followup_time='1:Time<=605 days 2:605-1210 3:>1210';


   if . < OVERALL_VOLUME_ON_FIRST_CT < 500 then vol_firstct=1; else
   if 500 <= OVERALL_VOLUME_ON_FIRST_CT    then vol_firstct=2; 

   label vol_firstct='1:Vol 1st CT <500 2:>=500'; 

   if . < age <= 70    then age70_group=1; else
   if 70 < age    then age70_group=2;

run;






data solid1;
   set a1 (keep=id time_days SOLID_COMPONENT_VOLUME_ON_CT);
   if time_days=0;
   if SOLID_COMPONENT_VOLUME_ON_CT=0 then SOLID_COMPONENT_VOLUME_ON_CT=.; 
   if 0 < SOLID_COMPONENT_VOLUME_ON_CT < 65 then solid_component_first=1; else
   if SOLID_COMPONENT_VOLUME_ON_CT >=65     then solid_component_first=2;

   label solid_component_first='1:Solid Vol<65 2:>=65'; 
   keep id solid_component_first; 
run;

data a1;
   merge a1
         solid1;
   by id;
run;


data ab.all_tumors1;
   set a1;
   by id;
   retain visit 1;
   if first.id then visit=1; else visit=visit+1;
   time_days2=time_days**2; 
   log_volume = log(OVERALL_VOLUME_ON_CT); 
   label log_volume = 'log(Overall_Volume)'; 
run;


proc freq data=ab.all_tumors1;
   tables histology_group age_group age70_group number_ct total_followup_time vol_firstct solid_component_first;
   where time_days=0; 
title 'Distribution of Grouped Variables';
run;


          



proc means data=ab.all_tumors1 maxdec=2 n mean std median p25 p50 p75;
   var log_volume;
run;

proc univariate normal plot data=ab.all_tumors1;
   var log_volume;
run;



%macro s0;
%do i=1 %to 74;
symbol&i v=circle c=black i=j l=1;
%end;
%mend;
%s0;

axis1 value=(h=1.5) label=(h=1.5 a=90 "Log OVERALL VOLUME (mm3)") minor=none;
axis2 value=(h=1.5) label=(h=1.5 a=0 "TIME (days)") minor=none;
proc gplot data=ab.all_tumors1;
  plot (log_volume) * TIME_DAYS = ID  / vaxis=axis1 haxis=axis2 nolegend;
  *where &mindays <= OVERALL_VOLUME_ON_CT <= &maxdays; 
  title1 h=1.5 "Log Growth Curves";
run;


*exponential model; 

proc mixed data=ab.all_tumors1;
   class id;
   model log_volume = TIME_DAYS / solution;
   random int / subject=id;
   title 'Model 1: Exponential Model with random intercept'; 
run;

*linear model; 

proc mixed data=ab.all_tumors1;
   class id;
   model OVERALL_VOLUME_ON_CT = TIME_DAYS / solution;
   random int / subject=id;
   title 'Model 2: Linear Model with random intercept'; 
run;

*quadratic model; 

proc mixed data=ab.all_tumors1;
   class id;
   model OVERALL_VOLUME_ON_CT = TIME_DAYS TIME_DAYS2/ solution;
   random int / subject=id;
   title 'Model 3: Quadratic Model with random intercept'; 
run;


%macro expoby(var,level1,level2);
proc mixed data=ab.all_tumors1;
   class id &var;
   model log_volume = TIME_DAYS TIME_DAYS*&var / solution;
   random int / subject=id;
   estimate "Rate for &var &level1:" time_days 1 time_days*&var 1 0;
   estimate "Rate for &var &level2:" time_days 1 time_days*&var 0 1;
   estimate "Rate &level1-&level2:" time_days*&var 1 -1; 
   title1 'Model 1: Exponential Model with random intercept'; 
   title2 "Comparing Rate of Change for Volume between &var"; 
run;
%mend; 



%macro expoby3(var,level1,level2,level3);
proc mixed data=ab.all_tumors1;
   class id &var;
   model log_volume = TIME_DAYS TIME_DAYS*&var / solution;
   random int / subject=id;
   estimate "Rate for &var &level1:" time_days 1 time_days*&var 1 0;
   estimate "Rate for &var &level2:" time_days 1 time_days*&var 0 1;
   estimate "Rate for &var &level3:" time_days 1 time_days*&var 0 0 1;
   estimate "Rate &level1-&level2:" time_days*&var 1 -1; 
   estimate "Rate &level1-&level3:" time_days*&var 1 0 -1; 
   estimate "Rate &level2-&level3:" time_days*&var 0 1 -1; 
   title1 'Model 1: Exponential Model with random intercept'; 
   title2 "Comparing Rate of Change for Volume between &var"; 
run;
%mend; 


%macro expobyc(var);
proc mixed data=ab.all_tumors1;
   class id;
   model log_volume = TIME_DAYS TIME_DAYS*&var / solution;
   random int / subject=id;
   estimate "Rate &var increased by 1:" time_days*&var 1; 
   title1 'Model 1: Exponential Model with random intercept'; 
   title2 "Comparing Rate of Change for Volume &var change by 1 unit"; 
run;
%mend; 

%expobyc(AGE);
%expoby(SEX,Male,Female);
%expoby(SMOKING_STATUS,Never,Former_Current);
%expoby(HX_LUNG_CANCER,No,Yes);
%expobyc(NB_OF_CTS);
*%expobyc(OVERALL_FOLLOWUP_TIME);
*%expobyc(SOLID_COMPONENT_VOLUME_ON_CT);
%expoby(CT_MORPHOLOGY_FIRST_CT,Ground_Glass_Module,Part_Solid_Module);
%expoby(CT_MORPHOLOGY_LAST_CT,Ground_Glass_Module,Part_Solid_Module);
%expobyc(OVERALL_VOLUME_ON_FIRST_CT);
%expobyc(OVERALL_VOLUME_ON_LAST_CT);
*%expobyc(RELATIVE_GROWTH);
%expoby(HISTOLOGY,Not_Invasive,Invasive);
%expoby(SOLID_OR_MICROPAPILLARY_COMP,No,Yes);
%expoby(STAS,No,Yes);


*with continuous variables converted to grouped variables; 

%expoby(HISTOLOGY_GROUP,In_Situ_Min_Invasive,Invasive); 
%expoby3(AGE_GROUP,Less_than_65,Between_65_75,Greater_75); 
%expoby(NUMBER_CT,3_or_4,5_6_7); 
%expoby3(TOTAL_FOLLOWUP_TIME,Less_20_months,Between_20_40_months,Greater_40_months); 
%expoby(VOL_FIRSTCT,Less_500_mm3,Greater_500_mm3); 
%expoby(SOLID_COMPONENT_FIRST,Less_65_mm3,Greater_65_mm3); 



%expoby(AGE70_GROUP,Less_than_70,Greater_70); 

proc freq data=ab.all_tumors1;
   tables CT_MORPHOLOGY_FIRST_CT;
run;





proc mixed data=ab.all_tumors1;
   class id;
   model log_volume = TIME_DAYS age sex/ solution;
   random int / subject=id;  
   where CT_MORPHOLOGY_FIRST_CT=1; 
run;

proc mixed data=ab.all_tumors1;
   class id;
   model log_volume = TIME_DAYS age sex/ solution;
   random int / subject=id;  
   where CT_MORPHOLOGY_FIRST_CT=2; 
run;




