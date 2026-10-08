/*
What are the most optimal skills to learn?
*/

WITH skills_demand AS (
    SELECT 
        skills_job_dim.skill_id,
        skills_dim.skills,
        COUNT(DISTINCT job_postings_fact.job_id) AS demand_count
    FROM job_postings_fact
    INNER JOIN skills_job_dim 
        ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim 
        ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_title_short = 'Data Analyst'
        AND salary_year_avg > 0
    GROUP BY
        skills_job_dim.skill_id,
        skills_dim.skills
),

average_salary AS (
    SELECT
        skills_job_dim.skill_id,
        skills_dim.skills,
        ROUND(AVG(salary_year_avg)) AS avg_salary
    FROM job_postings_fact
    INNER JOIN skills_job_dim 
        ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim 
        ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_title_short = 'Data Analyst'
        AND salary_year_avg > 0
    GROUP BY
        skills_job_dim.skill_id,
        skills_dim.skills
)

SELECT
    DISTINCT skills_demand.skills,
    demand_count,
    avg_salary
FROM skills_demand
INNER JOIN average_salary 
    ON skills_demand.skill_id = average_salary.skill_id
WHERE
    demand_count > 50
ORDER BY
    demand_count DESC,
    avg_salary DESC
LIMIT 10;