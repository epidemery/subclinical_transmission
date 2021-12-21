library("metafor")

### Load data 

# Load household contact data for each study (Supplementary Table 1)

viet = read.csv(file = "data/HHC_data_viet.csv")
phil = read.csv(file = "data/HHC_data_phil.csv")
act3 = read.csv(file = "data/HHC_data_act3.csv")
bang = read.csv(file = "data/HHC_data_bang.csv")

### Prepare data for meta-analysis 

# Set up data frame 

data = data.frame(study = rep("Study",4),
                  inf_S = rep(0,4),
                  N_S = rep(0,4),
                  inf_C = rep(0,4),
                  N_C = rep(0,4))

data$study = c("viet",
               "phil",
               "act3",
               "bang")

# Sum across smear (except for Bangladesh which only includes smear positive)

data$inf_S = c(viet$inf_Sn+viet$inf_Sp,
               phil$inf_Sn+phil$inf_Sp,
               act3$inf_Sn+act3$inf_Sp,
               +bang$inf_Sp)

data$N_S = c(viet$N_Sn+viet$N_Sp,
             phil$N_Sn+phil$N_Sp,
             act3$N_Sn+act3$N_Sp,
             +bang$N_Sp)

data$inf_C = c(viet$inf_Cn+viet$inf_Cp,
               phil$inf_Cn+phil$inf_Cp,
               act3$inf_Cn+act3$inf_Cp,
               +bang$inf_Cp)

data$N_C = c(viet$N_Cn+viet$N_Cp,
             phil$N_Cn+phil$N_Cp,
             act3$N_Cn+act3$N_Cp,
             +bang$N_Cp)


### Meta-analysis 

# Perform mixed effects meta-analysis 

data = escalc(measure = "OR", ai = inf_C, n1i = N_C,  ci = inf_S, n2i = N_S, data = data, append = TRUE)

model = rma.uni(measure = "OR", ai = inf_C, n1i = N_C, ci = inf_S, n2i = N_S, data = data, slab = study)


# Bind  parameters for confidence interval (summ) with data frame for individual studies

data = rbind(data,c("summ","NA","NA","NA","NA",predict(model)$pred,predict(model)$se^2))


### Generate odds ratios and save to interim outputs for plotting

# Convert to numeric 

data$yi = as.numeric(data$yi)
data$vi = as.numeric(data$vi)

# Introduce columns for results 

data$point_value = rep(0,5)
data$ci_lower = rep(0,5)
data$ci_upper = rep(0,5)

# Sample odds ratios and use quantiles for results

for(i in seq(1,5)){
  data[i,c("point_value","ci_lower","ci_upper")] = quantile(exp(rnorm(1000000,data$yi[i],sqrt(data$vi[i]))),c(0.5,0.025,0.975))
}

# Rearrange results and save to interim outputs 

data$survey_year = c("Viet Nam 2007",
                     "Philippines 1997",
                     "ACT3 2017",
                     "Bangladesh 2007",
                     "Summary")

data = data[,c("survey_year", "point_value", "ci_lower", "ci_upper")]

write.csv(data, "interim_outputs/odds_symp.csv", row.names = FALSE)
