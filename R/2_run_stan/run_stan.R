library("rstan") 


# Specify model name. Either "viet", "phil", "act3" or "bang" 

model_name = "bang" 

# Load household contact data (Supplementary Table 1)

HHC_data = read.csv(file = paste0("data/HHC_data_", model_name, ".csv"))

# Specify priors 

priors = list(lambda_alpha = 2,
              lambda_mean = 0.1,
              lambda_Cp_med = 0.5,
              lambda_Cp_sigma = 20,
              r_s_med = 1,
              r_s_sigma = 20,
              r_n_med = 0.2,
              r_n_sigma = 20)

# Bring together all model inputs 

model_inputs = c(HHC_data,priors)

# Specify Stan model. Bangladesh is separate as it considers smear positive index cases only  

if(model_name == "bang"){
  model = stan_model('stan/model_bang.stan')
}else{
  model = stan_model('stan/model.stan')  
}

# Sampling 

fit = sampling(model,
               data = model_inputs,
               iter = 50000, chains = 1,
               control = list(adapt_delta = 0.99))

# Save model fit 

saveRDS(fit, file = paste0("interim_outputs/fit_", model_name, ".rds"))

# Extract posterior for r_s and r_n 

posterior = extract(fit, inc_warmup = FALSE, permuted = TRUE)

if(model_name == "bang"){
  posterior = data.frame("r_s" = posterior$r_s)
}else{
  posterior = data.frame("r_s" = posterior$r_s,
                         "r_n" = posterior$r_n)  
}

# Find mean and variance of (log) posteriors 

if(model_name == "bang"){
  y_s = mean(log(posterior$r_s))
  v_s = var(log(posterior$r_s))
}else{
  y_s = mean(log(posterior$r_s))
  v_s = var(log(posterior$r_s))
  y_n = mean(log(posterior$r_n))
  v_n = var(log(posterior$r_n))  
}

# Save results to use in meta-analysis of r_s and r_n 

if(model_name == "bang"){
  results = data.frame("y_s" = y_s,
                       "v_s" = v_s,
                       "y_n" = NA,
                       "v_n" = NA)
}else{
  results = data.frame("y_s" = y_s,
                       "v_s" = v_s,
                       "y_n" = y_n,
                       "v_n" = v_n)
}

write.csv(results, paste0("interim_outputs/rel_hazards_", model_name, ".csv"), row.names = FALSE)



