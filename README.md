## Estimating the contribution of subclinical tuberculosis disease to transmission

This repository contains all the data and files necessary to re-run the analyses in:

_Emery JC, Dodd PJ et al. Estimating the contribution of subclinical tuberculosis disease to transmission._

Full details of the study can be found in the main paper and supplementary materials.

### Repository structure 

Contents of the folders in the repository:

1. `data`: Input data

2. `stan`: Stan model files

3. `R`: R files to:
  
    - `1_odds_ratios`: Calculate odds ratios from household contact data

    - `2_run_stan`: Perform MCMC runs in stan 

    - `3_rel_inf`: Estimate relative infectiousness from model results 

    - `4_prevalence`: Meta-analyse prevalence survey data (e.g. proportion of prevalent TB that is subclinical)

    - `5_prop_trans`: Estimate the contribution of subclinical TB to transmission 

    - `6_outputs`: Contruct plots

4. `interim_outputs`: Intermediate outputs to be used as inputs for further analysis 

5. `outputs`: Plots to be included in the:  

    - `main_paper`: Main paper

    - `sup_mats`: Supplementary materials 
    
Note that by default the output folders `interim_outputs`, `outputs/main_paper` and `outputs/supp_mats` contain a placeholder textfile `Placeholder.rtf` to preserve the otherwise empty folders before any outputs are generated. 

Note also that hereafter `XXXX` denotes either `viet` (Viet Nam), `phil` (Philippines), `bang` (Bangladesh) or `act3` (ACT3). 
    
### Data sources 

Household contact data (Supplementary Table 1): `HHC_data_XXXX.csv`

Subclinical and clinical disease durations (derived from Supplementary Table 2): `duration_data.csv`

Prevalence survey data (Supplementary Table 3): `prevalence_survey_data.csv` 

### Implementation 

To perform analyses as per the main paper or supplementary materials:

#### Calculate odds ratios from household contact data

1. Household contact data is stored in the folder `data` and labelled `HHC_data_XXXX.csv`. 

2. Odds ratios by symptoms or smear status are are estimated with `odds_symp.R` or `odds_smear.R`, respectively, in the folder `R/1_odds_ratios`. 

3. Results are saved as `odds_symp.csv` and `odds_smear.csv` to the folder `interim_outputs`

#### Perform MCMC runs in stan 

1. Household contact data is stored in the folder `data` and labelled `HHC_data_XXXX.csv`. 

2. A MCMC run is then executed with `run_stan.R` in the folder `R/2_run_stan` using the appropriate household contact data and stan model file from the folder `stan`. 

3. The appropriate data and stan model file are specified in `run_stan.R` using `viet` (Viet Nam), `phil` (Philippines), `bang` (Bangladesh) or `act3` (ACT3). All studies use `model.stan` except Bangladesh, which uses `model_bang.stan` since only smear-positive index cases were included. 

4. Full details of the model fit are saved as `fit_XXXX.rds` to the folder `interim_outputs`. 

5. The mean and variance of the (log) posterior of the relative hazards are saved as `rel_hazards_XXXX.csv` to the folder `interim_outputs`. 

#### Estimate relative infectiousness from model results 

1. Mixed-effect meta-anayses of the relative hazards from subclinical and smear-negative index cases are performed using `rel_inf_s.R` and `rel_inf_n.R` in the folder `R/3_rel_inf`, respectively. 

2. In both scripts the mean and variance of the (log) posterior of the relative hazards (`rel_hazards_XXXX.csv` in the folder `interim_outputs`) for all studies are imported. 

3. In both scripts a mixed-effects meta-analysis is performed with the results for the summary value saved as either `rel_hazards_s.csv` or `rel_hazards_n.csv` to the folder `interim_outputs`. 

4. In the script for the relative hazards from subclinical index cases, the duration of subclinical TB versus clinical TB is used to the estimate the relative infectiousness of subclinical TB for each study separately and the summary value. In the smear-negative case the relative hazards are assumed equal to the relative infectiousness. 

