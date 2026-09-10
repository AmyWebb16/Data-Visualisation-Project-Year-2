library(scales)
library(readr)
library(dplyr)
library(ggrepel)
library(ggplot2)
library(tidyverse)
library(sf)
library(rworldmap)


######### DATA CLEANING & PROCESSING #########

# read in the data set
data <- read.csv("C:/Users/Amy/Desktop/data visualization/assignment1/Co2_dataset.csv")
view(data)

# creating variables
colnames(data) <- c("country","year","iso_code", "co2", "co2_per_capita", "coal_co2", "oil_co2","gas_co2","cement_co2", "consumption_co2")

# get rid of records with empty values
clean_data <- na.omit(data)
view(clean_data)
m <- length(clean_data$country)

# group data by year and sum all co2 for global trend
global_co2 <- clean_data %>% group_by(year) %>% summarise(sum_co2 = sum(co2, na.rm=TRUE))

# sum of fuel types
fuel_sum <- data.frame(fuel_type = c("Coal", "Oil", "Gas", "Cement"), sum_co2   = c(sum(clean_data$coal_co2), sum(clean_data$oil_co2), sum(clean_data$gas_co2),  sum(clean_data$cement_co2)))

# top 10 countries by total co2 (all years)
top10_country <- clean_data %>% group_by(country) %>% summarise(sum_co2 = sum(co2, na.rm=TRUE)) %>% arrange(desc(sum_co2)) %>% slice_head(n=10) %>% mutate(is_top = ifelse(country == country[which.max(sum_co2)], TRUE, FALSE))

# get world map and remove NA regions
world_sf<- st_as_sf(getMap(resolution = "low"))
world_sf<- world_sf[!is.na(world_sf$REGION),]

# co2 data for 2022 (world map)
co2_2022 <- clean_data %>% filter(year == 2022) %>% select(country, co2) %>% mutate(country = recode(country,"Czechia"  = "Czech Republic", "Hong Kong" = "Hong Kong S.A.R.", "Tanzania" = "United Republic of Tanzania", "United States" = "United States of America"))

world_co2 <- world_sf %>%left_join(co2_2022, by = c("ADMIN" = "country")) %>% sf::st_transform(crs = st_crs("+proj=robin"))

# Europe country list
europe <- c("Albania","Andorra","Austria","Belarus","Belgium","Bosnia and Herzegovina",
            "Bulgaria","Croatia","Cyprus","Czechia","Denmark","Estonia","Finland",
            "France","Germany","Greece","Hungary","Iceland","Ireland","Italy",
            "Kosovo","Latvia","Liechtenstein","Lithuania","Luxembourg","Malta",
            "Moldova","Monaco","Montenegro","Netherlands","North Macedonia","Norway",
            "Poland","Portugal","Romania","Russia","San Marino","Serbia","Slovakia",
            "Slovenia","Spain","Sweden","Switzerland","Ukraine","United Kingdom")

# group Europe together
clean_data_europe <- clean_data %>% mutate(country = ifelse(country %in% europe, "Europe", country))

europe_grouped <- clean_data_europe %>% group_by(country, year) %>% #
  summarise(
    co2 = sum(co2, na.rm=TRUE),
    co2_per_capita = mean(co2_per_capita, na.rm=TRUE),
    coal_co2 = sum(coal_co2, na.rm=TRUE),
    oil_co2 = sum(oil_co2, na.rm=TRUE),
    gas_co2 = sum(gas_co2, na.rm=TRUE),
    cement_co2 = sum(cement_co2, na.rm=TRUE),
    .groups = "drop"
  )

# key countries trend data (1990 onwards)
key_countries <- c("China", "United States", "India")
trend_data <- europe_grouped %>% filter(country %in% c(key_countries, "Europe"), year >= 1990) %>% select(country, year, co2)

# top 5 emitters in 2022 with fuel breakdown
top5_countries <- clean_data %>% filter(year == 2022) %>% arrange(desc(co2)) %>% slice_head(n=5) %>% pull(country)

top_5_countries_fuel <- clean_data %>% filter(year == 2022, country %in% top5_countries) %>% select(country, coal_co2, oil_co2, gas_co2, cement_co2) %>% pivot_longer(cols = -country, names_to = "fuel_type", values_to = "emissions") %>%
  mutate( fuel_type = recode(fuel_type, coal_co2="Coal", oil_co2="Oil", gas_co2="Gas", cement_co2="Cement"),country= factor(country, levels = rev(top5_countries)))

# USA trend data (1990 onwards)
usa_trend <- trend_data %>% filter(country == "United States")

# Ireland trend data (1990 onwards)
ire_trend <- clean_data %>% filter(country == "Ireland", year >= 1990) %>% select(country, year, co2)


######### 1 EXPLORATORY GRAPHS #########

