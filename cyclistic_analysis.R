# =============================================================================
# CYCLISTIC BIKE-SHARE ANALYSIS | 2025
# Statistical Analysis & Visualization
# Tool: R (tidyverse, ggplot2, lubridate)
# Author: P.L.U.
# Last Updated: June 2025
# =============================================================================
# ANALYSIS OVERVIEW
#   Step 1 | Load libraries and import cleaned dataset (subset)
#   Step 2 | Bike type preference by user type (segmented bar chart)
#   Step 3 | Ride proportions: Members vs. Casual (bar chart + pie chart)
#   Step 4 | Temporal trends: Monthly, daily, and hourly ride patterns
#   Step 5 | Ride duration: Mean and median comparison
#   Step 6 | Ride duration distribution (boxplot)
#
# Input:  2025_Cyclistic_cleaned.csv  (exported from BigQuery — 648 MB)
# Source: Motivate International Inc. | https://divvybikes.com/data-license-agreement
# =============================================================================


# -----------------------------------------------------------------------------
# STEP 1 | LOAD LIBRARIES & IMPORT DATA
# -----------------------------------------------------------------------------
# Context:
#   The cleaned dataset exported from BigQuery is 648 MB with 5.5M+ ride
#   records. Loading the full file into memory is unnecessary for visualization.
#   col_select is used to import only the 5 columns required for this analysis,
#   significantly reducing memory usage and load time.

library(tidyverse)
library(lubridate)
library(readr)

df_subset <- read_csv(
  "2025_Cyclistic_cleaned.csv",
  col_select = c(member_casual, ride_duration, rideable_type, Hour, Month, Day_name)
)

# Confirm all records loaded correctly
nrow(df_subset)   # Expected: 5,551,157 total rides


# -----------------------------------------------------------------------------
# STEP 2 | BIKE TYPE PREFERENCE BY USER TYPE
# -----------------------------------------------------------------------------
# Business Question: Do members and casual riders prefer different bike types?
# Chart type: Stacked bar chart
# Why: Allows direct comparison of bike type mix within each user group.

ride_type_summary <- df_subset %>%
  count(member_casual, rideable_type)

ggplot(ride_type_summary, aes(x = member_casual, y = n, fill = rideable_type)) +
  geom_col(position = "stack") +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title    = "Bike Type Preference: Members vs. Casual Riders",
    subtitle = "Comparing usage of Classic, Electric, and Docked bikes",
    x        = "User Type",
    y        = "Total Number of Rides",
    fill     = "Bike Type"
  ) +
  theme_minimal()


# -----------------------------------------------------------------------------
# STEP 3 | RIDE PROPORTIONS: MEMBERS VS. CASUAL
# -----------------------------------------------------------------------------
# Business Question: What share of total rides do members vs. casual riders represent?
# Charts: Bar chart (absolute count) + Pie chart (percentage share)

# -- 3a. Bar Chart (absolute counts + percentage labels) ----------------------

proportion_data <- df_subset %>%
  count(member_casual) %>%
  mutate(percentage = n / sum(n) * 100)

ggplot(proportion_data, aes(x = member_casual, y = n, fill = member_casual)) +
  geom_col() +
  geom_text(
    aes(label = paste0(round(percentage, 1), "%")),
    vjust = -0.5, size = 5
  ) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Proportion of Rides: Members vs. Casual Riders",
    x     = "User Type",
    y     = "Total Number of Rides",
    fill  = "User Type"
  ) +
  theme_minimal()

# -- 3b. Pie Chart (percentage share) -----------------------------------------

pie_data <- df_subset %>%
  count(member_casual) %>%
  mutate(
    percentage = n / sum(n) * 100,
    label      = paste0(member_casual, "\n", round(percentage, 1), "%")
  )

ggplot(pie_data, aes(x = "", y = n, fill = member_casual)) +
  geom_col(width = 1, color = "white") +
  coord_polar("y", start = 0) +
  geom_text(
    aes(label = label),
    position  = position_stack(vjust = 0.5),
    color     = "white", size = 5, fontface = "bold"
  ) +
  labs(
    title    = "Total Ride Share: Members vs. Casual Riders",
    subtitle = "Percentage of total trips taken in 2025"
  ) +
  theme_void() +
  theme(legend.position = "none")


# -----------------------------------------------------------------------------
# STEP 4 | TEMPORAL TRENDS: MONTHLY, DAILY & HOURLY PATTERNS
# -----------------------------------------------------------------------------
# Business Question: When do members and casual riders use the service?
# Identifying peak periods informs targeted marketing and operational planning.

# -- 4a. Monthly Rides (Bar Chart) --------------------------------------------
# Why: Reveals seasonality differences between user groups.

monthly_rides <- df_subset %>%
  count(Month, member_casual)

# Enforce chronological month order (prevents alphabetical sorting)
monthly_rides$Month <- factor(
  monthly_rides$Month,
  levels = c("January","February","March","April","May","June",
             "July","August","September","October","November","December")
)

ggplot(monthly_rides, aes(x = Month, y = n, fill = member_casual)) +
  geom_col(position = "dodge") +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title    = "Total Rides per Month: Member vs. Casual",
    subtitle = "Comparing seasonal trends between user types",
    x        = "Month",
    y        = "Number of Rides",
    fill     = "User Type"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# -- 4b. Daily Rides by Day of the Week (Bar Chart) ---------------------------
# Why: Members peaking on weekdays vs. casual riders peaking on weekends
#      is a key behavioral insight supporting the conversion strategy.

