SELECT *
FROM covid_deaths$
WHERE continent is not null
ORDER BY 3, 4

--SELECT *
--FROM covid_vaccinations$
--ORDER BY 3, 4

SELECT location, date total_cases, new_cases, total_deaths, population
FROM covid_deaths$
WHERE continent is not null
ORDER BY 1,2

--Calculating total cases vs total deaths in percentage
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percentage_of_death
FROM covid_deaths$
WHERE continent is not null 
--WHERE location like '%Germany%'
ORDER BY 1,2

--Calculating total cases vs total deaths in percentage for whole world
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percentage_of_death
FROM covid_deaths$
WHERE continent is not null
ORDER BY 1,2

--Calculating total cases vs population in percentage
SELECT location, date, total_cases, population, (total_cases/population)*100 as percentage_of_total_cases
FROM covid_deaths$
WHERE continent is not null
--WHERE location like '%Germany%'
ORDER BY 1,2

--Calculating total cases vs population in percentage in whole world
SELECT location, date, total_cases, population, (total_cases/population)*100 as percentage_of_total_cases
FROM covid_deaths$
WHERE continent is not null
ORDER BY 1,2

--Countries with highest covid infection rate per population
SELECT location, population, MAX(total_cases) AS highest_infection_rate, MAX((total_cases/population))*100 as percentage_of_total_cases
FROM covid_deaths$
WHERE continent is not null
--WHERE location like '%Germany%'
GROUP BY location, population
ORDER BY 4 DESC

--Continents with highest death rate per population
SELECT continent, MAX(cast(total_deaths as int)) AS total_death_count
FROM covid_deaths$
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC

--Countries with highest death rate per population
SELECT location, MAX(cast(total_deaths as int)) AS total_death_count
FROM covid_deaths$
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC

--Global Covid data
SELECT date, SUM(new_cases) as total_new_cases, SUM(cast(new_deaths as int)) as total_new_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as new_death_percentage
FROM covid_deaths$
WHERE continent is not null
GROUP BY date					
ORDER BY 1,2 

--Global Covid Data total numbers
SELECT SUM(new_cases) as total_new_cases, SUM(cast(new_deaths as int)) as total_new_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as new_death_percentage
FROM covid_deaths$
WHERE continent is not null
--GROUP BY date					
ORDER BY 1,2 


--Comparing total population and total vaccination
SELECT death.continent,death.location,death.population,death.date,covacc.new_vaccinations
	,SUM(CONVERT(bigint,convert(decimal, covacc.new_vaccinations))) OVER (PARTITION BY death.location  
	ORDER BY death.location, death.date) AS rolling_vaccination_count
FROM CovidData..covid_deaths$ death
	
JOIN CovidData..covidvaccinations$ covacc
	ON death.location = covacc.location
	AND death.date = covacc.date
WHERE death.continent IS NOT NULL 
ORDER BY 2,3

--Build a CTE
--create temporary table to find out percentage of people vaccinated per population
WITH popvsvacc (Continent, Location, Date, Population, New_Vaccinations, rolling_vaccination_count)
as
(
SELECT death.continent,death.location,death.date, death.population, covacc.new_vaccinations
	,SUM(CONVERT(bigint,convert(decimal, covacc.new_vaccinations))) OVER (PARTITION BY death.location  
	ORDER BY death.location, death.date) AS rolling_vaccination_count
FROM CovidData..covid_deaths$ death
	
JOIN CovidData..covidvaccinations$ covacc
	ON death.location = covacc.location
	AND death.date = covacc.date
WHERE death.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *, (rolling_vaccination_count/Population)*100
FROM popvsvacc


--Create a Temp table
DROP TABLE if exists #vaccinatedpopulationpercentage
Create Table #vaccinatedpopulationpercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_vaccination_Count numeric
)

Insert into #vaccinatedpopulationpercentage
SELECT death.continent,death.location,death.date, death.population, covacc.new_vaccinations
	,SUM(CONVERT(bigint,convert(decimal, covacc.new_vaccinations))) OVER (PARTITION BY death.location  
	ORDER BY death.location, death.date) AS rolling_vaccination_count
FROM CovidData..covid_deaths$ death	
JOIN CovidData..covidvaccinations$ covacc
	ON death.location = covacc.location
	AND death.date = covacc.date
--WHERE death.continent is NOT NULL
--ORDER BY 2,3

SELECT *, (rolling_vaccination_count/Population)*100
FROM #vaccinatedpopulationpercentage

--Storing a view for later visualizations
CREATE view vaccinatedpopulationpercentage as
SELECT death.continent,death.location,death.date, death.population, covacc.new_vaccinations
	,SUM(CONVERT(bigint,convert(decimal, covacc.new_vaccinations))) OVER (PARTITION BY death.location  
	ORDER BY death.location, death.date) AS rolling_vaccination_count
FROM CovidData..covid_deaths$ death	
JOIN CovidData..covidvaccinations$ covacc
	ON death.location = covacc.location
	AND death.date = covacc.date
WHERE death.continent is NOT NULL
--Order by 2,3

SELECT * 
FROM vaccinatedpopulationpercentage