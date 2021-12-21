library("rstan") 
library("bayesplot")
library("PropCIs")
library("shinystan")


### Specify model and load data/interim outputs 

# Specify model name. Either "viet", "phil", "act3" or "bang" 

model_name = "phil" 

# Load household contact data 

HHC_data = read.csv(file = paste0("data/HHC_data_", model_name, ".csv"))

# Load model fit 

fit = readRDS(file = paste0("interim_outputs/fit_", model_name, ".rds"))


### Plot parameters 

# Plot appearance

title_size = 15.5
axis_title_size = 18
x_axis_text_size = 12
y_axis_text_size = 13
title_align = 0.5
title_face = "bold"
line_thickness = 0.6
point_size = 1.25

# Plot titles

if(model_name == "viet"){
  study_name = "Viet Nam"
}else if(model_name == "phil"){
  study_name = "Philippines"
}else if(model_name == "act3"){
  study_name = "ACT3"
}else if(model_name == "bang"){
  study_name = "Bangladesh"
}

# Parameters to include in plots

if(model_name == "bang"){
  pars = c("lambda_B","lambda_Cp","r_s")
}else{
  pars = c("lambda_B","lambda_Cp","r_s","r_n")
}


### Prevalence plot

# Prevalence estimates from model fit 

prev_mod = as.data.frame(summary(fit)$summary)

prev_mod = prev_mod[c("p_B", "p_Cp", "p_Cn", "p_Sp", "p_Sn"),
                    c("2.5%","50%","97.5%")]
prev_mod$hh = c("p_B", "p_Cp", "p_Cn", "p_Sp", "p_Sn")
prev_mod$hh <- factor(prev_mod$hh,levels = c("p_B", "p_Sn", "p_Sp", "p_Cn", "p_Cp"))

# Prevalence from household contact data 

prev_data = prev_mod 

if(model_name == "bang"){
  
  prev_data$`50%` = c(HHC_data$inf_B/HHC_data$N_B,
                      HHC_data$inf_Cp/HHC_data$N_Cp,
                      NA,
                      HHC_data$inf_Sp/HHC_data$N_Sp,
                      NA)
  
  prev_data$`2.5%`[1] = unlist(exactci(HHC_data$inf_B, HHC_data$N_B, conf.level=0.95))[[1]]
  prev_data$`2.5%`[2] = unlist(exactci(HHC_data$inf_Cp, HHC_data$N_Cp, conf.level=0.95))[[1]]
  prev_data$`2.5%`[3] = NA
  prev_data$`2.5%`[4] = unlist(exactci(HHC_data$inf_Sp, HHC_data$N_Sp, conf.level=0.95))[[1]]
  prev_data$`2.5%`[5] = NA
  
  prev_data$`97.5%`[1] = unlist(exactci(HHC_data$inf_B, HHC_data$N_B, conf.level=0.95))[[2]]
  prev_data$`97.5%`[2] = unlist(exactci(HHC_data$inf_Cp, HHC_data$N_Cp, conf.level=0.95))[[2]]
  prev_data$`97.5%`[3] = NA
  prev_data$`97.5%`[4] = unlist(exactci(HHC_data$inf_Sp, HHC_data$N_Sp, conf.level=0.95))[[2]]
  prev_data$`97.5%`[5] = NA
  
}else{
  
  prev_data$`50%` = c(HHC_data$inf_B/HHC_data$N_B,
                      HHC_data$inf_Cp/HHC_data$N_Cp,
                      HHC_data$inf_Cn/HHC_data$N_Cn,
                      HHC_data$inf_Sp/HHC_data$N_Sp,
                      HHC_data$inf_Sn/HHC_data$N_Sn)  
  
  prev_data$`2.5%`[1] = unlist(exactci(HHC_data$inf_B, HHC_data$N_B, conf.level=0.95))[[1]]
  prev_data$`2.5%`[2] = unlist(exactci(HHC_data$inf_Cp, HHC_data$N_Cp, conf.level=0.95))[[1]]
  prev_data$`2.5%`[3] = unlist(exactci(HHC_data$inf_Cn, HHC_data$N_Cn, conf.level=0.95))[[1]]
  prev_data$`2.5%`[4] = unlist(exactci(HHC_data$inf_Sp, HHC_data$N_Sp, conf.level=0.95))[[1]]
  prev_data$`2.5%`[5] = unlist(exactci(HHC_data$inf_Sn, HHC_data$N_Sn, conf.level=0.95))[[1]]
  
  prev_data$`97.5%`[1] = unlist(exactci(HHC_data$inf_B, HHC_data$N_B, conf.level=0.95))[[2]]
  prev_data$`97.5%`[2] = unlist(exactci(HHC_data$inf_Cp, HHC_data$N_Cp, conf.level=0.95))[[2]]
  prev_data$`97.5%`[3] = unlist(exactci(HHC_data$inf_Cn, HHC_data$N_Cn, conf.level=0.95))[[2]]
  prev_data$`97.5%`[4] = unlist(exactci(HHC_data$inf_Sp, HHC_data$N_Sp, conf.level=0.95))[[2]]
  prev_data$`97.5%`[5] = unlist(exactci(HHC_data$inf_Sn, HHC_data$N_Sn, conf.level=0.95))[[2]]
}

