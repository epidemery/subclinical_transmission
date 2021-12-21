data{
  /* Data */
  int N_B;                      
  int inf_B;                    
  int N_Sn;                     
  int inf_Sn;                   
  int N_Sp;                     
  int inf_Sp;                   
  int N_Cn;                     
  int inf_Cn;                   
  int N_Cp;                     
  int inf_Cp;                   
  
  /* Parameters specifying priors */
  real lambda_alpha; 
  real lambda_mean;
  real lambda_Cp_med; 
  real lambda_Cp_sigma;
  real r_s_med;
  real r_s_sigma;
  real r_n_med;
  real r_n_sigma;
}

parameters{
  /* Parameters to estimate */
  real<lower=0> lambda_B;  
  real<lower=0> lambda_Cp;  
  real<lower=0> r_s; 
  real<lower=0> r_n; 
}

model{
  /* Priors */
  lambda_B ~ gamma(lambda_alpha,lambda_alpha/lambda_mean);
  lambda_Cp ~ normal(lambda_Cp_med,lambda_Cp_sigma);
  r_s ~ normal(r_s_med,r_s_sigma);
  r_n ~ normal(r_n_med,r_n_sigma);
  
  /* Data */
  inf_B ~ binomial(N_B,1-exp(-lambda_B));
  inf_Cp ~ binomial(N_Cp,1-exp(-lambda_B-lambda_Cp));
  inf_Cn ~ binomial(N_Cn,1-exp(-lambda_B-r_n*lambda_Cp));
  inf_Sp ~ binomial(N_Sp,1-exp(-lambda_B-r_s*lambda_Cp));
  inf_Sn ~ binomial(N_Sn,1-exp(-lambda_B-r_s*r_n*lambda_Cp));
}

generated quantities{
  /* Estimated prevalences to check model fit */
  real p_B;
  real p_Cp;
  real p_Cn;
  real p_Sp;
  real p_Sn;
  
  p_B = 1-exp(-lambda_B);
  p_Cp = 1-exp(-lambda_B-lambda_Cp);
  p_Cn = 1-exp(-lambda_B-r_n*lambda_Cp);
  p_Sp = 1-exp(-lambda_B-r_s*lambda_Cp);
  p_Sn = 1-exp(-lambda_B-r_s*r_n*lambda_Cp);
}
