<div align="right">

English | [Русский](README_RU.md)

</div>

# Data Analyst Job Market Analysis

> A SQL portfolio case study exploring high-paying roles, skill demand, and salary associations in Data Analyst job postings.

**Business question → SQL analysis → results → insights**

**Project status:** Five analytical SQL queries are present, and the two identified SQL errors have been corrected. The queries are ready to run against the defined PostgreSQL schema; execution against the source dataset has not been verified. Source CSVs are not stored in the repository, so numerical results and charts have not yet been published.

## 📊 Overview

This educational project uses a relational job-posting dataset to explore which Data Analyst roles pay more, which skills employers request, and how skill demand relates to reported annual salaries. Its practical objective is to support evidence-based decisions about skills to investigate and learn while developing an entry-level analytics portfolio.

The analysis follows five questions, from individual vacancies to aggregated skill comparisons. The first two queries target postings marked `Anywhere` or containing `Moscow`; the remaining three cover all locations in the supplied dataset. Findings must therefore be interpreted within each query's scope, rather than as a single market-wide ranking.

### Data and relationships

| Table | Grain / key | Role in the analysis |
|---|---|---|
| `job_postings_fact` | One posting per `job_id` | Titles, locations, posting dates and salary fields |
| `company_dim` | One company per `company_id` | Company names; linked to postings through `company_id` |
| `skills_dim` | One skill per `skill_id` | Skill names and categories |
| `skills_job_dim` | One `(job_id, skill_id)` pair | Many-to-many bridge between postings and skills |

The schema defines primary and foreign keys, including a composite primary key on the bridge, and indexes on join columns. A posting can have multiple skills; skill counts are not mutually exclusive.

**Data limitations:** `csv_files/` is excluded by `.gitignore`. The dataset provider, collection period, geographic coverage, salary currency and normalization method are not documented. `salary_year_avg` is treated as a supplied annual salary field; cross-country comparisons require confirmation that its values are comparable. No date filter is applied, and this project does not establish current market conditions. Skill-based queries exclude postings without mapped skills.

## 🎯 Business Questions

1. Which salary-disclosing Data Analyst postings marked `Anywhere` or containing `Moscow` have the highest annual salaries?
2. Which skills are listed in those top ten postings?
3. Which five skills appear in the largest number of Data Analyst postings across all locations?
4. Which fifteen skills have the highest average annual salaries, with more than 50 salary-disclosing postings per skill?
5. Among skills with more than 50 salary-disclosing postings, which ten have the highest demand, and how do their average salaries compare?

## 🛠️ Tools & Technologies

- **SQL / PostgreSQL** — schema definition, relational joins, filtering and aggregation.
- **GitHub** — repository organization and bilingual project documentation.

The analytical SQL demonstrates `LEFT JOIN`, `INNER JOIN`, CTEs, `GROUP BY`, `HAVING`, `COUNT`, `COUNT(DISTINCT ...)`, `AVG`, `ROUND`, `DISTINCT`, `LIKE`, `IS NOT NULL`, `ORDER BY` and `LIMIT`. No window functions, `CASE` or `UNION` are used.

## 🗂️ Project Structure

```text
course/
├── project_sql/
│   ├── 1_top_paying_jobs.sql
│   ├── 2_top_paying_job_skills.sql
│   ├── 3_top_demanded_skills.sql
│   ├── 4_top_paying_skills.sql
│   └── 5_optimal_skills.sql
├── sql_load/
│   ├── 1_create_database.sql
│   ├── 2_create_tables.sql
│   └── 3_modify_tables.sql
├── .gitignore
├── README.md
└── README_RU.md
```

`project_sql/` contains the five analytical queries. `sql_load/` creates the database and tables, then imports four CSVs; despite its name, `3_modify_tables.sql` is a data-loading script. Its file paths must be adjusted to the local dataset location. An `assets/` directory can be added once actual results support charts.

## 🔎 Analysis

### 1. Top-Paying Data Analyst Jobs

**Business Question:** Which eligible individual postings offer the highest reported annual salaries?

**Approach:** Join postings to company names, apply role, location and non-null salary filters, then select ten postings in descending salary order. The `LEFT JOIN` retains postings without a company match.

