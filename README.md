# 🚲 Cyclistic Bike-Share: Rider Behavior Analysis
### Transportation & Mobility | Marketing Analytics | Chicago, IL

**Tools:** SQL (BigQuery) · R (tidyverse, ggplot2) · Excel  
**Dataset:** 5.55 million rides · 12-month period (2025)  
**Scope:** Exploratory analysis → behavioral segmentation → conversion strategy

---

## Executive Summary

Cyclistic's finance team confirmed that **annual members are significantly more profitable than casual riders**, yet a large casual rider base already uses the service. This analysis examines **5.55 million rides** across 2025 to identify behavioral differences between the two groups.

**Key finding:** Casual riders take fewer but longer rides concentrated on weekends and midday hours — a pattern consistent with leisure use, not commuting. Members ride shorter, with high consistency on weekday commute hours.

**Business opportunity:** A targeted weekend-to-membership conversion campaign, timed around peak casual usage periods, represents the highest-ROI path to growing annual memberships without acquiring new customers.

---

## Business Problem

Cyclistic offers three pricing tiers: single-ride passes, full-day passes, and annual memberships. Customers using the first two are classified as **casual riders**; the third as **members**.

The director of marketing, Lily Moreno, identified a growth hypothesis: casual riders already know and trust Cyclistic. **Converting them to annual members is cheaper and more effective than acquiring new customers from scratch.**

To design that conversion strategy, the marketing analytics team first needs to answer:

> **How do annual members and casual riders use Cyclistic bikes differently?**

This analysis was assigned as the foundational question — without understanding the behavioral gap, no targeted campaign can be designed.

**Why it matters:**
- Annual members are the primary revenue driver
- Casual riders represent an existing, addressable audience
- Behavioral data is the only way to identify *when* and *how* to reach them

---

## Methodology

The analysis followed a structured pipeline across two tools:

**Phase 1 — Data Preparation (SQL / BigQuery)**  
Twelve monthly CSV files (130,000+ rides each) were combined using BigQuery's wildcard method into a single annual table. A Common Table Expression (CTE) was used to engineer ride duration, day of week, month, and hour features — then bucket ride duration into six categories. Invalid records (negative durations, nulls, rides exceeding 60 minutes) were audited and removed before export.

**Phase 2 — Analysis & Visualization (R / tidyverse)**  
The cleaned dataset (648 MB) was imported with column selection to minimize memory load. Nine visualizations were produced across four analytical dimensions: ride share proportions, bike type preferences, temporal patterns (monthly, daily, hourly), and ride duration (mean, median, distribution).

**Analytical logic:**  
Each chart type was chosen deliberately — line charts for continuous hourly flow, dodged bar charts for group comparison, boxplots for behavioral spread. Both mean and median duration were calculated to account for outlier skew in casual rider data.

---

## Skills Used

| Layer | Skills |
|---|---|
| **SQL / BigQuery** | Wildcard table combining, CTEs, feature engineering, `TIMESTAMP_DIFF`, `EXTRACT`, `FORMAT_TIMESTAMP`, `UNION ALL`, data auditing, `ALTER TABLE` |
| **R** | `tidyverse`, `ggplot2`, `readr`, `lubridate`, `col_select` memory optimization, `sample_frac` for large-dataset performance, `factor()` for ordered categoricals |
| **Data Cleaning** | Null handling, negative value detection, out-of-range filtering, schema validation across 12 files |
| **Data Visualization** | Stacked bar, dodged bar, pie, line, boxplot — with business-question-driven chart selection |
| **Analytical Reasoning** | Mean vs. median comparison, behavioral segmentation, outlier interpretation |

---

## Results & Business Recommendations

### What the data shows

| Dimension | Members | Casual Riders |
|---|---|---|
| **Ride volume** | Higher total rides | Fewer total rides |
| **Avg. ride duration** | Shorter (~12 min) | Longer (~22 min) |
| **Peak days** | Weekdays (Mon–Fri) | Weekends (Sat–Sun) |
| **Peak hours** | 8 AM and 5 PM (commute) | Midday (11 AM–3 PM) |
| **Seasonality** | Consistent year-round | Sharp summer spike |
| **Bike preference** | Classic and electric | Higher docked bike use |

### What it means

Members use Cyclistic as a **commuting utility** — predictable, short, time-bound. Casual riders use it as a **leisure activity** — longer, spontaneous, weekend-concentrated.

This behavioral gap is the conversion opportunity. Casual riders are not opposed to the service — they're using it actively. The barrier to membership is likely **perceived value**: they don't yet see an annual membership as cost-effective for their usage pattern.

### Recommendations

**1. Launch a Weekend Warrior Campaign**  
Target casual riders with membership promotions at peak weekend hours (11 AM–3 PM, Saturday–Sunday). Messaging should reframe the annual membership around weekend freedom, not commuting.

**2. Seasonal Conversion Window**  
Casual ridership spikes sharply in summer. Run the most aggressive conversion offers in May–June, before peak casual usage begins, to capture riders before they default to single-ride passes all season.

**3. Ride Duration as the Value Hook**  
Casual riders average nearly 2× the ride duration of members. A campaign showing cost-per-minute savings for longer rides would directly address their usage pattern and make the membership ROI obvious.

---

## Next Steps

- **Extend with station-level data** — identifying which docking stations casual riders start and end at would enable geo-targeted digital ads (the third question Moreno's team needs answered)
- **Add year-over-year comparison** — a single year's data is sufficient for behavioral segmentation but trend analysis would strengthen the seasonality recommendation
- **Build a conversion model** — with member acquisition cost data from the finance team, a simple ROI model could quantify the revenue impact of a 5–10% casual-to-member conversion rate
- **Power BI dashboard** — a live, filterable dashboard would allow the executive team to explore the data interactively rather than reviewing static charts

---

## Repository Structure

```
cyclistic-bike-share-analysis/
│
├── README.md
├── analysis/
│   ├── cyclistic_data_preparation.sql   ← BigQuery pipeline (combine, clean, engineer)
│   └── cyclistic_analysis.R             ← R visualization scripts (9 charts)
└── visuals/
    └── [chart exports]                  ← Key charts referenced above
```

---

## Data Source

Data provided by **Motivate International Inc.** under their [public data license](https://divvybikes.com/data-license-agreement).  
Raw data available at: [https://divvy-tripdata.s3.amazonaws.com/index.html](https://divvy-tripdata.s3.amazonaws.com/index.html)  
*Note: Raw CSV files are not included in this repository. No personally identifiable rider information was used in this analysis.*
