


library(tidyverse)
library (here)
library(afex)
library(ggsci)
library(afex)
library("ggsci")
library(emmeans)
library(patchwork)
options(scipen=999) # turn off scientific notations


# -------------------------------------------------------- #
# --------------- Descriptive Statistics ----------------- #
# -------------------------------------------------------- #

data_exp1 <- read_csv(here("cleaned_data","cleaned_data_exp1.csv"))




# aggregated_data_exp1 <- data_exp1 %>%
#   group_by(stage, group) %>%
#   mutate(depression_score = mean(depression_score)) %>%
#   ungroup()
# 
# 
# # how many participants in total? 131
# data_exp1 %>% summarise(n= n_distinct(subject))
# 
# # how many participants in each group?
# data_exp1 %>% group_by(subject) %>% filter(row_number()==1) %>% ungroup () %>% group_by(group) %>% count()



narcissism_data <- read_csv(here("cleaned_data","narcissism_data.csv"))
narcissism_data %>% summary()
narcissism_data %>% skimr::skim()
narcissism_data %>% psych::describe()


### Exercise

#1: Open the dataset called `treatment_data.csv` and do a descriptive analysis:
treatment_data <- read_csv(here("cleaned_data","treatment_data.csv"))
treatment_data %>% summary()
treatment_data %>% skimr::skim()
treatment_data %>% psych::describe()

#2: Do the same thing for the `memory_data.csv`.
memory_data <- read_csv(here("cleaned_data","memory_data.csv"))
memory_data %>% 
  group_by(time) %>%
  skimr::skim()


#3: Open the dataset called `ghasemi_brightness_exp4.csv` and do a descriptive analysis:
ghasemi_data <- read_csv(here("cleaned_data","ghasemi_brightness_exp4.csv"))

ghasemi_data %>% summarise(n = n_distinct(participant)) # number of participants:200

ghasemi_data %>% group_by (participant) %>% 
  filter (row_number()==1) %>% 
  group_by (gender) %>% 
  summarise(n= n()) %>% 
  ungroup() # 183 female, 17 male

ghasemi_data %>% dplyr::select (age, cog_ability) %>% skimr::skim() # mean and sd for age and cognitive ability


# -------------------------------------------------------- #
# ---------------------- Analysis ------------------------ #
# -------------------------------------------------------- #


############## ----------- t-test  -------------################

# t.test (indep)
t.test(anxiety~treatment, data= treatment_data)
t.test(depression~treatment, data= treatment_data)
t.test(life_satisfaction~treatment, data= treatment_data)


# Is there a difference between groups at the first stage?
data_exp1 %>% 
  group_by(group) %>% 
  filter(stage=='stage1') %>% 
  ungroup () %>%
  t.test(depression_score~group, data = ., paired=FALSE)

# t.test (paired)
t.test(memory_score~time, data= memory_data, paired= T)


# Is there a difference between ratings of stage2 and stage4?
data_exp1 %>% 
  filter(stage=='stage2' | stage=='stage4') %>% 
  ungroup () %>%
  t.test(depression_score~stage, data = ., paired=TRUE)


# --------- John Back Down  -----------#

john_data <- read_csv(here("cleaned_data","john_backdown_exp2.csv"))


t.test(intelligent~back_down, data = john_data, paired=FALSE)
t.test(confident~back_down, data = john_data, paired=FALSE)



############## ----------- ANOVA  -------------################


data_exp1 <- read_csv(here("cleaned_data","cleaned_data_exp1.csv"))

str(data_exp1)

data_exp1 %>% group_by(group) %>% skimr::skim()
data_exp1 %>% group_by(stage) %>% skimr::skim()

data_exp1 %>%
  group_by(stage, group) %>%
  mutate(depression_score = mean(depression_score)) %>%
  ungroup() %>%
  ggplot(aes(x=factor(stage), y= depression_score, group= group, color= group)) +
  geom_line(aes(linetype= group)) +
  geom_point(size= 5)



aov_m1 <- aov_car (depression_score ~ group*stage +
                     Error(subject/stage), data = data_exp1)  

aov_m1 %>% summary()

emmeans(aov_m1, 'group')
emmeans(aov_m1, 'stage')
pairs(emmeans(aov_m1, 'stage'), adjust= 'holm')
emmeans(aov_m1, "group", by= "stage")# interaction
update(pairs(emmeans(aov_m1, "group", by= "stage")), by = NULL, adjust = "holm") # interaction

