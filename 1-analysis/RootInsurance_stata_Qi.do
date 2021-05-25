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
	
	tabulate rank, gen(r)
	tabulate numberofvehicles, gen(vehicle)
	tabulate numberofdrivers, gen(driver)
	
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

*--> 2.1 check the variable's distribution
	local x "rank insured_N insured_Y insured_Un married single numberofvehicles numberofdrivers"
	foreach i of varlist `x'{
		tabulate `i' 
	}
			
	
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

*>>>>>
* this one treats rank, numberofvehicles, numberofdrivers as continuous variables
*>>>>>
	logit click_true rank ///
		  b3.insured numberofvehicles numberofdrivers b2.marrystatus 
*>>>>>		  
* this one treats rank as discrete while numberofvehicles, numberofdrivers as continuous variables
*>>>>>
	logit click_true b1.rank ///
		  b3.insured numberofvehicles numberofdrivers b2.marrystatus
*>>>>>		  
* this one treats rank as continuous while numberofvehicles, numberofdrivers as discrete variables
*>>>>>
	logit click_true rank ///
		  b3.insured b1.numberofvehicles b1.numberofdrivers b2.marrystatus 
*>>>>>	
* this one treats rank, numberofvehicles, numberofdrivers as discrete variables
*>>>>>
	logit click_true b1.rank ///
		  b3.insured b1.numberofvehicles b1.numberofdrivers b2.marrystatus 	  

		  	
*--> 3.1.2 click with interactions

*>>>>>
* this one treats rank, numberofvehicles, numberofdrivers as continuous variables
*>>>>>
	logit click_true c.rank ///
	      b3.insured##rank c.numberofvehicles##rank ///
	      c.numberofdrivers##rank b2.marrystatus##rank   

*>>>>>		  
* this one treats rank as discrete while numberofvehicles, numberofdrivers as continuous variables
*>>>>>
	logit click_true i.rank ///
	      b3.insured##rank c.numberofvehicles##rank ///
	      c.numberofdrivers##rank b2.marrystatus##rank

*>>>>>
* this one treats rank as continuous while numberofvehicles, numberofdrivers as discrete variables
*>>>>>
	logit click_true c.rank ///
	      b3.insured##c.rank i.numberofvehicles##c.rank ///
	      i.numberofdrivers##c.rank b2.marrystatus##c.rank   

*>>>>>
* this one treats rank, numberofvehicles, numberofdrivers as discrete variables
*>>>>>
	logit click_true i.rank ///
	      b3.insured##i.rank i.numberofvehicles##i.rank ///
	      i.numberofdrivers##i.rank b2.marrystatus##i.rank  
		  
*--> 3.2 policies_sold 
*--> 3.2.1 policies_sold without interactions

*>>>>>
* this one treats rank, numberofvehicles, numberofdrivers as continuous variables
*>>>>>
	logit policies_sold rank ///
		  b3.insured numberofvehicles numberofdrivers b2.marrystatus 

*>>>>>
* this one treats rank as discrete while numberofvehicles, numberofdrivers as continuous variables
*>>>>>
	logit policies_sold b1.rank ///
		  b3.insured numberofvehicles numberofdrivers b2.marrystatus

*>>>>>
* this one treats rank as continuous while numberofvehicles, numberofdrivers as discrete variables
*>>>>>
	logit policies_sold rank ///
		  b3.insured b1.numberofvehicles b1.numberofdrivers b2.marrystatus 
*>>>>>	
* this one treats rank, numberofvehicles, numberofdrivers as discrete variables
*>>>>>
	logit policies_sold b1.rank ///
		  b3.insured b1.numberofvehicles b1.numberofdrivers b2.marrystatus 	  

*--> 3.2.2 policies_sold with interactions
*>>>>>
* this one treats rank, numberofvehicles, numberofdrivers as continuous variables
*>>>>>
	logit policies_sold c.rank ///
	      b3.insured##rank c.numberofvehicles##rank ///
	      c.numberofdrivers##rank b2.marrystatus##rank   
*>>>>>
* this one treats rank as discrete while numberofvehicles, numberofdrivers as continuous variables
*>>>>>
	logit policies_sold i.rank ///
	      b3.insured##rank c.numberofvehicles##rank ///
	      c.numberofdrivers##rank b2.marrystatus##rank
*>>>>>		  
* this one treats rank as continuous while numberofvehicles, numberofdrivers as discrete variables
*>>>>>
	logit policies_sold c.rank ///
	      b3.insured##c.rank i.numberofvehicles##c.rank ///
	      i.numberofdrivers##c.rank b2.marrystatus##c.rank   
*>>>>>		  
* this one treats rank, numberofvehicles, numberofdrivers as discrete variables
*>>>>>
	logit policies_sold i.rank ///
	      b3.insured##i.rank i.numberofvehicles##i.rank ///
	      i.numberofdrivers##i.rank b2.marrystatus##i.rank  
		  
