/*
What are the top skills based on salary?
*/

SELECT
    skills,
    ROUND(AVG(salary_year_avg)) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
WHERE
    job_title_short = 'Data Analyst' AND
    salary_year_avg > 0
GROUP BY
    skills
HAVING
    COUNT(DISTINCT job_postings_fact.job_id) > 50
ORDER BY
    avg_salary DESC
LIMIT 15