# Graph 1.1: CO2 per Capita Distribution (2022)
ggplot(filter(clean_data, year == 2022), aes(x = co2_per_capita)) +
  geom_histogram(binwidth = 1, fill = "lightblue", colour = "white") +
  scale_x_continuous(labels = comma) +
  scale_y_continuous(labels = comma) +
  annotate("segment", x=30, xend=22, y=3, yend=2, arrow = arrow(length = unit(0.1, "in")), colour = "darkgrey") +
  annotate("text", x=31, y=3.2, label = "High-emission\noutliers", size = 3, colour = "black") +
  labs(title = "Distribution of CO2 per Capita (2022)", x = "CO2 Per Capita (tonnes per person)", y = "Count") +
  theme_minimal()
ggsave("graph_1_1_co2_per_capita_distribution.png", width=10, height=6, dpi=300)


# Graph 1.2: USA CO2 Emission Trend (1990-2023) 
ggplot(usa_trend, aes(x = year, y = co2)) +
  geom_line(linewidth = 1.5, colour = "lightblue") +
  annotate("rect", xmin=2020, xmax=2021, ymin=-Inf, ymax=Inf, fill="darkred", alpha=0.05) +
  geom_vline(xintercept = 2015, linetype = "dashed", colour = "darkgrey", linewidth = 0.5) +
  annotate("text", x=2014.8, y=max(usa_trend$co2)*0.97, label = "Paris Agreement\n(2015)", hjust=1, size=3, colour="black") +
  geom_vline(xintercept = 2020, linetype = "dashed", colour = "darkgrey", linewidth = 0.5) +
  annotate("text", x=2019.4, y=max(usa_trend$co2)*0.72,label = "USA leaves\nParis Agreement\n(2020)", hjust=1, size=3, colour="black") +
  geom_vline(xintercept = 2020.5, linetype = "dashed", colour = "darkred", linewidth = 0.5) +
  annotate("text", x=2021.2, y=max(usa_trend$co2)*0.65, label = "COVID-19\n(2020)", hjust=0, size=3, colour="black") +
  scale_y_continuous(labels = comma) +
  labs(title = "CO2 Emission Trends: United States (1990-2023)",x = "Year", y = "CO2 Emissions (million tonnes)") +
  theme_minimal()
ggsave("graph_1_2_trend_usa.png", width=10, height=6, dpi=300)

# Graph 1.3: CO2 Emission Trends — China, USA, Europe & India (1990-2023) 
ggplot(trend_data, aes(x = year, y = co2, colour = country)) +
  geom_line(linewidth = 1.5) +
  geom_vline(xintercept = 2015, linetype = "dashed", colour = "darkgrey", linewidth = 0.5) +
  annotate("text", x=2014, y=max(trend_data$co2)*0.99,label = "Paris\nAgreement (2015)", hjust=0, size=3, colour="black") +
  geom_vline(xintercept = 2020, linetype = "dashed", colour = "darkgrey", linewidth = 0.5) +
  annotate("text", x=2020, y=max(trend_data$co2)*0.55,label = "COVID-19\n(2020)", hjust=0, size=3, colour="black") +
  scale_colour_manual(values = c("China"="darkred","United States"="lightblue","India"="orange","Europe"="darkgreen")) +
  scale_y_continuous(labels = comma) +
  labs(title = "CO2 Emission Trends: China, USA, Europe and India (1990-2023)", x = "Year", y = "CO2 Emissions (million tonnes)", colour = NULL) +
  theme_minimal()
ggsave("graph_1_3_trend_china_usa_europe_india.png", width=10, height=6, dpi=300)

# Graph 1.4: Global CO2 Emission by Country - World Map (2022) 
ggplot(data = world_co2, aes(fill = co2)) +
  geom_sf(colour = "white", linewidth = 0.1) +
  scale_fill_gradient(low="#90D5FF", high="#005385", na.value="grey",name="CO2 (Mt)", labels = comma) +
  labs(title = "Global CO2 Emission by Country (2022)",subtitle = "Grey = no data available", x=NULL, y=NULL) +
  theme_bw() +
  theme(axis.text=element_blank(), axis.ticks=element_blank(),panel.grid=element_blank(), legend.position="bottom")
ggsave("graph_1_4_world_map_co2_2022.png", width=12, height=7, dpi=300)


######### 2 EXPLANATORY GRAPHS #########

# Graph 2.1: Sum of CO2 by Fossil Fuel Type (All Years) 
ggplot(fuel_sum, aes(x = fuel_type, y = sum_co2, fill = fuel_type)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = paste0(round(sum_co2, 1), "Mt")), vjust=-1, size=3) +
  scale_fill_manual(values = c("Coal"="#6096ba","Oil"="#a3cef1","Gas"="#e7ecef","Cement"="#274c77")) +
  scale_y_continuous(labels = comma) +
  annotate("text", x="Coal", y=max(fuel_sum$sum_co2)*0.5,label = "Largest\nsource", size=3, colour="black") +
  labs(title = "Sum of CO2 for Fossil Fuel Type (All Years)", x=NULL, y="Sum of CO2 (million tonnes)") +
  theme_minimal()
