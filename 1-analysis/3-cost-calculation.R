# Calculating some descriptives
# 

library(tidyverse)
library(janitor)
mydata<-read_csv("./0-data/Root_Insurance_data.csv")%>%
  set_names(c("currently_insured", "num_vehicles", "num_drivers", "married", "bid", "rank", "click",
              "policies_sold"))

# Calculate cost per policies sold by currently insured
temp1<-mydata%>%
  mutate(cost=bid*click)%>%
  filter(click==T)%>%
  group_by(currently_insured)%>%
  summarise(total_cost=sum(cost))%>%
  ungroup()

mydata%>%
  filter(click==T & policies_sold==1)%>%
  group_by(currently_insured)%>%
  summarise(number_sold=n())%>%
  ungroup()%>%
  left_join(temp1)%>%
  mutate(cost_per_sold=total_cost/number_sold)

# Calculate cost per policies sold by marital status

temp1<-mydata%>%
  mutate(cost=bid*click)%>%
  filter(click==T)%>%
  group_by(married)%>%
  summarise(total_cost=sum(cost))%>%
  ungroup()

mydata%>%
  filter(click==T & policies_sold==1)%>%
  group_by(married)%>%
  summarise(number_sold=n())%>%
  ungroup()%>%
  left_join(temp1)%>%
  mutate(cost_per_sold=total_cost/number_sold)



# Calculate cost per policies sold by number of vehicles

temp1<-mydata%>%
  mutate(cost=bid*click)%>%
  filter(click==T)%>%
  group_by(num_vehicles)%>%
  summarise(total_cost=sum(cost))%>%
  ungroup()

mydata%>%
  filter(click==T & policies_sold==1)%>%
  group_by(num_vehicles)%>%
  summarise(number_sold=n())%>%
  ungroup()%>%
  left_join(temp1)%>%
  mutate(cost_per_sold=total_cost/number_sold)


# Calculate cost per policies sold by number of drivers

temp1<-mydata%>%
  mutate(cost=bid*click)%>%
  filter(click==T)%>%
  group_by(num_drivers)%>%
  summarise(total_cost=sum(cost))%>%
  ungroup()

mydata%>%
  filter(click==T & policies_sold==1)%>%
  group_by(num_drivers)%>%
  summarise(number_sold=n())%>%
  ungroup()%>%
  left_join(temp1)%>%
  mutate(cost_per_sold=total_cost/number_sold)


# 
table(mydata$click, mydata$policies_sold)
mydata%>%
  filter(click==F)%>%
  tabyl(rank, married)%>%
  adorn_totals(c('row', 'col')) %>%
  adorn_percentages('row')


mydata%>%
  filter(click==T)%>%
  tabyl(rank, married)%>%
  adorn_totals(c('row', 'col')) %>%
  adorn_percentages('row')

mydata%>%
  filter(click==T)%>%
  tabyl(rank, married, policies_sold)