daily_rides <- df_subset %>%
  count(Day_name, member_casual)

daily_rides$Day_name <- factor(
  daily_rides$Day_name,
  levels = c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")
)

ggplot(daily_rides, aes(x = Day_name, y = n, fill = member_casual)) +
  geom_col(position = "dodge") +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title    = "Number of Rides by Day of the Week",
    subtitle = "Comparing daily usage between Casual riders and Members",
    x        = "Day of the Week",
    y        = "Total Number of Rides",
    fill     = "User Type"
  ) +
  theme_minimal()

# -- 4c. Hourly Demand (Line Chart) -------------------------------------------
# Why: Line chart shows continuous time flow across 24 hours.
#      Dual peaks (commute hours) for members vs. midday casual peaks
#      confirm purpose-of-use differences.

hourly_rides <- df_subset %>%
  count(Hour, member_casual)

ggplot(hourly_rides, aes(x = Hour, y = n, color = member_casual)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2) +
  scale_x_continuous(breaks = seq(0, 23, by = 2)) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title    = "Hourly Bike Demand: Members vs. Casual Riders",
    subtitle = "Comparing 24-hour usage patterns",
    x        = "Hour of Day (24h Clock)",
    y        = "Number of Rides",
    color    = "User Type"
  ) +
  theme_minimal()

# -- 4d. Monthly Trends (Line Chart) ------------------------------------------
# Why: Line chart emphasizes trajectory and stability over time,
#      complementing the bar chart view in 4a.

monthly_trends <- df_subset %>%
  count(Month, member_casual)

monthly_trends$Month <- factor(
  monthly_trends$Month,
  levels = c("January","February","March","April","May","June",
             "July","August","September","October","November","December")
)

ggplot(monthly_trends, aes(x = Month, y = n, color = member_casual, group = member_casual)) +
  geom_line(linewidth = 1.5) +
  geom_point(size = 3) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title    = "Seasonal Trends: Total Monthly Rides",
    subtitle = "Comparing ridership stability throughout the year",
    x        = "Month",
    y        = "Number of Rides",
    color    = "User Type"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# -----------------------------------------------------------------------------
# STEP 5 | RIDE DURATION: MEAN vs. MEDIAN
# -----------------------------------------------------------------------------
# Business Question: How long do members vs. casual riders typically ride?
# Why both mean and median?
#   The mean is pulled upward by long leisure rides (outliers).
#   The median gives the "typical" ride length and is more robust.
#   Comparing both reveals the skew in casual rider behavior.

# -- 5a. Average (Mean) Ride Duration -----------------------------------------

duration_comparison <- df_subset %>%
  group_by(member_casual) %>%
  summarize(avg_duration = mean(ride_duration, na.rm = TRUE))

ggplot(duration_comparison, aes(x = member_casual, y = avg_duration, fill = member_casual)) +
  geom_col() +
  geom_text(
    aes(label = paste0(round(avg_duration, 1), " min")),
    vjust = -0.5, size = 5
  ) +
  labs(
    title    = "Average Ride Duration: Member vs. Casual",
    subtitle = "Calculated in minutes per trip",
    x        = "User Type",
    y        = "Average Duration (Minutes)",
    fill     = "User Type"
  ) +
  theme_minimal()

# -- 5b. Median Ride Duration --------------------------------------------------

duration_stats <- df_subset %>%
  group_by(member_casual) %>%
  summarize(
    mean_duration   = mean(ride_duration,   na.rm = TRUE),
    median_duration = median(ride_duration, na.rm = TRUE)
  )

ggplot(duration_stats, aes(x = member_casual, y = median_duration, fill = member_casual)) +
  geom_col() +
  geom_text(
    aes(label = paste0(round(median_duration, 1), " min")),
    vjust = -0.5, size = 5
  ) +
  labs(
    title    = "Median Ride Duration: Member vs. Casual",
    subtitle = "The 'typical' ride length — less sensitive to extreme outliers",
    x        = "User Type",
    y        = "Median Duration (Minutes)"
  ) +
  theme_minimal()


# -----------------------------------------------------------------------------
# STEP 6 | RIDE DURATION DISTRIBUTION (BOXPLOT)
# -----------------------------------------------------------------------------
# Business Question: How spread out is ride behavior within each group?
# Why a boxplot?
#   Bar charts show averages but hide distribution shape.
#   A boxplot reveals the median, IQR, and behavioral spread in one view.
#
# Performance note:
#   5% random sample used (sample_frac) to render the plot at speed
#   without distorting the distribution shape. With 5.5M rows, plotting
#   all points would be slow and add no analytical value.

plot_sample <- df_subset %>% sample_frac(0.05)

ggplot(plot_sample, aes(x = member_casual, y = ride_duration, fill = member_casual)) +
  geom_boxplot(outlier.shape = NA, alpha = 0.7) +
  coord_cartesian(ylim = c(0, 60)) +
  labs(
    title    = "Behavioral Spread: Ride Duration Distribution",
    subtitle = "Zoomed to 0–60 minutes | Outliers hidden for clarity | 5% sample",
    x        = "User Type",
    y        = "Duration (Minutes)",
    fill     = "User Type"
  ) +
  theme_minimal()

# =============================================================================
# END OF ANALYSIS
# Key outputs: 9 charts covering bike preference, ride share, temporal
# patterns (monthly/daily/hourly), ride duration (mean/median), and
# behavioral distribution.
# =============================================================================
