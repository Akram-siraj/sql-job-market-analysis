-- ============================================================
-- SQL Data Job Market Analysis
-- Tool: PostgreSQL
-- Dataset: 787,000+ job postings
-- Focus: Data Analyst roles
-- ============================================================


-- ============================================================
-- Query 1: Top Paying Remote Data Analyst Jobs
-- Question: What are the top-paying jobs for my role?
-- ============================================================

SELECT
    j.job_id,
    j.job_title,
    j.job_location,
    j.job_schedule_type,
    j.salary_year_avg,
    j.job_posted_date::date,
    c.name AS company
FROM job_postings_fact j
LEFT JOIN company_dim c ON j.company_id = c.company_id
WHERE
    j.job_title_short = 'Data Analyst' AND
    j.salary_year_avg IS NOT NULL AND
    j.job_location = 'Anywhere'
ORDER BY j.salary_year_avg DESC
LIMIT 10;


-- ============================================================
-- Query 2: Monthly Hiring Trends
-- Question: How does hiring activity change throughout the year?
-- ============================================================

SELECT
    EXTRACT(MONTH FROM job_posted_date) AS month,
    COUNT(job_id) AS total_jobs
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY EXTRACT(MONTH FROM job_posted_date)
ORDER BY month ASC;


-- ============================================================
-- Query 3: Most In-Demand Skills
-- Question: What are the most in-demand skills for my role?
-- ============================================================

SELECT
    COUNT(j.job_id) AS skill_count,
    s.skills AS skill_name
FROM job_postings_fact j
INNER JOIN skills_job_dim sj ON j.job_id = sj.job_id
INNER JOIN skills_dim s ON sj.skill_id = s.skill_id
WHERE j.job_title_short = 'Data Analyst'
GROUP BY s.skills
ORDER BY skill_count DESC
LIMIT 5;


-- ============================================================
-- Query 4: Remote vs Onsite Salary Comparison
-- Question: Do remote jobs pay more than onsite roles?
-- ============================================================

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


-- ============================================================
-- Query 5: Most Optimal Skills to Learn
-- Question: What are the most optimal skills to learn?
-- ============================================================

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
