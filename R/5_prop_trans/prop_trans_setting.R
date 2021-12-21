

### Load data 

# Load prevalence survey data (Supplementary Table 3)

data_prev = read.csv(file = "data/prevalence_survey_data.csv")

# Add survey (year) column

data_prev$survey_year = paste(data_prev$survey," (", data_prev$year, ")", sep = "")

# Load summary results for relative hazards 

rel_rep_s = read.csv(file = "interim_outputs/rel_hazards_s.csv")
rel_rep_n = read.csv(file = "interim_outputs/rel_hazards_n.csv")


### Estimate relative infectiousness from relative hazards 

# Number of samples

samples = 1000000

# Quantiles to use throughout 

quantiles = c(0.025,0.5,0.975)

# Samples of relative durations. Progression and regression parameters as per Supplementary Table 2.  

reg_sub = rnorm(samples,0.42,0.01)
pro_sub = rnorm(samples,0.51,0.09)
reg_cli = rnorm(samples,1.26,0.18)
pro_cli1 = 0.7
pro_cli2 = 0.39
d_sub = 1/(reg_sub+pro_sub)
d_cli = 1/(reg_cli+pro_cli1+pro_cli2)
rel_dur = d_cli/d_sub

# Samples of relative infectiousness 

r_s = rel_dur*exp(rnorm(samples, mean = rel_rep_s$yi, sd = rel_rep_s$si))
r_n = exp(rnorm(samples, mean = rel_rep_n$yi, sd = rel_rep_n$si))


### Proportions for each setting individually

# Proportion subclinical that is smear positive

data_prev$prop_sub_pos = data_prev$sub_pos/(data_prev$sub_pos+data_prev$sub_neg)

# Proportion clinical that is smear positive

data_prev$prop_clin_pos = data_prev$clin_pos/(data_prev$clin_pos+data_prev$clin_neg)

# Proportion prevalent TB that is subclinical 

data_prev$prop_prev_sub = (data_prev$sub_neg+data_prev$sub_pos)/(data_prev$sub_neg+data_prev$sub_pos+data_prev$clin_neg+data_prev$clin_pos)


### Estimate contribution to transmission for each setting individually 

for(i in seq(1,dim(data_prev)[1])){
  # Samples for proportions subclinical and clinical smear-positive and proportion prevalent TB subclinical 
  
  P_S_p = rbinom(samples,data_prev$sub_neg[i]+data_prev$sub_pos[i],data_prev$prop_sub_pos[i])/(data_prev$sub_neg[i]+data_prev$sub_pos[i])
  P_C_p = rbinom(samples,data_prev$clin_neg[i]+data_prev$clin_pos[i],data_prev$prop_clin_pos[i])/(data_prev$clin_neg[i]+data_prev$clin_pos[i])
  P_TB_S = rbinom(samples,data_prev$sub_neg[i]+data_prev$sub_pos[i]+data_prev$clin_neg[i]+data_prev$clin_pos[i],data_prev$prop_prev_sub[i])/(data_prev$sub_neg[i]+data_prev$sub_pos[i]+data_prev$clin_neg[i]+data_prev$clin_pos[i])
  
  # Contribution to transmission  
  
  prop_trans = ((P_S_p*r_s + (1-P_S_p)*r_s*r_n)*P_TB_S)/(((P_S_p*r_s + (1-P_S_p)*r_s*r_n)*P_TB_S)+((P_C_p + (1-P_C_p)*r_n)*(1-P_TB_S)))
  
  # Results 
  
  results_prop_trans = round(quantile(prop_trans,quantiles),3)
  data_prev$prop_trans_low[i] = 100*results_prop_trans[1]
  data_prev$prop_trans_med[i] = 100*results_prop_trans[2]
  data_prev$prop_trans_upp[i] = 100*results_prop_trans[3]
}


# Rearrange resuts and save to interim outputs for plotting  

prop_prev_sub = data_prev[,c("year","survey_year","prop_trans_low","prop_trans_med","prop_trans_upp")]
prop_prev_sub$region = c("Asia",
                         "Asia",
                         "Asia",
                         "Asia",
                         "Asia",
                         "Asia",
                         "Asia",
                         "Africa",
                         "Africa",
                         "Africa",
                         "Asia",
                         "Asia",
                         "Asia",
                         "Africa",
                         "Africa") 

prop_prev_sub$point_value = prop_prev_sub$prop_trans_med
prop_prev_sub$ci_lower = prop_prev_sub$prop_trans_low
prop_prev_sub$ci_upper = prop_prev_sub$prop_trans_upp
prop_prev_sub = prop_prev_sub[,c("survey_year","region","point_value","ci_lower","ci_upper")]

write.csv(prop_prev_sub, "interim_outputs/prop_trans_setting.csv", row.names = FALSE)

