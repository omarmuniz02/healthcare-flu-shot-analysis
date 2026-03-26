# 🏥 Flu Shot Compliance Analysis (2022)

## 📌 Project Overview
This project analyzes flu shot compliance among active patients in 2022 using SQL and Tableau.

The goal was to identify which patients received a flu shot, then break compliance down across age, race, and county while also tracking the running total of flu shots over time.

This dashboard was built using **synthetic healthcare data** for portfolio purposes.

## 📊 Dashboard Preview (Interactive Views)

### 🏥 Main Dashboard Overview
![Main Dashboard](images/SS%201.png)

This view shows the full dashboard without any filters applied. It provides a high-level summary of flu shot compliance across all active patients in 2022, including:

- Overall compliance rate and total flu shots administered
- Breakdown of flu shot percentages by age group
- Compliance distribution across race categories
- County-level flu shot rates
- A patient-level list of vaccination status
- A running total chart showing vaccination trends over time

This serves as the primary analytical view for identifying overall patterns and trends.

---

### 📍 Filter Applied: Dallas County
![Dallas Filter](images/SS%202%20Dallas.png)

This view demonstrates dashboard interactivity by filtering specifically for **Dallas County**.

Key observations:
- Compliance rate dynamically updates based on the selected county
- All visualizations (age, race, totals, and running sum) adjust in real time
- Allows for geographic comparison across different counties

This highlights how the dashboard supports **localized analysis** and quick comparison across regions.

---

### 👶 Filter Applied: Age Group (0–17)
![Age Group Filter](images/SS%203%200-17.png)

This view focuses on the **0–17 age group**, showcasing demographic filtering.

Key observations:
- All other age groups are dimmed, emphasizing the selected segment
- Compliance metrics update to reflect only the selected population
- Race and county distributions adjust based on this age group
- Running total reflects vaccination trends specific to this segment

This demonstrates the ability to drill down into specific populations and analyze targeted insights.
---

## 🎯 Project Goals
This project answers the following questions:

- What percentage of active patients received a flu shot in 2022?
- How does compliance vary by **age group**?
- How does compliance vary by **race**?
- How does compliance vary by **county**?
- How many total flu shots were given?
- How does vaccination progress across the year?
- Which patients received or did not receive a flu shot?

---

## 🛠 Tools Used
- **SQL** (PostgreSQL-style queries)
- **Tableau**

### SQL Techniques
- CTEs
- Joins
- Filtering
- Date logic
- Binary indicator logic
- Aggregations
- Window functions

### Tableau Features
- Calculated fields
- KPI cards
- Dashboard actions
- Interactive filtering

---

## 📊 Key Insights

- Overall flu shot compliance was approximately **44–47%**
- Younger populations showed relatively higher compliance
- Compliance varied across race categories
- County-level differences highlight geographic variation
- Running total shows vaccination trends over time  

---

## 📈 Tableau Logic

### Calculated Fields
- **Age** → derived from birthdate  
- **Age Group** → 0–17, 18–34, 35–49, 50–64, 65+  
- **Flu Shot %** → compliance metric  

### KPI Cards
- Total Compliance  
- Total Flu Shots Given  

### Interactivity
Selecting any category dynamically updates:
- Age breakdown  
- Race breakdown  
- County breakdown  
- KPI cards  
- Patient list  
- Running total chart  

---

## 💡 What This Project Demonstrates

- Building analysis-ready datasets using SQL  
- Translating business logic into queries  
- Performing analytical aggregations in SQL  
- Creating interactive dashboards in Tableau  
- Turning raw data into insights  
- Presenting work in a portfolio-ready format  

---

## ⚠️ Notes
- Dataset is synthetic (not real patient data)  
- Project created for portfolio purposes  

---

## 🧠 Core SQL Story
The analysis was built around:

- **Active patients only**
- **Flu shot status in 2022**
- **Overall compliance**
- **Breakdowns by age, race, and county**
- **Running total of flu shots**
- **Patient-level flu shot list**

The final dashboard was built from a curated SQL dataset, then extended with Tableau calculated fields.

---

## 🧮 SQL Approach

### Step 1: Identify Active Patients
Patients were considered **active** if they:
- Had at least one encounter during 2022
- Were alive (`deathdate IS NULL`)
- Were at least 6 months old by the end of 2022

---

### Step 2: Identify Flu Shot Activity
A second CTE isolated flu shot records for 2022 and captured the **earliest flu shot date per patient**.

---

### Step 3: Join + Create Indicator
The final dataset joined active patients to flu shot records and created a binary indicator:

```sql
LEFT JOIN flu_shot_2022 flu
  ON pat.id = flu.patient

CASE 
    WHEN flu.patient IS NOT NULL THEN 1
    ELSE 0
END AS flu_shot_2022
```

---

## 📂 SQL Implementation

### Final Query (Refined Version)

```sql
WITH active_patients AS (
    SELECT DISTINCT e.patient
    FROM encounters e
    JOIN patients pat
      ON e.patient = pat.id
    WHERE e.start_time BETWEEN '2022-01-01 00:00:00' AND '2022-12-31 23:59:59'
      AND pat.deathdate IS NULL
      AND pat.birthdate <= DATE '2022-12-31' - INTERVAL '6 months'
),
flu_shot_2022 AS (
    SELECT patient, MIN(date_time) AS earliest_flu_shot
    FROM immunizations
    WHERE date_time BETWEEN '2022-01-01 00:00:00' AND '2022-12-31 23:59:59'
    GROUP BY patient
)
SELECT 
    pat.birthdate,
    pat.race,
    pat.county,
    pat.id,
    pat.first,
    pat.last,
    flu.earliest_flu_shot,
    CASE 
        WHEN flu.patient IS NOT NULL THEN 1
        ELSE 0
    END AS flu_shot_2022
FROM patients pat
LEFT JOIN flu_shot_2022 flu
  ON pat.id = flu.patient
WHERE pat.id IN (SELECT patient FROM active_patients);
```

---

## 📊 Additional SQL Analysis

In addition to building the dataset, SQL was used to validate key metrics:

### Overall Compliance
```sql
SELECT 
    ROUND(AVG(flu_shot_2022) * 100, 2) AS overall_compliance_pct
FROM final_dataset;
```

### Compliance by Race
```sql
SELECT 
    race,
    ROUND(AVG(flu_shot_2022) * 100, 2) AS compliance_pct
FROM final_dataset
GROUP BY race;
```

### Total Flu Shots Given
```sql
SELECT COUNT(*) AS total_flu_shots
FROM final_dataset
WHERE flu_shot_2022 = 1;
```

### Running Total of Flu Shots
```sql
SELECT 
    earliest_flu_shot::date AS shot_date,
    COUNT(*) AS daily_shots,
    SUM(COUNT(*)) OVER (ORDER BY earliest_flu_shot::date) AS running_total
FROM final_dataset
WHERE flu_shot_2022 = 1
GROUP BY shot_date
ORDER BY shot_date;
```