data_exp1 %>% group_by(group) %>% skimr::skim()
  

afex_plot(aov_m1, x = "stage", trace = "group", error='between') + theme_bw()

afex_plot(aov_m1, x = "stage", trace = "group", error='between',
          line_arg = list(size=1.3),
          point_arg = list(size=3.5),
          data_arg = list(size= 2, color= 'grey'),
          data_plot = FALSE,
          mapping = c("linetype", "shape", "color"),
          legend_title = "Group") +
  labs(y = "Truth Likelihhod Estimate", x = "") +
  theme_bw()+ # remove the grey background and grid
  theme(axis.text=element_text(size=13),
        axis.title = element_text(size = 13),
        legend.text=element_text(size=13),
        legend.title=element_text(size=13),
        #legend.position=c(0.8, 0.88),
        legend.position='bottom',
        legend.key.size = unit(1, "cm"),
        legend.background = element_rect(colour = 'black', fill = 'white', linetype='solid'))+
  scale_color_nejm()

afex_plot(aov_m1, x = "stage", trace = "group", error='between',
          line_arg = list(size=1.3),
          point_arg = list(size=3.5),
          data_arg = list(size= 1, color= 'grey'),
          data_geom = geom_violin,
          mapping = c("linetype", "shape", "fill"),
          legend_title = "Group") +
  labs(y = "Truth Likelihhod Estimate", x = "") +
  theme_bw()+ # remove the grey background and grid
  theme(axis.text=element_text(size=13),
        axis.title = element_text(size = 13),
        legend.text=element_text(size=13),
        legend.title=element_text(size=13),
        legend.position='bottom',
        legend.key.size = unit(1, "cm"),
        legend.background = element_rect(colour = 'black', fill = 'white', linetype='solid'))+
  scale_color_d3() +
  scale_fill_d3()


afex_plot(aov_m1, x = "stage", trace = "group", error='between',
          line_arg = list(size=1),
          point_arg = list(size=3.5),
          data_arg = list(size= 1, color= 'grey', width=.4),
          data_geom = geom_boxplot,
          mapping = c("linetype", "shape", "fill"),
          legend_title = "Group") +
  labs(y = "Truth Likelihhod Estimate", x = "") +
  theme_bw()+ # remove the grey background and grid
  theme(axis.text=element_text(size=13),
        axis.title = element_text(size = 13),
        legend.text=element_text(size=13),
        legend.title=element_text(size=13),
        legend.position='bottom',
        legend.key.size = unit(1, "cm"),
        legend.background = element_rect(colour = 'black', fill = 'white', linetype='solid'))+
  scale_color_simpsons() +
  scale_fill_simpsons()


# --------- Rotello Shooter Bias  -----------#

# load the general data file
rotello_data <- read_csv(here("cleaned_data","rotello_shooter_exp1.csv"))

# Analyses that assume a linear ROC: ANOVA
rotello_aov <- aov_car (resp ~ target*prime +
                          Error(subject/target*prime), data = rotello_data)

rotello_aov
knitr::kable(nice(rotello_aov))

emmeans(rotello_aov, 'target')

afex_plot(rotello_aov, x = "target", trace = "prime", error='between') + theme_bw()




############## ----------- Correlation  -------------################

narcissism_data_cor <- narcissism_data %>%
  select(-subject)
#-- Base R:
cor(narcissism_data_cor, method = "pearson",  use = "complete.obs")

# if we want the correlation for two specific variables
cor.test(narcissism_data_cor$psychopathy,narcissism_data_cor$self_esteem, method = "pearson",  use = "complete.obs")

#-- Psych library:
psych::pairs.panels(narcissism_data_cor, method = "pearson", hist.col = "#00AFBB",  stars = T)

#-- Correlation library:
# install.packages("devtools")
# devtools::install_github("easystats/correlation")
#library("correlation")
correlation::correlation(narcissism_data_cor)
correlation::correlation(narcissism_data_cor) %>% summary()

#-- apaTables library: install.packages("apaTables",dep=T)
narcissism_data_cor %>% 
  apaTables::apa.cor.table(filename="./outputs/CorMatrix.doc", show.conf.interval=T)



# Always check the scatterplot of your data and correlations!
library(cannonball)
plot_r(r = 0.404, n = 131)




#--------- Pennycook AOTE  -----------#

