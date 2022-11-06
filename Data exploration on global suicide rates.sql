
-- This an analysis of a dataset on suicides commited in each country from 1985 to 2016. Data such as age,gender,country,gdp are provided in this dataset


-- Selecting dataset to be used --
SELECT * FROM suicide
SELECT * FROM gdp_per_country

-- Looking at suicides per 100k in Canada since 1985
SELECT country,year,suicides_no, population, ROUND((suicides_no/population)*100000) AS 'suicides per 100000' FROM suicide
WHERE COUNTRY= 'Canada'
ORDER BY 1,2

-- Looking at global suicide numbers--
SELECT  year AS Year, sum(suicides_no) AS 'Total Number of Suicides' 
FROM suicide 
GROUP BY year
ORDER BY year DESC

-- Looking at Top 10 countries with highest suicides rates per 100k in last 20 years--

SELECT country, ROUND(sum((suicides_no/population)*100000)) AS 'total number of suicides' 
FROM suicide 
WHERE year > 2002
GROUP BY country
ORDER BY ROUND(sum((suicides_no/population)*100000)) DESC
LIMIT 10

-- Looking at countries with lowest suicide rates --
SELECT country, ROUND(sum((suicides_no/population)*100000)) AS 'Total number of Suicides' 
FROM suicide 
GROUP BY country
ORDER BY ROUND(sum((suicides_no/population)*100000))ASC
LIMIT 5

-- Looking at gender at higher risk of suicide among 15-24 year olds--

SELECT  age ,sex, ROUND(sum((suicides_no/population)*100000)) AS 'Total number of Suicides' FROM suicide
WHERE age= '15-24 years'
GROUP BY sex

-- Looking at age group at highest risk  of suicide--
SELECT age, ROUND(sum((suicides_no/population)*100000)) as 'total suicides'
FROM suicide 
GROUP BY age
ORDER BY ROUND(sum((suicides_no/population)*100000)) DESC
LIMIT 1

-- Looking at total number of suicides over last 20 years in the United States--
SELECT country, year, ROUND(sum((suicides_no/population)*100000)) AS 'total number of suicides' 
FROM suicide 
WHERE country= 'United States' and year >2002 
GROUP BY country, year
ORDER BY year DESC


-- Looking at suicides number over the year--
SELECT year, ROUND(sum((suicides_no/population)*100000)) AS 'total number of suicides' 
FROM suicide 
GROUP BY year
ORDER BY ROUND(sum((suicides_no/population)*100000)) ASC

--  Using CTE ---
WITH sui AS 
(SELECT country, year, ROUND(sum((suicides_no/population)*100000)) AS total
FROM suicide 
GROUP BY country, year
ORDER BY country)

SELECT sui.country, sui.year,`gdp_per_capita ($)`,total, sum(total) OVER (Partition by country order by sui.country, sui.year) as running_total
 from sui
JOIN gdp_per_country ON gdp_per_country.country=sui.country and gdp_per_country.year=sui.year

-- Temp table --
DROP Table if exists suicides_commited
Create Table suicides_commited
(
country varchar(255),
year int, 
total int)


INSERT INTO suicides_commited

SELECT country, year, ROUND(sum((suicides_no/population)*100000)) AS total
FROM suicide 
GROUP BY country, year
ORDER BY country

Select *  from suicides_commited



-- Create a view ---


Create view suicides_in_USA as 
SELECT country, year, sum((suicides_no/population)*100000) AS 'total number of suicides' 
FROM suicide 
WHERE country= 'United States' 
GROUP BY country, year
ORDER BY year DESC

Select * FROM suicides_in_USA 


-- Tableu queries --

-- Looking at Canada's suicide numbers from 1985-2016--
SELECT country, sum(suicides_no) AS 'Total number of Suicides' 
FROM suicide 
WHERE country='Canada'
group by country

-- Top 10 suicide rates over the world---
SELECT country, ROUND(sum((suicides_no/population)*100000)) AS 'total number of suicides' 
FROM suicide 
GROUP BY country
ORDER BY ROUND(sum((suicides_no/population)*100000)) DESC
LIMIT 10

-- suicide rate per country-- 
SELECT country, ROUND(sum((suicides_no/population)*100000)) AS 'total number of suicides' 
FROM suicide 
GROUP BY country
ORDER BY ROUND(sum((suicides_no/population)*100000)) DESC

-- Looking at suicides number over the years--
SELECT year AS Year, ROUND(sum((suicides_no/population)*100000)) AS 'Total number of Suicides' 
FROM suicide 
GROUP BY year
ORDER BY ROUND(sum((suicides_no/population)*100000)) ASC

-- suicide comparison between men and women---
SELECT sex AS Gender, ROUND(sum((suicides_no/population)*100000)) AS 'Total number of Suicides' 
FROM suicide 
GROUP BY sex
ORDER BY ROUND(sum((suicides_no/population)*100000)) DESC
-- suicide comparison between ages---

SELECT age AS Age, SUM(suicides_no) AS 'Total number of Suicides' 
FROM suicide 
GROUP BY age
ORDER BY SUM(suicides_no) DESC

-- suicides compared to gdp--
WITH sui AS 
(SELECT country, year, ROUND(sum((suicides_no/population)*100000)) AS Total
FROM suicide 
GROUP BY country, year
ORDER BY country)

SELECT sui.country AS Country, sui.year AS Year,`gdp_per_capita ($)` AS GDP_Per_Capita ,total AS Total
 from sui
JOIN gdp_per_country ON gdp_per_country.country=sui.country and gdp_per_country.year=sui.year

