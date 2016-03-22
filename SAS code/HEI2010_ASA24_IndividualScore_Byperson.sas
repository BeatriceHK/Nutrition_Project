*******************************************************************************
*The SAS program (HEI2010_ASA24_IndividualScore_Byperson.sas):		      *
*									      *
*This SAS program can be used to calculate Healthy Eating Index (HEI)-2010    *
*scores from 24-hour recall data collected using ASA24-2011, ASA24-Kids-2013, *
*ASA24-2014 and ASA24-Kids-2014. This program calculates HEI-2010 component   *
*and total scores for each individual (using multiple ASA24 recalls, if	      *
*available, for a single respondent).					      *
*									      *
*This program has been tested using SAS, version 9.2 and uses the INFMYPHEI   *
*and TNMYPHEI analysis files from ASA24.  These files can be downloaded from  *
*the Researcher Web site. If any changes are made to the INFMYPHEI analysis   *
*file during data cleaning, please recreate an updated TNMYPHEI file prior    *
*to running this code. The files should be in CSV format.		      *
*				      *					      *
*									      *
*Please see accompanying readme file.   				      *
*******************************************************************************;

/* Filenames for the input datasets.*/

filename inf4 'C:/INFMYPHEI.xls'; /*Individual Foods and MyPyramid Equivalents Excel file from ASA24*/
filename tn4 'C:/TNMYPHEI.xls'; /*Total Foods and MyPyramid Equivalents Excel file from ASA24*/

/*Name and location of the output file to be exported, containing HEI-2010 component and total scores for each intake day*/

filename res 'C:/hei2010.individual.result.csv';


/*Read in required macros*/

%include 'C:/hei2010.beanspeas.allocation.macro.doc.sas';
%include 'C:/hei2010.score.macro.doc.sas';

TITLE 'ASA24 HEI-2010 scores - by person using all days';

/*Step 1. 
 Moves soy beverages out of Soybean Products (M_SOY) and into Dairy (D_TOTAL).
  This uses the ASA24 INFMYPHEI output file.  The adjusted totals are generated for
  each day of dietary intake and saved in a temporary SAS dataset.
 */

*Input the food data;
proc import datafile=inf4
  out=inf4
  dbms=xls
  replace;
  getnames=yes;
run;

data food;
  set inf4;

  *move soy milk from soy to dairy;
  /*FOODCODE=11310000, MILK, IMITATION, FLUID, SOY BASED (1 cup=244 grams)
    FOODCODE=11320000, MILK, SOY, READY-TO-DRINK, NOT BABY (1 cup=245 grams)
    FOODCODE=11321000, MILK, SOY, READY-TO-DRINK, NOT BABY'S, CHOCOLATE (1 cup=240 grams)
    FOODCODE=11330000, MILK, SOY, DRY, RECONSTITUTED, NOT BABY (1 cup=245 grams) */
  IF FOODCODE=11310000 THEN DO;
     M_SOY=0;
	 D_TOTAL=ROUND(FoodAmt/244,.001);
	 END;
  ELSE IF FOODCODE=11320000 THEN DO;
     M_SOY=0;
	 D_TOTAL=ROUND(FoodAmt/245,.001);
	 END;
  ELSE IF FOODCODE=11321000 THEN DO;
     M_SOY=0;
	 D_TOTAL=ROUND(FoodAmt/240,.001);
	 END;
  ELSE IF FOODCODE=11330000 THEN DO;
     M_SOY=0;
	 D_TOTAL=ROUND(FoodAmt/245,.001);
	 END;


run;

proc sort data=food;
  by username recallno;
run;

proc means data=food noprint;
  by username recallno;
  var d_total m_soy;
  output out=adjsum sum=d_total_adj m_soy_adj;
run;

/*Step 2. 
 Merges the TNMYPHEI file with the SAS dataset created in Step 1, creating a file with
  adjusted variables for the MPED variables of Total Milk (D_TOTAL_ADJ) and Soybean Products (M_SOY_ADJ).
*/ 

*Input the day total data;
proc import datafile=tn4
  out=tn4
  dbms=xls
  replace;
  getnames=yes;
run;

proc sort data=tn4;
  by username recallno;
  