**SQL Techniques:** `LEFT JOIN`, Boolean filtering, `LIKE`, `IS NOT NULL`, `ROUND`, `ORDER BY`, `LIMIT`.

**SQL Example — location and salary filters:**

```sql
WHERE job_title_short = 'Data Analyst'
  AND (job_location = 'Anywhere' OR job_location LIKE '%Moscow%')
  AND salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 10;
```

[View full query](project_sql/1_top_paying_jobs.sql)

**Result:** Not published because the source CSVs and saved query outputs are absent. The location alternatives are grouped in parentheses, so the role and non-null salary filters apply to both locations.

**Insight:** No salary ranking can be claimed yet. The query is designed to describe individual postings in a specific location subset; it does not establish typical pay or junior-level pay.

### 2. Skills in Top-Paying Jobs

**Business Question:** Which skills are associated with the ten highest-paying eligible postings?

**Approach:** A CTE selects ten postings using the intended role and location filters. Two `INNER JOIN`s attach skill mappings and names, yielding one row per posting–skill pair.

**SQL Techniques:** CTE, `LEFT JOIN`, `INNER JOIN`, filtering, `ROUND`, `ORDER BY`, `LIMIT`.

**SQL Example — CTE salary output and skill joins:**

```sql
-- Within top_paying_jobs:
ROUND(salary_year_avg) AS salary_year_avg
-- Preserve sorting by the original salary inside the CTE:
ORDER BY job_postings_fact.salary_year_avg DESC

-- After the CTE:
SELECT top_paying_jobs.*, skills
FROM top_paying_jobs
INNER JOIN skills_job_dim
  ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim
  ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY salary_year_avg DESC;
```

[View full query](project_sql/2_top_paying_job_skills.sql)

**Result:** Not published because query outputs are absent. The CTE now exposes `ROUND(salary_year_avg) AS salary_year_avg` for the outer sort. Inside the CTE, `job_postings_fact.salary_year_avg DESC` preserves selection by the original, unrounded salary.

**Insight:** Once executed, the query can identify listed skills in a small high-pay subset. It does not count or rank those skills. Postings without skill mappings disappear after the joins, and the output may contain more than ten rows.

### 3. Most In-Demand Skills

**Business Question:** Which skills appear most frequently in Data Analyst postings?

**Approach:** Join postings to skills, group by skill name and count matching bridge rows. Select the five largest counts, including postings with and without salary information.

**SQL Techniques:** `INNER JOIN`, `COUNT`, `GROUP BY`, filtering, `ORDER BY`, `LIMIT`.

**SQL Example:**

```sql
SELECT skills, COUNT(skills_job_dim.job_id) AS demand_count
-- The full query joins postings to the skill bridge and dictionary.
WHERE job_title_short = 'Data Analyst'
GROUP BY skills
ORDER BY demand_count DESC
LIMIT 5;
```

*This excerpt omits the FROM/JOIN clauses; use the full query to execute it.*

[View full query](project_sql/3_top_demanded_skills.sql)

**Result:** No counts or skill ranking are available from the repository. With the defined composite key, each posting contributes at most once per skill ID. Grouping by names assumes that names uniquely identify skills; the schema does not enforce that assumption.

**Insight:** This is the broadest demand measure in the project. Its counts should not be equated with the salary-disclosing demand counts in analysis 5.

### 4. Highest-Paying Skills

**Business Question:** Which sufficiently represented skills are associated with the highest average annual salaries?

**Approach:** Keep Data Analyst postings with `salary_year_avg > 0`, calculate mean salary by skill and retain groups with more than 50 distinct postings. Return fifteen skills sorted by rounded average salary.

**SQL Techniques:** `INNER JOIN`, `AVG`, `ROUND`, `COUNT(DISTINCT ...)`, `GROUP BY`, `HAVING`, `ORDER BY`, `LIMIT`.

**SQL Example:**

```sql
WHERE job_title_short = 'Data Analyst'
  AND salary_year_avg > 0
GROUP BY skills
HAVING COUNT(DISTINCT job_postings_fact.job_id) > 50
ORDER BY avg_salary DESC
LIMIT 15;
```

[View full query](project_sql/4_top_paying_skills.sql)

**Result:** No verified salary averages are available. The threshold is strictly greater than 50, so a group needs at least 51 distinct postings. Zero, negative and null salaries are excluded.

