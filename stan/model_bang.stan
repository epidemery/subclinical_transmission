data{
  /* Data */
  int N_B;                      /* number, background */
  int inf_B;                    /* infected, background */
  int N_Sp;                      /* number, subclinical */
  int inf_Sp;                    /* infected, subclinical */
  int N_Cp;                      /* number, clinical */
  int inf_Cp;                    /* infected, subclinical */
  
  /* Parameters specifying priors */
  real lambda_alpha; 
  real lambda_mean;
  real lambda_Cp_med; 
  real lambda_Cp_sigma;
  real r_s_med;
  real r_s_sigma;
}

parameters{
  /* Parameters to estimate */
  real<lower=0> lambda_B;  
  real<lower=0> lambda_Cp;  
  real<lower=0> r_s;
}

model{
  /* Priors */
  lambda_B ~ gamma(lambda_alpha,lambda_alpha/lambda_mean);
  lambda_Cp ~ normal(lambda_Cp_med,lambda_Cp_sigma);
  r_s ~ normal(r_s_med,r_s_sigma);
  
  /* Data */
  inf_B ~ binomial(N_B,1-exp(-lambda_B));
  inf_Cp ~ binomial(N_Cp,1-exp(-lambda_B-lambda_Cp));
  inf_Sp ~ binomial(N_Sp,1-exp(-lambda_B-r_s*lambda_Cp));
}

generated quantities{
  /* Estimated prevalences to check model fit */
  real p_B;
  real p_Cp;
  real p_Sp;

  p_B = 1-exp(-lambda_B);
  p_Cp = 1-exp(-lambda_B-lambda_Cp);
  p_Sp = 1-exp(-lambda_B-r_s*lambda_Cp);
}
