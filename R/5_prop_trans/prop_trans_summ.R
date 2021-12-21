

### Load data 

# Load summary results for relative hazards 

rel_rep_s = read.csv(file = "interim_outputs/rel_hazards_s.csv")
rel_rep_n = read.csv(file = "interim_outputs/rel_hazards_n.csv")

### Load summary results for proportions of prevalent TB 

# Proportion prevalent TB that is subclinical 

prop_prev_sub = read.csv(file = "interim_outputs/prop_prev_sub_summ.csv")

# Proportion subclinical that is smear positive

prop_sub_pos = read.csv(file = "interim_outputs/prop_sub_pos_summ.csv")

# Proportion clinical that is smear positive

prop_cli_pos = read.csv(file = "interim_outputs/prop_clin_pos_summ.csv")


### Estimate relative infectiousness from relative hazards 

samples = 1000000

# Quantiles to use throughout 

quantiles = c(0.025,0.5,0.975)

# Samples of relative durations. Progression and regression parameters as per Supplementary Table 2.  

reg_sub = rnorm(1000000,0.42,0.01)
pro_sub = rnorm(1000000,0.51,0.09)
reg_cli = rnorm(1000000,1.26,0.18)
pro_cli1 = 0.7
pro_cli2 = 0.39
d_sub = 1/(reg_sub+pro_sub)
d_cli = 1/(reg_cli+pro_cli1+pro_cli2)
rel_dur = d_cli/d_sub

# Samples of relative infectiousness 

r_s = rel_dur*exp(rnorm(samples, mean = rel_rep_s$yi, sd = rel_rep_s$si))
r_n = exp(rnorm(samples, mean = rel_rep_n$yi, sd = rel_rep_n$si))

### Estimate contribution to transmission for each setting individually 

# Samples for proportions subclinical and clinical smear-positive and proportion prevalent TB subclinical 

P_TB_S = rnorm(samples,prop_prev_sub$y,prop_prev_sub$se)
P_S_p = rnorm(samples,prop_sub_pos$y,prop_sub_pos$se)
P_C_p = rnorm(samples,prop_cli_pos$y,prop_cli_pos$se)

# Undo log transorm 

P_TB_S = exp(P_TB_S)/(1+exp(P_TB_S))
P_S_p = exp(P_S_p)/(1+exp(P_S_p))
P_C_p = exp(P_C_p)/(1+exp(P_C_p))

# Samples for contribution to transmission  

prop_trans = ((P_S_p*r_s + (1-P_S_p)*r_s*r_n)*P_TB_S)/(((P_S_p*r_s + (1-P_S_p)*r_s*r_n)*P_TB_S)+((P_C_p + (1-P_C_p)*r_n)*(1-P_TB_S)))

# Results

result = round(quantile(prop_trans,quantiles),2)

# Rearrange results and save  to interim outputs for plotting  

result = data.frame(survey_year = "Global",
                    region = "Global",
                    point_value = 100*result[[2]], 
                    ci_lower = 100*result[[1]], 
                    ci_upper = 100*result[[3]])

write.csv(result, "interim_outputs/prop_trans_summ.csv", row.names = FALSE)











# data = data.frame("category" = c("Subclinical","Clinical"), "lb" = c(NA,NA), "ce" = c(NA,NA), "ub" = c(NA,NA))
# data[1,c("lb","ce","ub")] = round(quantile(prop_trans,quantiles),2)
# data[2,c("ub","ce","lb")] = 1-data[1,c("lb","ce","ub")]
# 
# data[,c("lb","ce","ub")] = 100*data[,c("lb","ce","ub")]
# 
# data$category <- factor(data$category,levels = data$category[(order(rev(data$category)))])
# 
# 
# 
# # quantile(P_S_p,quantiles)
# # quantile(P_C_p,quantiles)
# # quantile(P_TB_S,quantiles)
# 
# theme=theme_bw()+
#   theme(panel.grid.major=element_blank(),
#         panel.grid.minor=element_blank())



# Graph = ggplot() +
#   geom_bar(data = data, stat="identity", aes(x = category, y = ce), colour = "grey55", fill = "grey55") +
#   #geom_bar(data = JPN_cohort_self_cure, stat="identity", aes(x = cohort, y = median/1000, fill = scenario), alpha = alpha)+
#   geom_errorbar(data = data, aes(x = category, ymin = lb, ymax = ub), width = 0.1, size = 0.35) +
#   #scale_fill_manual(values=c("white", colour_self_cure), labels=c("Lifelong infection","Self-clearance of infection"), guide = FALSE) + 
#   #scale_x_continuous(trans = "reverse", breaks = seq(2014, 1914, -5), labels = labels, expand = c(0, 0)) + 
#   scale_y_continuous(breaks = seq(0, 100, 10), limits = c(0, 100), expand = c(0, 0)) +
#   #labs(title = "Japan",
#   #     x = "Age",
#   #     y = "Number (millions)") +
#   theme + 
#   theme(legend.position = "none") + 
#   theme(axis.title.x=element_blank(), axis.title.y=element_blank()) + 
#   theme(axis.text.x.bottom = element_text(hjust = 0.5, vjust = -1, size = 15, angle = 0, margin = margin(t = 0))) + 
#   theme(axis.text.y.left = element_text(hjust = 1, vjust = 0.5, size = 12, angle = 0, margin = margin(l = 0)))
# 
# 
# ggsave(Graph, file = "infectiousness_symptoms/results/bar.png", width = 11, height = 8, units = "cm", dpi = 600)
# 
# 
#   