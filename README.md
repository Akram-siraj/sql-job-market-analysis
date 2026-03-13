# SQL Data Job Market Analysis

Analysed 787,000+ real-world job postings using PostgreSQL to uncover actionable insights for Data Analyst career development.

## Project Overview

This project uses SQL to answer five key career questions for aspiring Data Analysts. Each query targets a different business question and demonstrates a different core SQL concept.

**Database:** 787,000+ job postings across multiple countries and roles  
**Tool:** PostgreSQL + VS Code + SQLTools  
**Focus:** Data Analyst roles — salaries, skills, and hiring trends

## Database Schema

| Table | Description |
|-------|-------------|
| `job_postings_fact` | All job postings with salary, location, and date data |
| `company_dim` | Company names and details |
| `skills_dim` | Skill names and categories |
| `skills_job_dim` | Bridge table linking jobs to required skills |

---

## Queries

### Query 1 — Top Paying Remote Data Analyst Jobs
**Question:** What are the top-paying jobs for Data Analyst role?

Identifies the top 10 highest-paying remote Data Analyst roles with specified salaries, joined with company names.

**SQL Concepts:** JOINs, WHERE filtering, ORDER BY, LIMIT

```sql
SELECT j.*, c.name AS company
FROM job_postings_fact j
LEFT JOIN company_dim c ON j.company_id = c.company_id
WHERE
    job_title_short = 'Data Analyst' AND
    salary_year_avg IS NOT NULL AND
    job_location = 'Anywhere'
ORDER BY salary_year_avg DESC
LIMIT 10;
```

**Result:** Salaries range from $184,000 to $650,000 — senior and director level titles dominate.

---

### Query 2 — Monthly Hiring Trends
**Question:** How does hiring activity change throughout the year?

Counts total Data Analyst job postings per month to identify peak hiring periods.

**SQL Concepts:** Date Functions, EXTRACT, GROUP BY, ORDER BY

```sql
SELECT
    EXTRACT(MONTH FROM job_posted_date) AS month,
    COUNT(job_id) AS total_jobs
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY EXTRACT(MONTH FROM job_posted_date)
ORDER BY month ASC;
```

**Result:** January peaks at 23,697 postings. August is the strongest mid-year window. May and December are the slowest months.

---

### Query 3 — Most In-Demand Skills
**Question:** What are the most in-demand skills for Data Analyst role?

Identifies the top 5 most frequently requested skills across all Data Analyst job postings using a 3-table JOIN.

**SQL Concepts:** Multiple JOINs, COUNT, GROUP BY, LIMIT

```sql
SELECT
    COUNT(j.job_id) AS skill_count,
    s.skills AS skill_name
FROM job_postings_fact j
INNER JOIN skills_job_dim sj ON j.job_id = sj.job_id
INNER JOIN skills_dim s ON sj.skill_id = s.skill_id
WHERE job_title_short = 'Data Analyst'
GROUP BY s.skills
ORDER BY COUNT(j.job_id) DESC
LIMIT 5;
```

**Result:** SQL leads with 92,628 postings (46.8%), followed by Excel, Python, Tableau, and Power BI.

---

### Query 4 — Remote vs Onsite Salary Comparison
**Question:** Do remote jobs pay more than onsite roles?

Uses a CASE expression to categorise jobs as Remote or Onsite and compares average salaries.

**SQL Concepts:** CASE Expressions, AVG, ROUND, GROUP BY

```sql
SELECT
    CASE job_location
        WHEN 'Anywhere' THEN 'Remote'
        ELSE 'Onsite'
    END AS location_type,
    COUNT(job_id) AS total_jobs,
    ROUND(AVG(salary_year_avg), 2) AS average_salary
FROM job_postings_fact
WHERE
    job_title_short = 'Data Analyst' AND
    salary_year_avg IS NOT NULL
GROUP BY location_type
ORDER BY average_salary DESC;
```

**Result:** Remote pays $94,770 vs Onsite $93,765 — a $1,005 difference. Remote roles are 8x rarer.

---

### Query 5 — Most Optimal Skills to Learn
**Question:** What are the most optimal skills to learn?

Uses a CTE and RANK() window function to rank remote Data Analyst skills by demand alongside average salary.

**SQL Concepts:** CTEs, Window Functions, RANK(), OVER(), LEFT JOIN

```sql
WITH skill_stat AS (
    SELECT
        COUNT(sj.skill_id) AS skill_count,
        s.skills,
        ROUND(AVG(j.salary_year_avg), 2) AS average_salary
    FROM skills_job_dim sj
    LEFT JOIN skills_dim s ON sj.skill_id = s.skill_id
    LEFT JOIN job_postings_fact j ON sj.job_id = j.job_id
    WHERE
        j.job_title_short = 'Data Analyst' AND
        j.job_location = 'Anywhere' AND
        j.salary_year_avg IS NOT NULL
    GROUP BY s.skills
)
SELECT
    skills,
    skill_count,
    average_salary,
    RANK() OVER (ORDER BY skill_count DESC) AS demand_rank
FROM skill_stat
ORDER BY demand_rank;
```

**Result:** Python is the most optimal skill — top 3 in demand and $101,397 average salary. SQL is essential at rank 1.

---

## Key Findings

| Area | Finding |
|------|---------|
| Best month to apply | January or August |
| Most in-demand skill | SQL — in 46.8% of all postings |
| Highest paying role | Director / Principal level at big tech |
| Most optimal skill | Python — high demand + $101,397 avg salary |
| Optimal learning path | SQL → Python → Tableau → R |

---

## What I Learned

| SQL Concept | How It Was Applied |
|-------------|-------------------|
| JOINs | Connected job postings, companies and skills across 4 related tables |
| Aggregate Functions | Used COUNT and AVG to summarise salary and skill demand at scale |
| CASE Expressions | Categorised job locations into Remote and Onsite groups dynamically |
| Date Functions | Used EXTRACT to isolate month from timestamp and analyse hiring trends |
| CTEs | Structured complex multi-step logic into clean, readable query blocks |
| Window Functions | Applied RANK() with OVER() to rank skills by demand |
| HAVING | Filtered aggregated results to include only titles with sufficient data |
| NULL Handling | Excluded unspecified salaries using IS NOT NULL for accurate averages |

---

## Tools Used

- **PostgreSQL 17** — database engine
- **VS Code** — development environment
- **SQLTools Extension** — running queries inside VS Code