5. The results for relative infectiousness for each study and the summary value are saved as `rel_inf_s.csv` and `rel_inf_n.csv` to the folder `interim_outputs`. 

#### Meta-analyse prevalence survey data 

1. Prevalence survey data is stored in the folder `data` and labelled `prevalence_survey_data.csv`. 

2. This data is then imported to scripts in the folder `R/4_prevalence` that perform mixed-effect meta-anayses of: 

    1. The proportion of prevalent TB that is subclinical (`prop_prev_sub.R`)
    2. The proportion of subclincal TB that is smear-positive (`prop_sub_pos.R`)
    3. The proportion of clinical TB that is smear-positive (`prop_clin_pos.R`)
    
3. The results for the summary value are saved as `prop_prev_sub_summ.csv`, `prop_sub_pos_summ.csv` and `prop_clin_pos_summ.csv` to the folder `interim_outputs`. 

4. The results for the individual surveys plus summary value are saved as `prop_prev_sub_all.csv`, `prop_sub_pos_all.csv` and `prop_clin_pos_all.csv` to the folder `interim_outputs`. 

#### Estimate the contribution of subclinical TB to transmission

1. The proportion of transmission from subclinical TB is estimated for each setting separately using `prop_trans_setting.R` in the folder `R/5_prop_trans`. 

2. Prevalence survey data (`prevalence_survey_data.csv`) is imported from the folder `data`. 

3. The summary value for the relative hazards from subclinical and smear-negative index cases (`rel_hazards_s.csv` and `rel_hazards_n.csv`) are imported from the folder `interim_outputs`. 

4. The duration of subclinical TB versus clinical TB is again used to the estimate the relative infectiousness of subclinical TB. In the smear-negative case the relative hazards are assumed equal to the relative infectiousness. 

5. The proportion of transmission in each setting is then estimated and saved as `prop_trans_setting.csv` to the folder `interim_outputs`. 

6. A summary value for the proportion of transmission from subclinical TB is then estimated using `prop_trans_summ.R` in the folder `R/5_prop_trans.R`.

7. The process is the same as the above except that at step 2) the summary values `prop_prev_sub_summ.csv`, `prop_sub_pos_summ.csv` and `prop_clin_pos_summ.csv` are imported from the folder `interim_outputs`.  

8. The summary value for the proportion of transmission from subclinical TB is then saved as `prop_trans_summ.csv` to the folder `interim_outputs`. 

#### Contruct plots

1. Plots for the main paper are constructed using `outputs_main_paper.R` in the folder `R/6_outputs`, which imports all relevant results from the folder `interim_outputs`. All plots are saved to the folder `outputs/main_paper` with the title of their respective label in the main paper (e.g. `fig_3A.png`).  

2. Plots for the supplementary materials are constructed using `outputs_supp_mats.R` in the folder `R/6_outputs`, which imports all relevant results from the folder `interim_outputs`. 

3. The appropriate study is specified in `outputs_supp_mats.R` using `viet` (Viet Nam), `phil` (Philippines), `bang` (Bangladesh) or `act3` (ACT3). 

4. All plots are saved to the folder `outputs/supp_mats` with the type of plot and study name (e.g. `trace_viet.png`) for the Viet Nam trace plot. 

5. Detailed model results (e.g n_eff, Rhat, mean, mcse, sd and sample quantiles) are viewed in a web-browser using `shinystan`.

### Further resources 

Stan is used to perform the MCMC runs. The R packages `rstan` and `shinystan` are used to interact with stan and analyse the results using R. Meta-analyses are performed using the R package `metafor`. 

`rstan` documentation: https://mc-stan.org/users/interfaces/rstan

`shinystan` documentation: https://mc-stan.org/users/interfaces/shinystan

`metafor` documentation: https://www.metafor-project.org/doku.php

 