*--> 3.3 Multivariate logit


*>>>>>
* Explanation of bivariate logit/probit model: 
* When we are trying to estimate binary discrete choice models with two outcome variables 
* If these two outcome variables are independent with each other. Then we could model two logit/probit models sperately.
* However, sometimes these two outcome variables are correlated with each other.
* for example, 
* Individual decision whether to work or not and whether to have children or not.
* Farmer decision of whether to use marketing contracts or not and whether to use environmental contracts or not.
* So the bivariate models estimates decisions that are interrelated as opposed to independent.	
* In our case, we suspect that click and policy sold are two outcome variables that are highly correlated with each other. 
* So a bivariate logit/probit is appropriate. 
* Note: If we have more than two outcome variables that are correlated with each other, then multivariate logit/probit would be better.
*>>>>>


*--> 3.3.1 Without interactions
*>>>>>
* this one treats rank, numberofvehicles, numberofdrivers as continuous variables
*>>>>>
    local x "rank insured_N insured_Y married numberofvehicles numberofdrivers"
	mvprobit (click_true = `x') (policies_sold = `x'), dr(100)

*>>>>>
* this one treats rank as discrete while numberofvehicles, numberofdrivers as continuous variables
*>>>>>
	local x "r2-r5 insured_N insured_Y married numberofvehicles numberofdrivers"
	mvprobit (click_true = `x') (policies_sold = `x'), dr(100)

*>>>>>
* this one treats rank as continuous while numberofvehicles, numberofdrivers as discrete variables
*>>>>>
    local x "rank insured_N insured_Y married vehicle2-3 driver2-3"
	mvprobit (click_true = `x') (policies_sold = `x'), dr(100)

*>>>>>
* this one treats rank, numberofvehicles, numberofdrivers as discrete variables
*>>>>>
    local x "r2-r5 insured_N insured_Y married vehicle2-3 driver2-3"
	mvprobit (click_true = `x') (policies_sold = `x'), dr(100)
	
	
*--> 3.3.2 With interactions

*>>>>>
* I will only treat rank, numberofvehicles, numberofdrivers as continuous 
* since the # of interactions will increase a lot. 
* if necessary, i will do it later. 
*>>>>>

*>>>>>
* the command bivariate in Stata doesn't support factor variables.
* thus, I have to create the interaction terms by hand. 
*>>>>>
	gen insuerd_N_rank = insured_N * rank
	gen insured_Y_rank = insured_Y * rank
	gen married_rank = married * rank
	gen driver_rank = numberofdrivers * rank
	gen vehicle_rank = numberofvehicles * rank
	
	local x1 "rank insured_N insured_Y married numberofdrivers numberofvehicles"
	local x2 "insuerd_N_rank insured_Y_rank married_rank driver_rank vehicle_rank"
	mvprobit (click_true = `x1' `x2') (policies_sold = `x1' `x2'), dr(100)


*--> 3.4 Nested logit or multinomial logit or conditional logit
*>>>>>
* All of the variables we have are observations-specific variables, meaning that
* there is only variation in demographics across observations.
* But when we are doing multinomial/nested logit/conditional model, we need alternative-specific 
* variables to estimate. To be more specific, when one observation/insurance buyer 
* decides to click or not, there is no variation in his/her demographics and ranks.
* From my perspective, simple interacting with rank would be enough.
* Any thoughts on this?
*>>>>>

	
*===============================================================================
*-> 4. Classification
*===============================================================================

* I don't think we need classification so far. But the code below is random forest
* that I tried. Feel free to run and get some conclusions from it. 
	
*--> 4.1 Random forest 
	set seed 2021
	gen u = uniform()
	sort u
	
	gen out_of_bag_error1 = .
	gen validation_error = .
	gen iter1 = .
	local j = 0
	local x "insured_N insured_Y married numberofvehicles numberofdrivers"	
	
	forvalues i = 10(5)500{
		local j = `j' + 1
		rforest class2 `x' in 1/7000, ///
					type(class) iter(`i') numvars(1)
		replace iter1 = `i' in `j'
		replace out_of_bag_error1 = `e(OOB_Error)' in `j'
		predict p in 7001/10000
		replace validation_error = `e(error_rate)' in `j'
		drop p
}
  tw scatter out_of_bag_error1 iter1
	gen oob_error = .
	gen nvars = .
	gen val_error = .
	local j = 0
	local x "insured_N insured_Y married numberofvehicles numberofdrivers"	
	forvalues i = 1(1)6{
		local j = `j' + 1
		rforest class2 `x' in 1/7000, ///
					type(class) iter(500) numvars(`i')
		replace nvars = `i' in `j'
		replace oob_error = `e(OOB_Error)' in `j'
		predict p in 7001/10000
		replace val_error = `e(error_rate)' in `j'
		drop p
}
	

