library(ggplot2)
library(reshape2)
library(data.table)
library(patchwork)
library(plyr)


### Plot parameters 

# Plot appearance

 col_africa = "#984447"
 col_asia = "#468C98"
 col_studies = "#A569BD"
 col_summary = "#808B96"
 col_sub = "#2673ad"
 col_clin = "#2673ad"


### Fig 1: Odds ratios 

# Fig 1A: smear-negative versus positive 

Results_1A <- read.csv("interim_outputs/odds_smear.csv")
Results_1A$type <- "country"
Results_1A$type [Results_1A$survey_year == "Summary" ] <- "Global"
Results_1A$survey_year <- factor(Results_1A$survey_year, levels = Results_1A$survey_year[rev(order(Results_1A$survey_year))])

theme=theme_bw()+
  theme(
    panel.grid.minor=element_blank())

fig_1A <- ggplot() +
  geom_errorbarh(data = Results_1A, mapping = aes(y=survey_year, xmin=ci_lower, xmax=ci_upper), height=0.16, position=position_dodge(.9)) +
  geom_point(data = subset(Results_1A, survey_year != "Summary"), aes(x=point_value, y=survey_year, fill=type), shape = 22, size = 4.5 ) +
  geom_point(data = subset(Results_1A, survey_year == "Summary"), aes(y = survey_year, x = point_value, fill=type), shape = 23, size = 4.5 ) +
  geom_vline(xintercept = 1, size = 0.4, linetype = "dashed") + 
  scale_fill_manual(values=c("country"=col_studies, "Global"=col_summary)) +
  scale_x_continuous(lim = c(0.1,100), trans = "log10", expand = c(0, 0), labels = c(0.1,1,10,100)) +
  theme + 
  facet_grid(type~., scales = 'free', space ='free') + theme(strip.background = element_blank(), strip.text.y = element_blank()) + theme(legend.position="none") +
  labs(title="Smear-positive vs. smear-negative") + xlab("Odds ratio") + ylab("Study") + theme(axis.title.x = element_text(size = 14, hjust=0.5, vjus = -0.5)) +
  theme(plot.title = element_text(size = 13), 
        plot.margin = unit(c(10,20,10,10), "pt"),
        axis.title.y = element_blank(), #element_text(size = 15, vjust = 3),
        axis.text.y = element_text(size = 11),
        axis.text.x = element_text(size = 11),
        axis.ticks.y=element_blank())

# Fig 1B: subclinical versus clinical 

Results_1B <- read.csv("interim_outputs/odds_symp.csv")
Results_1B$type <- "country"
Results_1B$type [Results_1B$survey_year == "Summary" ] <- "Global"
Results_1B$survey_year <- factor(Results_1B$survey_year, levels = Results_1B$survey_year[rev(order(Results_1B$survey_year))])

theme=theme_bw()+
  theme(
    panel.grid.minor=element_blank())

fig_1B <- ggplot() +
  geom_vline(xintercept = 1, size = 0.4, linetype = "dashed") + 
  geom_errorbarh(data = Results_1B, mapping=aes(y=survey_year, xmin=ci_lower, xmax=ci_upper), height=0.16, position=position_dodge(.9)) +
  geom_point(data = subset(Results_1B, survey_year != "Summary"), aes(x=point_value, y=survey_year, fill=type), shape = 22, size = 4.5, alpha = 1) +
  geom_point(data = subset(Results_1B, survey_year == "Summary"), aes(y = survey_year, x = point_value, fill=type), shape = 23, size = 4.5 ) +
  scale_fill_manual(values=c("country"=col_studies, "Global"=col_summary)) +
  scale_x_continuous(lim = c(0.1,100), trans = "log10", expand = c(0, 0), labels = c(0.1,1,10,100)) +
  facet_grid(type~., scales = 'free', space ='free') + 
  labs(title="Clinical vs. subclinical") + xlab("Odds ratio") +  
  theme + 
  theme(axis.title.x = element_text(size = 14, hjust=0.5, vjust = -0.5), 
        axis.title.y=element_blank(),
        strip.background = element_blank(),
        strip.text.y = element_blank(),
        legend.position="none",
        plot.title = element_text(size = 13), 
        plot.margin = unit(c(10,10,10,10), "pt"),
        axis.text.y=element_blank(),
        axis.text.x = element_text(size = 11),
        axis.ticks.y=element_blank())

fig_1 = fig_1A + fig_1B 

ggsave(fig_1, file = "outputs/main_paper/fig_1.png", width = 20, height = 11, units = "cm", dpi = 300)