**Insight:** The threshold reduces reliance on very small groups, but does not remove bias from seniority, geography, company mix or salary disclosure. Associations between skills and salaries do not prove a causal pay premium.

### 5. Demand and Salary Together

**Business Question:** Which frequently requested skills also warrant investigation for their salary associations?

**Approach:** Two CTEs calculate distinct posting counts and rounded mean salaries for the same positive-salary Data Analyst subset. Join them by skill ID, retain counts above 50 and return ten skills ordered by demand first, then salary.

**SQL Techniques:** Multiple CTEs, `INNER JOIN`, `COUNT(DISTINCT ...)`, `AVG`, `ROUND`, `GROUP BY`, `DISTINCT`, filtering, multi-column `ORDER BY`, `LIMIT`.

**SQL Example:**

```sql
FROM skills_demand
INNER JOIN average_salary
  ON skills_demand.skill_id = average_salary.skill_id
WHERE demand_count > 50
ORDER BY demand_count DESC, avg_salary DESC
LIMIT 10;
```

[View full query](project_sql/5_optimal_skills.sql)

**Result:** No demand–salary pairs are available. The implemented ranking prioritizes demand; average salary breaks demand ties. There is no combined score or mathematical optimization criterion.

**Insight:** The output can support a learning-priority discussion after validation, but the filename's “optimal” label should not be read as a proven best balance of pay and demand.

## 📉 Visualizations

Charts are pending real query outputs. No placeholder salaries, skill counts or illustrative market rankings are presented. Both language versions will share the same English-labelled images in `assets/`.

| Planned shared image | Required result | Intended chart |
|---|---|---|
| `assets/top_paying_jobs.png` | Corrected query 1 | Horizontal salary bars by posting |
| `assets/demanded_skills.png` | Query 3 | Horizontal skill-demand bars |
| `assets/paying_skills.png` | Query 4 | Average salary bars by skill |
| `assets/optimal_skills.png` | Query 5 | Demand vs. mean salary scatter with skill labels |

These are future paths, not links to existing files. Real query outputs are required before plotting; Python, pandas and matplotlib are possible future tools, not implemented project components.

## 📈 Key Insights

**Evidence status:** Numerical market insights cannot be established without data. The following are verified observations about the analysis and its interpretation, not empirical market findings:

- The project uses two different location scopes: `Anywhere`/`Moscow` for analyses 1–2, all locations for analyses 3–5. Their rankings answer different questions.
- Analysis 3 includes postings without salary disclosure; analyses 4–5 require positive annual salaries. “Demand” therefore has different denominators across these outputs.
- Salary-based skill comparisons require at least 51 distinct postings per group. This is a coverage rule, not a guarantee of representativeness.
- Analysis 5 ranks demand before salary. A high salary alone cannot move a lower-demand skill ahead of a higher-demand one.

After running the reviewed queries, replace these observations with supported skill names, counts and salary comparisons, and update both READMEs together.

## 🧠 Skills Demonstrated

- Translating job-market questions into a sequence of SQL analyses.
- Joining fact, dimension and bridge tables at the correct grain.
- Filtering postings and aggregating skill demand and salary measures.
- Using CTEs, `HAVING` and distinct counts to structure comparisons.
- Distinguishing query scope, salary disclosure and association from causation.
- Reviewing Boolean logic and column visibility before interpreting results.
- Communicating analytical methods and evidence limitations through bilingual GitHub documentation.

## 💡 What I Learned

Through this project, I strengthened my ability to translate analytical questions into SQL and reason about table relationships, filters and aggregation. Reviewing the queries also helped me understand why population definitions and SQL correctness must be checked before turning an output into a market insight.

## 🚀 Future Improvements

Possible next steps:

- Record the dataset source, snapshot period and salary units.
- Export real results, add findings and build shared pandas/matplotlib charts.
- Check skill-name uniqueness, salary missingness, duplicate postings and tied rankings.
- Standardize comparison populations and add seniority, geography and posting-period breakdowns.
- Define an explicit demand–salary scoring method or explore a Pareto comparison.
- Develop a Power BI or Tableau dashboard after validating the dataset.

## 👤 About

This project is part of my Data Analytics portfolio and reflects my ongoing development in SQL, analytical thinking, and data-driven problem solving.