ggsave("graph_2_1_co2_by_fuel_type.png", width=10, height=6, dpi=300)

# Graph 2.2:Fuel Type Breakdown for Top 5 Emitters (2022)
ggplot(top_5_countries_fuel, aes(x = emissions, y = country, fill = fuel_type)) +
  geom_bar(stat = "identity", position = "stack") +
  annotate("segment", x=9000, xend=6950, y=5.4, yend=5.1,arrow = arrow(length = unit(0.1,"in")), colour="darkgrey") +
  annotate("text", x=9220, y=5.25, label="Coal-heavy\nemissions", size=3, colour="black") +
  scale_x_continuous(labels = comma) +
  scale_fill_manual(values = c("Coal"="#6096ba","Oil"="#a3cef1","Gas"="#e7ecef","Cement"="#274c77")) +
  labs(title = "Fuel Type Breakdown for Top 5 CO2 Emitters (2022)",x = "CO2 Emissions (million tonnes)", y = NULL, fill = "Fuel type") +
  theme_minimal()
ggsave("graph_2_2_fuel_type_top5_countries.png", width=10, height=6, dpi=300)

# Graph 2.3: Global CO2 Over Time (All Years) 
ggplot(global_co2, aes(x = year, y = sum_co2)) +
  geom_line(colour = "lightblue", linewidth = 1.5) +
  geom_vline(xintercept = 2020, linetype = "dashed", colour = "darkgrey", linewidth = 0.5) +
  annotate("text", x=2020, y=max(global_co2$sum_co2)*0.90,label = "COVID-19\n(2020)", hjust=0, size=3, colour="black") +
  scale_y_continuous(labels = comma) +
  labs(title = "Global CO2 Over Time",x = "Year", y = "Sum CO2 (million tonnes)") +
  theme_minimal()
ggsave("graph_2_3_global_co2_over_time.png", width=10, height=6, dpi=300)


######### 3 EXTRA GRAPHS #########

# Graph 3.1: Top 10 Countries by Total CO2 (All Years)
ggplot(top10_country, aes(x=sum_co2, y=reorder(country, sum_co2), fill=is_top)) +
  geom_bar(stat="identity") +
  geom_label(data=top10_country %>% filter(is_top==TRUE), aes(label=paste0(round(sum_co2/1000, 0), "kMt")), hjust=1, size=3, fill="white", colour="black") +
  scale_fill_manual(values=c("FALSE"="lightblue","TRUE"="darkblue")) +
  scale_x_continuous(labels=comma) +
  labs(title="Top 10 Countries by Total CO2 (All Years)", x="Total CO2 (million tonnes)", y=NULL) +
  theme_minimal() +
  theme(legend.position="none")
ggsave("graph_3_1_top10_countries_total_co2.png", width=10, height=6, dpi=300)


# Graph 3.2: Oil CO2 vs Gas CO2 by Country (2022)
ggplot(filter(clean_data, year==2022), aes(x=oil_co2, y=gas_co2)) +
  geom_point(colour="lightblue", alpha=0.5) +
  geom_smooth(method="lm", colour="red3", se=FALSE) +
  scale_x_continuous(labels=comma) +
  scale_y_continuous(labels=comma) +
  labs(title="Oil CO2 vs Gas CO2 by Country (2022)", x="Oil CO2 (million tonnes)", y="Gas CO2 (million tonnes)") +
  theme_minimal()
ggsave("graph_3_2_oil_vs_gas_co2_scatter.png", width=10, height=6, dpi=300)

# Graph 3.3: CO2 Emission Trends — Ireland (1990-2023) 
ggplot(ire_trend, aes(x = year, y = co2)) +
  geom_line(linewidth = 1.5, colour = "lightblue") +
  geom_vline(xintercept = 2015, linetype = "dashed", colour = "darkgrey", linewidth = 0.5) +
  annotate("text", x=2015.5, y=max(ire_trend$co2)*0.95,label = "Paris Agreement\n(2015)", hjust=0, size=3, colour="black") +
  geom_vline(xintercept = 2019.5, linetype = "dashed", colour = "darkred", linewidth = 0.5) +
  annotate("text", x=2023, y=max(ire_trend$co2)*0.80, label = "COVID-19\n(2020)", hjust=1.05, size=3, colour="black") +
  annotate("rect", xmin=2019.5, xmax=2021, ymin=-Inf, ymax=Inf, fill="darkred", alpha=0.05) +
  scale_y_continuous(labels = comma) +
  labs(title = "CO2 Emission Trends: Ireland (1990-2023)", x = "Year", y = "CO2 Emissions (million tonnes)") +
  theme_minimal()
ggsave("graph_3_3_trend_ireland.png", width=10, height=6, dpi=300)