### Fig 2B: Durations  

Results_2B <- read.csv("data/duration_data.csv")

fig_2B <- ggplot() +
  geom_bar(data = Results_2B, aes(x=point_value, y=status, fill = status), stat = "identity", alpha = 0.85) +
  scale_fill_manual(values=c("clinical"=col_clin, "subclinical"=col_sub)) +
  geom_errorbarh(data = Results_2B, aes(y = status, xmin = ci_lower, xmax = ci_upper), size = 0.6, height = 0.08) +
  scale_x_continuous(limits=c(0,18), breaks = seq(0,18,3), expand = c(0, 0)) +
  scale_y_discrete(labels = c("Clinical","Subclinical")) + 
  theme + theme(axis.title.y=element_blank()) + 
  xlab("Duration of disease (months)") +
  theme(legend.position = "none") +
  theme(plot.title = element_blank(), 
        axis.title.x = element_text(size = 16, hjust=0.5, vjust = -0.5), 
        axis.text.y = element_text(size = 16),
        axis.text.x = element_text(size = 13),
        strip.background = element_blank(),
        strip.text.y = element_blank(),
        legend.position="none",
        plot.margin = unit(c(10,10,10,10), "pt"),
        axis.ticks.y=element_blank())

ggsave(fig_2B, file = "outputs/main_paper/fig_2B.png", width = 20, height = 8, units = "cm", dpi = 300)


### Fig 3: Relative infectiousness 

# Fig 3A: Subclinical 

Results_3A <- read.csv("interim_outputs/rel_inf_s.csv")
Results_3A$type <- "country"
Results_3A$type [Results_3A$survey_year == "Summary" ] <- "Global"
Results_3A$survey_year <- factor(Results_3A$survey_year, levels = Results_3A$survey_year[rev(order(Results_3A$survey_year))])

fig_3A <- 
  ggplot() +
  geom_errorbarh(Results_3A, mapping=aes(y=survey_year, xmin=ci_lower, xmax=ci_upper), height=0.16, position=position_dodge(.9)) +
  geom_point(data = subset(Results_3A, survey_year != "Summary"), aes(x=point_value, y=survey_year, fill=type), shape = 22, size = 4.5 ) +
  geom_point(data = subset(Results_3A, survey_year == "Summary"), aes(y = survey_year, x = point_value, fill=type), shape = 23, size = 4.5 ) +
  facet_grid(type~., scales = 'free', space ='free') + 
  scale_fill_manual(values=c("country"= col_studies, "Global"= col_summary)) +
  scale_x_continuous(limits=c(0.01,100), expand = c(0, 0), trans = 'log10', labels = c(0.01,0.1,1,10,100)) +
  labs(title="Relative Infectiousness") +
  xlab("Infectiousness of subclinical TB \n relative to clinical") + 
  ylab("Study") + 
  theme + 
  theme(strip.background = element_blank(), 
        strip.text.y = element_blank(),
        legend.position = "none",
        plot.margin = unit(c(10,15,10,10), "pt"),
        plot.title = element_blank(), 
        axis.title.y = element_blank(), 
        axis.title.x = element_text(size = 17, hjust=0.5, vjust = -0.6),
        axis.text.y = element_text(size = 17),
        axis.text.x = element_text(size = 14),
        axis.ticks.y=element_blank())

ggsave(fig_3A, file = "outputs/main_paper/fig_3A.png", width = 20, height = 11, units = "cm", dpi = 300)

# Fig 3B: Smear negative 

Results_3B <- read.csv("interim_outputs/rel_inf_n.csv")
Results_3B$type <- "country"
Results_3B$type [Results_3B$survey_year == "Summary" ] <- "Global"
Results_3B$survey_year <- factor(Results_3B$survey_year, levels = Results_3B$survey_year[rev(order(Results_3B$survey_year))])

