

library(tidyverse)
library (here)
options(scipen=999) # turn off scientific notations


# read the raw data
raw_data <- read_csv(here("raw_data","raw_data_exp1.csv"))
head(raw_data)


# Exercise: read the UNICEF data
unicef_data <- read_csv(here("cleaned_data","unicef_u5mr.csv"))


# Pick 3 columns: subject, age, gender
selected_data <- select(raw_data, subject, age, gender)

# Pick male participants
fil_male <- filter(raw_data, gender == "Male")
fil_male_and_g25 <- filter(raw_data, gender == "Male" & age > 25 )
fil_male_or_g25 <- filter(raw_data, gender == "Male" | age > 25 )

# order participants based on their age
arranged_data <- arrange(raw_data, age)
arranged_desc <- arrange(raw_data, desc(age))

# Create a column to show if the participant has finished the task or not
mutated_data <- mutate (raw_data, finished= case_when(progress==100~ "Yes",T~ "No"))

# summarize participants age and sd:
summarised_data <- summarise(raw_data, mean= mean(age, na.rm=T))

# pipe functions %>%
raw_data %>% 
  summarise(., mean= mean(age, na.rm=T))

raw_data %>% 
  summarise(mean= mean(age, na.rm=T))

# calculate the mean of younger than 25 participants only
raw_data %>% 
  filter (age < 25) %>%
  summarise(mean= mean(age, na.rm=T),
            sd= sd (age, na.rm=T))

# calculate the mean of younger than 25 participants only for each gender separately
raw_data %>% 
  filter (age < 25) %>%
  group_by(gender) %>%
  summarise(mean= mean(age, na.rm=T),
            sd= sd (age, na.rm=T)) %>%
  ungroup ()

# exercise1: Create a column to show if participant is older than 23 or not and then calculate 
# sleep quality (`sleep_quality`) mean for each group separately
raw_data %>%
  mutate(age_group = case_when(age > 23 ~ "greater than 23", T~ "younger than 23")) %>%
  group_by(age_group) %>%
  summarise(sleep_quality = mean(sleep_quality, na.rm=T))

# exercise2: add the anxiety total score (sum) to the dataframe and then convert subject column to factor
anxiety_data <- raw_data %>%
  mutate(anxiety_total= anxiety1+anxiety2+anxiety3+anxiety4+anxiety5+anxiety6+anxiety7+anxiety8) %>%
  mutate(subject= factor(subject))

str(anxiety_data)


# pivoting your data
long_data <- raw_data %>%
  select(subject, stage1_cbt:stage5_cbt,stage1_dynamic:stage5_dynamic) %>%
  pivot_longer(cols = c(stage1_cbt:stage5_dynamic), names_to = 'stage', values_to = 'depression_score')

wide_data <- long_data %>%
  pivot_wider(names_from = stage, values_from= depression_score)
  

# Exercise: pivot
library(janitor)
head(unicef_data)
colnames(unicef_data)

unicef_data_cleaned <- unicef_data %>%
  clean_names()

head(unicef_data_cleaned)
colnames(unicef_data_cleaned) 

# backtick `
unicef_long_data <- unicef_data_cleaned %>% 
  pivot_longer(cols = c(u5mr_1950:u5mr_2015), names_to = 'year', values_to = 'u5mr')
unicef_wideg_data <- unicef_long_data %>% 
  pivot_wider(names_from = 'year', values_from = 'u5mr')



cleaned_data <- raw_data %>% 
  filter(progress == 100) %>% # filter out unfinished participants
  select(-consent_form) %>% #remove some useless columns
  # create a total score for our questionnaire
  mutate(anxiety_total= anxiety1+anxiety2+anxiety3+anxiety4+anxiety5+anxiety6+anxiety7+anxiety8) %>%
  select(-anxiety1:-anxiety8) %>%
  # make our dataframe long
  pivot_longer(cols = c(stage1_cbt:stage5_cbt,stage1_dynamic:stage5_dynamic),names_to = 'stage',values_to = 'depression_score') %>% 
  #pivot_wider(names_from = stage, values_from= depression_score) # this code change our dataframe back to wide
  filter(!is.na(depression_score)) %>% #remove rows with depression_score == NA
  mutate(stage= gsub("_.*", "", stage)) %>%
  select (subject, age, gender, group, stage, depression_score, anxiety_total, sleep_quality, life_satisfaction)
         

str(cleaned_data)
dim(cleaned_data)

write_csv(cleaned_data, here("cleaned_data","cleaned_data_exp1.csv"))