# Plot of prevalence estimates versus data 

fig_1 = ggplot() +
  geom_point(data = prev_mod, aes(x = hh, y = `50%`), size = point_size, colour = "#6297B2") +
  geom_errorbar(data = prev_mod, aes(x = hh, ymin = `2.5%`, ymax = `97.5%`), size = 2.5, colour = "#6297B2", width = 0, alpha = 0.5) +
  geom_point(data = prev_data, aes(x = hh, y = `50%`), size = point_size, colour = "black") +
  geom_errorbar(data = prev_data, aes(x = hh, ymin = `2.5%`, ymax = `97.5%`), colour = "black", width = 0.065) +
  scale_x_discrete(labels = c("Background \n",
                              "Subclinical \n smear -ve",
                              "Subclinical \n smear +ve",
                              "Clinical \n smear -ve",
                              "Clinical \n smear +ve")) +  
  scale_y_continuous(breaks = seq(0, 1, 0.1), limits = c(0, 1), expand = c(0, 0)) +
  labs(title = study_name,
       x = "Household type",
       y = "Prevalence of infection") +
  theme(text = element_text(family = "sans"),
        panel.background = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.major.x = element_blank(),
        axis.line = element_line(),
        axis.line.x.bottom = element_line(size = line_thickness),
        axis.line.y.left = element_line(size = line_thickness),
        axis.ticks = element_line(size = line_thickness),
        axis.title.x.bottom = element_text(vjust = -2, margin = margin(b = 20), size = axis_title_size),
        axis.title.y.left = element_text(vjust= 3, margin = margin(l = 15), size = axis_title_size),
        axis.text.x.bottom = element_text(vjust = 0.3, hjust = 0.5, size = x_axis_text_size-2.5, angle = 0),
        axis.text.y.left = element_text(size = y_axis_text_size),
        plot.title = element_text(size = title_size, vjust = 6, hjust = title_align, margin = margin(t = 20), face = title_face)) +
  theme(legend.position = "none")

ggsave(fig_1, file = paste0("outputs/supp_mats/prev_", model_name, ".png"), width = 12, height = 12, units = "cm", dpi = 300)


### Trace plot

fig_2 = mcmc_trace(fit,
                   pars = pars) +
  labs(title = study_name) +
  xaxis_text(on = TRUE, size = 8) +
  theme(plot.title = element_text(family = "sans", size = title_size-4, vjust = 6, hjust = title_align, margin = margin(t = 15), face = title_face))

ggsave(fig_2, file = paste0("outputs/supp_mats/trace_", model_name, ".png"), width = 12, height = 12, units = "cm", dpi = 300)


### Correlation plot

fig_3 = mcmc_pairs(fit,
                   pars = pars,
                   off_diag_args = list(size = 0.35, alpha = 0.15),
                   grid_args = list(top= study_name))

ggsave(fig_3, file = paste0("outputs/supp_mats/corr_", model_name, ".png"), width = 12, height = 12, units = "cm", dpi = 300)


### Autocorrelation plot

fig_4 = mcmc_acf(fit, pars = pars,
                 lags = 25) +
  labs(title = study_name) +
  theme(plot.title = element_text(family = "sans", size = title_size-4, vjust = 6, hjust = title_align, margin = margin(t = 15), face = title_face))

ggsave(fig_4, file = paste0("outputs/supp_mats/auto_", model_name, ".png"), width = 12, height = 12, units = "cm", dpi = 300)


### Detailed model results (n_eff, Rhat, mean, mcse, sd and sample quantiles)

launch_shinystan(fit)






