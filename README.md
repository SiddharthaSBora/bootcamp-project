# bootcamp-project
Erdos Data Science Bootcamp Project

## Description of Process
* Logit Model Selection (Y = Policies_Sold)
    - With Naive specification, identify preliminary cutoff for assigning Y_hat = 1 (0.10) via f1 score
    - Iterate through set of specifications that included continuous rank, continuous rank interactions, discrete rank, and combinations of discrete rank interactions. Identify best performing model via f1 score and recall (F1 Score ~ 0.3, Recall ~ 0.7)
    - Selected functional form: Dummies for Currently Insured, Number of Vehicles, Number of Drivers, Insured, rank, with interactions between rank and Number of Drivers/Insurance Status
    - Identify final cutoff (0.14) using selected functional form from above using F1 Score (F1 Score ~ 0.33)
* Logit Model Selection (Y = Policies_Sold | click)
    - Same process as above... prelim cutoff (0.32)
    - Selected functional form (F1 Score = 0.6): Dummies for Currently Insured, Number of Vehicles, Number of Drivers, Insured, rank, with interactions between rank and Insurance status
    - Identify final cutoff (0.38) as above
* Model application
    - Identify which unique groups of consumers are most/least responsive to change in rank
    - Convert predicted probabilities of purchase into costs per policy purchase
    - Calculate marginal changes in costs per policy for unique groups with respect to rank; demean by average marginal changes per group/rank combination
    - Calculate average demeaned marginal change in costs per policy purchase across all ranks for unique groups
    - Rank based on highest/lowest "sensitivities" to changes in rank