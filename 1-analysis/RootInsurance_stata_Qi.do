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

*--> generate click variables 

	gen click_nobuy = 1 if click_true == 1 & policies_sold == 0 
	replace click_nobuy = 0 if click_nobuy == .
	gen click_buy = 2 if click_true == 1 & policies_sold == 1 
	replace click_buy = 0 if click_buy == .
	gen noclick_nobuy = 3 if click_true == 0 & policies_sold == 0 
	replace noclick_nobuy = 0 if noclick_nobuy == .
	
	gen class1 = click_nobuy + click_buy + noclick_nobuy
	
	replace click_buy = 1 if click_buy == 2
	replace noclick_nobuy = 1 if noclick_nobuy == 3
	
*--> generate click * rank variables

	local click "click_nobuy click_buy	noclick_nobuy"
	local k = 0 
	foreach i of varlist `click'{
		forval j = 1/5{    // di: display
			gen `i'_r`j' =  5 * `k' + `j' if `i' == 1 & rank == `j'
			replace `i'_r`j' = 0 if `i'_r`j' == .
		}
		local k = `k' + 1 
	}

	local click "*_r*"
	gen class2 = 0
	foreach i of varlist `click'{
		replace class2 = class2 + `i'
	}
	
	
*===============================================================================
*-> 2. Descriptive statistics
*===============================================================================

*--> 2.1 
	
		
			
	
*--> 2.2 Across click_nobuy, click_buy and noclick_nobuy
		
	local x "rank insured_N insured_Y insured_Un married single numberofvehicles numberofdrivers"	
	local k = 1
	foreach i of varlist `x'{
		tabstat `i', save ///
			by(class1) stat(mean p50 sd min max) format(%6.3f)
			tabstatmat A`k'
			mat list A`k', format(%6.3f)		
			local k = `k' + 1
	}
		
			
*--> 2.3 Across click_nobuy, click_buy and noclick_nobuy
	local x "rank insured_N insured_Y insured_Un married single numberofvehicles numberofdrivers"	
	local k = 1
	foreach i of varlist `x'{
		tabstat `i', save ///
			by(class2) stat(mean p50 sd min max) format(%6.3f)
			tabstatmat B`k'
			mat list B`k', format(%6.3f)		
			local k = `k' + 1
	}
		
	
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
		  