data tn4a;
  merge tn4 adjsum;
  by username recallno;
run;

/*Step 3.
 Creates three additional required variables.  These variables are:  MONOPOLY, ALLMEAT, and SEAPLANT. 
*/


DATA tn4a;
  SET tn4a;
  by username recallno;

  MONOPOLY=mfat+pfat;

  ALLMEAT=M_MPF+M_EGG+M_NUTSD+m_soy_adj;
  SEAPLANT=M_FISH_HI+M_FISH_LO+m_soy_adj+M_NUTSD;

 /**Calculate intake of Calories from SoFAAS**/

      ADDSUGC=16*ADD_SUG;	/*calories from added sugars*/
      SOLFATC=DISCFAT_SOL*9;	/*calories from solid fat*/

                           
run; 

/*Step 4.
 Calculates total food group and nutrient intake over all possible days reported per individual.
*/

*get sum per person of variables of interest;
proc means data=tn4a noprint;
  by username;
  var KCAL allmeat seaplant v_total v_drkgr legumes f_total wholefrt g_whl d_total_adj
     monopoly sfat SODI G_NWHL ADDSUGC SOLFATC ALC;
  output out=persumtn4 sum=;
run;


/*Step 5.
 Creates the final required variable, EMPTYCAL10.
*/

DATA persumtn4;
  SET persumtn4;
  by username;


 /**Calculate intake of Calories from SoFAAS**/


      maxalcgr=13*(kcal/1000);  /*max grams of alcohol based on kcal intake*/

      if ALC <= maxalcgr then EXALCCAL=0;  /*consumed less than max*/
        else if ALC > maxalcgr then EXALCCAL=7*(ALC-maxalcgr);  /*get cal from extra alc grams*/

      EMPTYCAL10=ADDSUGC+SOLFATC+EXALCCAL; /*total empty calories in hei2010 definition*/
                           
run; 

/*Step 6.
 Runs the macro to properly allocate the intakes of the MPED variable Legumes (LEGUMES)
  to either Total Protein Foods and Seafood and Plant Proteins (ALLMEAT and SEAPLANT)
  or Total Vegetables and Greens and Beans (V_TOTAL and V_DRKGR).  The four resulting
  variables from this step, named LEGUME_ADDED_V_TOTAL, LEGUME_ADDED_BEANGRN,
  LEGUME_ADDED_ALLMEAT, and LEGUME_ADDED_SEAPLANT are all used in the next step. 
*/

%LEG2010A (indat=persumtn4,
           kcal=KCAL,
           allmeat=allmeat,
	   seaplant=seaplant,
	   v_total=v_total,
	   v_drkgr=v_drkgr,
	   legumes=legumes,
	   outdat=afterleg);

/*Step 7. 
 Runs the HEI2010 scoring macro which calculates intake density amounts and HEI scores.
*/

%HEI2010 (indat=afterleg,
          kcal=KCAL,
	  lv_total=legume_added_V_TOTAL,
	  lbeangrn=legume_added_BEANGRN,
	  f_total=f_total,
	  wholefrt=wholefrt
	  g_whl=g_whl,
	  d_total=d_total_adj,
          lallmeat=legume_added_ALLMEAT,
	  lseaplant=legume_added_SEAPLANT,
	  monopoly=monopoly,
	  sfat=sfat,
	  sodi=SODI,
	  G_NWHL=G_NWHL,
	  EMPTYCAL10=EMPTYCAL10,
	  outdat=hei2010);
 
run;

/*Step 8.
 Displays and saves the results.
*/ 


Data hei2010r (keep=username HEIX1_TOTALVEG HEIX2_GREEN_AND_BEAN HEIX3_TOTALFRUIT
     HEIX4_WHOLEFRUIT HEIX5_WHOLEGRAIN HEIX6_TOTALDAIRY HEIX7_TOTPROT HEIX8_SEAPLANT_PROT
     HEIX9_FATTYACID HEIX10_SODIUM HEIX11_REFINEDGRAIN HEIX12_SOFAAS
     HEI2010_TOTAL_SCORE);
  Set hei2010;
  Run;

proc means n nmiss min max mean data=hei2010r;
run;


proc export data= hei2010r
  file=res
  dbms=csv
  replace;
run;