fig_3B <- 
  ggplot() +
  geom_errorbarh(Results_3B, mapping=aes(y=survey_year, xmin=ci_lower, xmax=ci_upper), height=0.16, position=position_dodge(.9)) +
  geom_point(data = subset(Results_3B, survey_year != "Summary"), aes(x=point_value, y=survey_year, fill=type), shape = 22, size = 4.5 ) +
  geom_point(data = subset(Results_3B, survey_year == "Summary"), aes(y = survey_year, x = point_value, fill=type), shape = 23, size = 4.5 ) +
  facet_grid(type~., scales = 'free', space ='free') + 
  scale_fill_manual(values=c("country"= col_studies, "Global"= col_summary)) +
  scale_x_continuous(limits=c(0.01,100), expand = c(0, 0), trans = 'log10', labels = c(0.01,0.1,1,10,100)) +
  labs(title="Relative Infectiousness") +
  xlab("Infectiousness of smear-negative TB \n relative to smear-positive") + 
  ylab("Study") + 
  theme + 
  theme(strip.background = element_blank(), 
        strip.text.y = element_blank(),
        legend.position = "none",
        plot.margin = unit(c(10,15,10,10), "pt"),
        plot.title = element_blank(), 
        axis.title.y = element_blank(), #element_text(size = 15, vjust = 3),
        axis.title.x = element_text(size = 17, hjust=0.5, vjust = -0.6),
        axis.text.y = element_text(size = 17),
        axis.text.x = element_text(size = 14),
        axis.ticks.y=element_blank())

ggsave(fig_3B, file = "outputs/main_paper/fig_3B.png", width = 20, height = 11, units = "cm", dpi = 300)


### Fig 4A-C: Prevalence  

# Fig 4A: Proportion of prevalent TB that is subclinical 

Results_4A <- read.csv("interim_outputs/prop_prev_sub_all.csv")
Bar_data <- Results_4A[,c(1,3)]
long <- melt(setDT(Bar_data), id.vars = c("survey_year"), var2iable.name = "contribution")   
long$type <- "country"
long$type [long$survey_year == "Summary" ] <- "Global"

Err_bar <- as.data.table(Results_4A[,c(1,4,5)])
region <- as.data.table(Results_4A[,c(1,2)])
long <- as.data.table(long)
long <- join(long, Err_bar, by="survey_year", type="inner")
long <- join(long, region, by="survey_year", type="inner")
long$region [long$survey_year == "Summary" ] <- "Global"

long$survey_year <- factor(long$survey_year, levels = long$survey_year[rev(order(long$survey_year))])

theme=theme_bw()+
  theme(
    panel.grid.minor=element_blank())

fig_4A <- ggplot() +
  geom_bar(data = subset(long, survey_year != "Summary"), aes(x=100*value, y=survey_year, fill=region), stat = "identity") +
  geom_bar(data = subset(long, survey_year = "Summary"), aes(x=100*value, y=survey_year, fill=region), stat = "identity") +
  geom_errorbarh(data=long, mapping=aes(y=survey_year, xmin=100*ci_lower, xmax=100*ci_upper), height=.3, position=position_dodge(.9), size = 0.35) +
  scale_fill_manual(values=c("Africa"= col_africa, "Asia"= col_asia, "Global"= col_summary)) +
  theme +
  theme(legend.position = "none") + ylab("Survey")+ labs(title = "% subclinical (prevalent TB)") +
  scale_x_continuous(limits=c(0,100), expand = c(0, 0)) +
  facet_grid(type~., scales = 'free', space ='free') + theme(strip.background = element_blank(), strip.text.y = element_blank(), axis.title.x = element_blank()) + 
  theme(plot.title = element_text(size = 10.5), 
        plot.margin = unit(c(10,10,10,10), "pt"),
        axis.title.y = element_blank(),
        axis.text.y = element_text(size = 10),
        axis.ticks.y=element_blank())

# Fig 4B: Proportion of subclinical TB that is smear-positive

Results_4B <- read.csv("interim_outputs/prop_sub_pos_all.csv")
Results_4B$type <- "country"
Results_4B$type [Results_4B$survey_year == "Summary" ] <- "Global"
Results_4B$region [Results_4B$survey_year == "Summary" ] <- "Global"
Results_4B$survey_year = factor(Results_4B$survey_year, levels = Results_4B$survey_year[rev(order(Results_4B$survey_year))])

fig_4B <- ggplot() +
  geom_bar(data = subset(Results_4B, survey_year != "Summary"), aes(x=100*point_value, y=survey_year, fill=region), stat = "identity") +
  geom_bar(data = subset(Results_4B, survey_year = "Summary"), aes(x=100*point_value, y=survey_year, fill=region), stat = "identity") +
  geom_errorbarh(data=Results_4B, mapping=aes(y=survey_year, xmin=100*ci_lower, xmax=100*ci_upper), height=.3, position=position_dodge(.9), size = 0.35) +
  theme(legend.position = "none") + 
  scale_fill_manual(values=c("Africa"= col_africa, "Asia"= col_asia, "Global"= col_summary)) +
  scale_x_continuous(limits=c(0,100), expand = c(0, 0)) +
  theme + 
  theme(axis.title.y=element_blank(), 
        axis.text.y=element_blank(),
        axis.title.x = element_blank()) +  
  facet_grid(type~., scales = 'free', space ='free') + theme(strip.background = element_blank(), strip.text.y = element_blank()) + theme(legend.position="none") +
  labs(title="% smear-positive (subclinical)") +
  theme(plot.title = element_text(size = 10.5), 
        plot.margin = unit(c(10,10,10,10), "pt"),
        axis.ticks.y=element_blank())

