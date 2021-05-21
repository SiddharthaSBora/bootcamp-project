*       -----------------------------------------      *
*       -----------------------------------------      *
*                                                      *
*             Root Insurance Data Camp Project         * 
*                    Qi Jiang(jiang.1885)              *
*                         AEDE                         *
*               The Ohio State University              *
*                      05/21/2021                      *
*       -----------------------------------------      *
*       -----------------------------------------      *

* Settings
    clear all 
    cd "/Users/qi/Desktop/Python/DataCamp/Project/bootcamp-project/0-data"  // define the path
	
* import 
	import delimited "Root_Insurance_data.csv", clear
	
*===============================================================================
*-> 1. Data cleaning   
*===============================================================================

	tabulate currentlyinsured, gen(insured)
	
	rename insured1 insured_N
	rename insured2 insured_Y
	rename insured3 insured_Un
	
	tabulate maritalstatus, gen(married)
	rename married1 married
	rename married2 single
	
	tabulate click, gen(c)
	rename c1 click_false
	rename c2 click_true
	
	encode currentlyinsured, gen(insured)
	encode maritalstatus, gen(marrystatus)
	encode click, gen(click_t)
	
	drop currentlyinsured maritalstatus click
	
	rename click_t click 
	
	order click click_true click_false policies_sold ///
		  insured insured_N insured_Y insured_Un ///
		  marrystatus married single ///
		  numberofvehicles numberofdrivers ///
		  rank bid
	
	
*===============================================================================
*-> 2. Descriptive statistics
*===============================================================================
	
	sum _all
	pwcorr _all
	
	tabulate click_true rank 
	
*===============================================================================
*-> 3. Logit regression
*===============================================================================

*--> 3.1 click 
*--> 3.1.1 click without interactions
	logit click_true rank ///
		  b3.insured numberofvehicles numberofdrivers b2.marrystatus 
	
*--> 3.1.2 click with interactions
	logit click_true rank ///
	      b3.insured##rank c.numberofvehicles##rank ///
	      c.numberofdrivers##rank b2.marrystatus##rank

	logit click_true rank ///
	      b3.insured##rank numberofvehicles##rank ///
	      numberofdrivers##rank b2.marrystatus##rank
		  
		  
*--> 3.2 policies_sold 
*--> 3.2.1 policies_sold without interactions
	logit policies_sold rank ///
		  b3.insured numberofvehicles numberofdrivers b2.marrystatus 

*--> 3.2.2 policies_sold with interactions
	logit policies_sold rank ///
	      b3.insured##rank c.numberofvehicles##rank ///
	      c.numberofdrivers##rank b2.marrystatus##rank
		  
	logit policies_sold rank ///
	      b3.insured##rank numberofvehicles##rank ///
	      numberofdrivers##rank b2.marrystatus##rank
		  
