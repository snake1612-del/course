/* 
What are the top paying data analyst jobs?
*/

SELECT
    company_dim.name,
    job_title,
    job_location,
    job_schedule_type,
    ROUND(salary_year_avg),
    job_posted_date
FROM
    job_postings_fact
LEFT JOIN company_dim
ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_title_short = 'Data Analyst' AND
    (job_location = 'Anywhere' OR job_location LIKE '%Moscow%') AND
    salary_year_avg IS NOT NULL
ORDER BY
    salary_year_avg DESC
LIMIT 10;
