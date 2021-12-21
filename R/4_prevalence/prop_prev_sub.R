library("metafor")


### Load data and prepare data 

# Load prevalence survey data (Supplementary Table 3)

data = read.csv(file = "data/prevalence_survey_data.csv")

# Add survey (year) column

data$survey_year = paste(data$survey," (", data$year, ")", sep = "")


### Meta-analysis 

# Perform mixed effects meta-analysis 

data = escalc(measure = "PLO", xi = sub_neg + sub_pos, mi = clin_neg + clin_pos, data = data, append = TRUE)

mod_prop_prev_sub = rma.uni(measure = "PLO", xi = sub_neg + sub_pos, mi = clin_neg + clin_pos, data = data, slab = survey_year)

# Extract parameters for summary value 

y = mod_prop_prev_sub$b[1]
se = (predict(mod_prop_prev_sub)$cr.ub - y)/1.96
output = data.frame("y"= y, "se"= se)


### Summary result for contribution to transmission 

# Save results for summary value to interim outputs to use in estimation of contribution to transmission 

write.csv(output, "interim_outputs/prop_prev_sub_summ.csv", row.names = FALSE)


### Prepare results for plotting 

# Bind summary value with results for individual studies 

summary = matrix(c(NA, NA, NA, NA, NA, NA, NA, NA, NA, "Summary", y, se^2), nrow = 1)
summary = as.data.frame(summary)
names(summary) = names(data)
data = rbind(data,summary)

# Convert to numeric

data$yi = as.numeric(data$yi)
data$vi = as.numeric(data$vi)
data$survey_year = as.factor(data$survey_year)

# Add column for standard deviation 

data$se = sqrt(data$vi)

# Generate uncertainty intervals 

data$ci_lower = data$yi - 1.96*data$se
data$ci_upper = data$yi + 1.96*data$se

# Undo logit transform 

data$yi = exp(data$yi)/(1+exp(data$yi))
data$ci_lower = exp(data$ci_lower)/(1+exp(data$ci_lower))
data$ci_upper = exp(data$ci_upper)/(1+exp(data$ci_upper))

# Rearrange data and save results to interim outputs for plotting  

data$point_value = data$yi
data = data[,c("survey_year","region","point_value","ci_lower","ci_upper")]

write.csv(data, "interim_outputs/prop_prev_sub_all.csv", row.names = FALSE)





