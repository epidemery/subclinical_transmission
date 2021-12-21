library("metafor")

### Load data 

# Load household contact data for each study (Supplementary Table 1) (not Bangladesh as only smear positive included)

viet = read.csv(file = "data/HHC_data_viet.csv")
phil = read.csv(file = "data/HHC_data_phil.csv")
act3 = read.csv(file = "data/HHC_data_act3.csv")


### Prepare data for meta-analysis 

# Set up data frame 

data = data.frame(study = rep("Study",3),
                  inf_p = rep(0,3),
                  N_p = rep(0,3),
                  inf_n = rep(0,3),
                  N_n = rep(0,3))

data$study = c("viet",
               "phil",
               "act3")

# Sum across symptoms 

data$inf_p = c(viet$inf_Sp+viet$inf_Cp,
               phil$inf_Sp+phil$inf_Cp,
               act3$inf_Sp+act3$inf_Cp)

data$N_p = c(viet$N_Sp+viet$N_Cp,
             phil$N_Sp+phil$N_Cp,
             act3$N_Sp+act3$N_Cp)

data$inf_n = c(viet$inf_Sn+viet$inf_Cn,
               phil$inf_Sn+phil$inf_Cn,
               act3$inf_Sn+act3$inf_Cn)

data$N_n = c(viet$N_Sn+viet$N_Cn,
             phil$N_Sn+phil$N_Cn,
             act3$N_Sn+act3$N_Cn)


### Meta-analysis 

# Perform mixed effects meta-analysis 

data = escalc(measure = "OR", ai = inf_p, n1i = N_p, ci = inf_n, n2i = N_n, data = data, append = TRUE)

model = rma.uni(measure = "OR", ai = inf_p, n1i = N_p, ci = inf_n, n2i = N_n, data = data, slab = study)

# Bind  parameters for confidence interval (summ) with data frame for individual studies


### Generate odds ratios and save to interim outputs for plotting

# Convert to numeric 

data = rbind(data,c("summ","NA","NA","NA","NA",predict(model)$pred,predict(model)$se^2))

data$yi = as.numeric(data$yi)
data$vi = as.numeric(data$vi)

# Introduce columns for results 

data$point_value = rep(0,4)
data$ci_lower = rep(0,4)
data$ci_upper = rep(0,4)

# Sample odds ratios and use quantiles for results

for(i in seq(1,4)){
  data[i,c("point_value","ci_lower","ci_upper")] = quantile(exp(rnorm(1000000,data$yi[i],sqrt(data$vi[i]))),c(0.5,0.025,0.975))
}

# Rearrange results 

data$survey_year = c("Viet Nam 2007",
                     "Philippines 1997",
                     "ACT3 2017",
                     "Summary")

data = data[,c("survey_year", "point_value", "ci_lower", "ci_upper")]

# Add dummy row for Bangladesh so plots for subclinical and smear negative align 

data = rbind(data,c("Bangladesh 2007",-1,-1,-1))

# Save to interim outputs 

write.csv(data, "interim_outputs/odds_smear.csv", row.names = FALSE)




