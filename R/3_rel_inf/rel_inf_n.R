library("metafor")

### Load data and rearrange data  

# Load mean and variance of (log) posteriors for r_s and r_n 

data_viet = read.csv("interim_outputs/rel_hazards_viet.csv")
data_phil = read.csv("interim_outputs/rel_hazards_phil.csv")
data_act3 = read.csv("interim_outputs/rel_hazards_act3.csv")
data_bang = read.csv("interim_outputs/rel_hazards_bang.csv")

# Extract mean and variance of (log) posteriors for r_n only 

data = data.frame("setting" = c("viet", "phil", "bang","act3"),
                  "yi" = c(data_viet$y_n,
                           data_phil$y_n,
                           data_bang$y_n,
                           data_act3$y_n),
                  "vi" = c(data_viet$v_n,
                           data_phil$v_n,
                           data_bang$v_n,
                           data_act3$v_n))

# Add column for standard deviation

data$si = sqrt(data$vi)


### Meta-analysis 

# Perform mixed effects meta-analysis 

model = rma.uni(measure = "GEN", yi, vi, data = data, slab = setting)

# Extract parameters for prediction interval (summ) and bind to data frame for individual studies

se = (predict(model)$cr.ub - model$b[1])/1.96

data = rbind(data, c("summ", model$b[1], se^2, se))


### Summary result for contribution to transmission 

# Save results for summary value to interim outputs to use in estimation of contribution to transmission 

write.csv(subset(data, setting == "summ"), "interim_outputs/rel_hazards_n.csv", row.names = FALSE)


### Estimate relative infectiousness from relative hazards 

# Number of samples 

samples = 1000000

# Quantiles to use throughout 

quantiles = c(0.025,0.5,0.975)

# Convert to numeric

data$yi = as.numeric(data$yi)
data$vi = as.numeric(data$vi)
data$si = as.numeric(data$si)

# Samples of relative hazards (use -1 for Bangladesh as placeholder)

viet = exp(rnorm(1000000,data$yi[1],data$si[1]))
phil = exp(rnorm(1000000,data$yi[2],data$si[2]))
bang = -1 
act3 = exp(rnorm(1000000,data$yi[4],data$si[4]))
summ = exp(rnorm(1000000,data$yi[5],data$si[5]))

# Samples of relative durations (assume durations independent of smear status)

rel_dur = 1

# Estimate of relative infectiousness 

viet = quantile(viet*rel_dur,c(0.025,0.5,0.975))
phil = quantile(phil*rel_dur,c(0.025,0.5,0.975))
bang = quantile(bang*rel_dur,c(0.025,0.5,0.975))
act3 = quantile(act3*rel_dur,c(0.025,0.5,0.975))
summ = quantile(summ*rel_dur,c(0.025,0.5,0.975))

# Rearrange data and save results to interim outputs for plotting  

data$point_value = c(viet[2],phil[2],bang[2],act3[2],summ[2])
data$ci_lower = c(viet[1],phil[1],bang[1],act3[1],summ[1])
data$ci_upper = c(viet[3],phil[3],bang[3],act3[3],summ[3])

data$survey_year = c("Vietnam 2007","Philippines 1997","Bangladesh 2007","ACT3 2017","Summary")
data = data[,c("survey_year","point_value","ci_lower","ci_upper")]

write.csv(data, "interim_outputs/rel_inf_n.csv", row.names = FALSE)