pennycook_data <- read_csv(here("cleaned_data","pennycook_aote_exp1.csv")) 


# If your data contain missing values, use the following R code to handle missing values by case-wise deletion.
cor(pennycook_data, method = "pearson",  use = "complete.obs")

#library(psych)
pennycook_data %>% 
  psych::pairs.panels(method = "pearson", hist.col = "#00AFBB", density = T, ellipses = F, stars = T)


correlation::correlation(pennycook_data) %>% summary()


#library(apaTables)
pennycook_data %>% 
  apaTables::apa.cor.table(filename="./outputs/CorMatrix3.doc", show.conf.interval=T)



###### Multiple Regression

# Here, we do single and multiple linear regression on the narcissism_data

m1 <- lm(mental_health ~ narcissism, data = narcissism_data)

summary(m1)

# This ~ is called tilde, and in regression it means ‘predicted from’. (We can’t write ‘=’ because that would confuse R, plus we’re not saying the outcome is equal to the predictor, just that the outcome has something to do with the predictor.)

m2 <- lm(mental_health ~ narcissism + psychopathy, data= narcissism_data)

summary(m2)


# Stepwise regressions are generally frowned upon by statisticians, and R is not as good at running automated stepwise regressions as some other statistics programs we could mention. However, I’m still going to tell you how to do them, but be aware that if you can’t do a stepwise regression in the same way in R that you can in another program, that’s because the other program was written 40 years ago when people didn’t know better.
# because stepwise techniques are influenced by random variation in the data and so seldom give replicable results if the model is retested.

# For this reason stepwise methods are best avoided except for exploratory model building. If you must do a stepwise regression then it is advisable to cross-validate your model by splitting the data.

m3 <- step(lm(mental_health ~ narcissism + psychopathy, data= narcissism_data), direction = "forward")

summary(m3)

# Remember that when R wants to show small or large numbers it uses exponential notation. So 2.2e–16 means “2.2 with the decimal place moved 16 places to the left, and add zeros as necessary”, which means: 0.00000000000000022. That’s a very small number indeed.


rm(m3)


# To get the standardized version of the b-vales, which are easier to interpret (as they are not dependent on the units of the variable measurement). To obtain that, we need to use the QuantPsyc package and the lm.beta() function

library(QuantPsyc)

lm.beta(m2)

# The output of lm.beta tell us the number of SD by which the outcome will change as a result of one SD change in the predictor. As standardized beta are directly comparable, they provide a better insight into the 'importance' of a predictor in a model.

confint(m2)


# Comparing regression models using R. If you run hierarchical regression, you can use anova() function to examine if adding a predictor significantly improved the model. It's worth noting that the second model must contain everything that was in the first model plus sth new, and the third model must contain everything in the second model plus sth new and so on.
anova(m1, m2)



# Outliers and influential cases
residuals(m2)

narcissism_data$residual = residuals(m2)


# One statistic that does consider the effect of a single case on the model as a whole is distance. Cook’s distance is a measure of the overall influence Cook’s of a case on the model. Look at the values of Cook’s distance: any value above 1 indicates a case that might be influencing the model.
narcissism_data$cook_distance = cooks.distance(m2)


# Look at standardized residuals and check that no more than 5% of cases have absolute values above 2, and that no more than about 1% have absolute values above 2.5. Any case with a value above about 3 could be an outlier.
narcissism_data$standard_residual2 = rstandard(m1)


# assessing the assumptions

library(car)

# assessing the assumption of independent errors: the closer the D-W statistic to 2 is better and less significant
car::dwt(m2)

# assessing the assumption of multicollinearity: vif lower than 0.1 or larger than 10 is of concern. Below that is tolerance 1/vif and it is a concern if it is below 0.2
car::vif(m2)

1/vif(m2)

plot(m2)

# Linearity of the errors
hist(narcissism_data$standard_residual2)


library(gvlma)

summary(gvlma(m1))

plot(gvlma(m1))


#--------- Trémolière Climate Literacy  -----------#

Tremoliere_data <- read_csv(here("cleaned_data","tremoliere_data_exp1.csv"))


# Multiple linear regression with variation in R square in 4 steps
Tremoliere_reg=lm(Climato ~ Age+ Gender+ Education+ BeliefInSciencetotal+ Literacy+ Numtotal+ CognitiveReflection,
                  data=Tremoliere_data)

broom::tidy(Tremoliere_reg)
broom::glance(Tremoliere_reg)