# Fig 4C: Proportion of clinical TB that is smear-positive

Results_4C <- read.csv("interim_outputs/prop_clin_pos_all.csv")
Results_4C$type <- "country"
Results_4C$type [Results_4C$survey_year == "Summary" ] <- "Global"
Results_4C$region [Results_4C$survey_year == "Summary" ] <- "Global"
Results_4C$survey_year = factor(Results_4C$survey_year, levels = Results_4C$survey_year[rev(order(Results_4C$survey_year))])

fig_4C <- ggplot() +
  geom_bar(data = subset(Results_4C, survey_year != "Summary"), aes(x=100*point_value, y=survey_year, fill=region), stat = "identity") +
  geom_bar(data = subset(Results_4C, survey_year = "Summary"), aes(x=100*point_value, y=survey_year, fill=region), stat = "identity") +
  geom_errorbarh(data=Results_4C, mapping=aes(y=survey_year, xmin=100*ci_lower, xmax=100*ci_upper), height=.3, position=position_dodge(.9), size = 0.35) +
  theme(legend.position = "none") + 
  scale_fill_manual(values=c("Africa"= col_africa, "Asia"= col_asia, "Global"= col_summary)) +
  scale_x_continuous(limits=c(0,100), expand = c(0, 0)) +
  theme+
  theme(axis.title.y=element_blank(),axis.text.y=element_blank()) +  
  facet_grid(type~., scales = 'free', space ='free') + 
  theme(strip.background = element_blank(), strip.text.y = element_blank(), axis.title.x = element_blank()) + theme(legend.position="none") +
  labs(title="% smear-positive (clinical)")+
  theme(plot.title = element_text(size = 10.5), 
        plot.margin = unit(c(10,10,10,10), "pt"),
        axis.ticks.y=element_blank())

# Combined plot

fig_4ABC = fig_4A + fig_4B + fig_4C 

ggsave(fig_4ABC, file = "outputs/main_paper/fig_4A-C.png", width = 20, height = 12, units = "cm", dpi = 300)


### Fig 4D: Contribution to transmission   

Results_4Di <- read.csv("interim_outputs/prop_trans_setting.csv")
Results_4Dii <- read.csv("interim_outputs/prop_trans_summ.csv")

Results_4D = rbind(Results_4Di,Results_4Dii)
Results_4D$type <- "country"
Results_4D$type [Results_4D$survey_year == "Global" ] <- "Global"
Results_4D$survey_year <- factor(Results_4D$survey_year, levels = Results_4D$survey_year[rev(order(Results_4D$survey_year))])

Plot_4D <- ggplot() +
  geom_bar(data = subset(Results_4D, survey_year != "Global"), aes(x=point_value, y=survey_year, fill=region), stat = "identity") +
  geom_bar(data = subset(Results_4D, survey_year = "Global"), aes(x=point_value, y=survey_year, fill=region), stat = "identity") +
  geom_errorbarh(data=Results_4D, mapping=aes(y=survey_year, xmin=ci_lower, xmax=ci_upper), height=0.3, size = 0.4, position=position_dodge(.9)) +
  scale_fill_manual(values=c("Africa"=col_africa, "Asia"=col_asia, "Global"=col_summary)) +
  scale_x_continuous(limits=c(0,100), expand = c(0, 0)) +
  facet_grid(type~., scales = 'free', space ='free') + 
  xlab("% transmission from subclinical cases") +
  ylab("Survey") +
  theme +
  theme(legend.position = "none") + 
  theme(plot.title = element_blank(), 
        axis.title.x = element_text(size = 12, hjust=0.5, vjust = -0.5), 
        axis.title.y = element_blank(), 
        axis.text.y = element_text(size = 11),
        axis.text.x = element_text(size = 10),
        strip.background = element_blank(),
        strip.text.y = element_blank(),
        legend.position="none",
        plot.margin = unit(c(10,10,10,10), "pt"),
        axis.ticks.y=element_blank())

ggsave(Plot_4D, file = "outputs/main_paper/fig_4D.png", width = 20, height = 12, units = "cm", dpi = 300)










