Use PortfolioProject;
GO
SELECT* FROM [dbo].[CovidDeath]
WHERE continent is NOT NULL
-- another way 
--SELECT* FROM  PortfolioProject..CovidDeath
--ORDER BY 3,4
-- SELECT data that were going to be using 
SELECT Location,date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeath
WHERE continent is NOT NULL
ORDER BY 1,2

 -- change data type 
ALTER TABLE  PortfolioProject..CovidDeath
ALTER column  total_cases INT NULL;
ALTER TABLE  PortfolioProject..CovidDeath
ALTER column  total_deaths INT NULL;

-- Looking at total cases vs total deaths
SELECT location, SUM (total_cases) AS Cases,SUM (total_deaths) AS Deaths 
FROM PortfolioProject..CovidDeath 
GROUP BY location;
-- CHECK THE DATA TYPE because of error
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH, 
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CovidDeath';

-- Looking at total cases vs total deaths
SELECT location, date, total_cases, total_deaths, cast((total_deaths/total_cases)*100 as decimal(2,2)) AS DeathPercentage 
FROM CovidDeath
WHERE location like '%states%' AND  continent is NOT NULL
ORDER BY 1,2 -- In the output I got 0 its a common pitfall in SQL server due to how it handles integer division
-- dividing 2 integers the result is integer too so the decimal part is truncated 
-- solution: convert numerator into float or decimal!!!

--Likelihood of dying if you contract Covid in your country 
SELECT location, date, total_cases, total_deaths, (cast (total_deaths AS decimal (10,2)) /total_cases)*100  AS DeathPercentage 
FROM CovidDeath
WHERE location like '%occo'
ORDER BY 1,2 
-- Looking at total cases VS Population 
SELECT location, date, total_cases, population, (cast (total_cases AS decimal (10,2)) /population)*100  AS Percentpopulationinfected
FROM CovidDeath
WHERE location like '%occo'
ORDER BY 1,2 
-- WHAT COUNTRY HAS THE HIGHEST INFECTION RATE (cases/population)
SELECT location, population,MAX (total_cases) AS Highestinfectioncount, Max ((cast (total_cases AS decimal (20,10)) /population)*100) AS HighestInfectionRate
FROM CovidDeath
GROUP BY location, population
ORDER BY HighestInfectionRate DESC
-- Showing countries with highest death count per population
SELECT location, population,MAX (total_deaths) AS Highestdeathcount, Max ((cast (total_deaths AS decimal (20,10)) /population)*100) AS HighestdeathRate
FROM CovidDeath
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY Highestdeathcount DESC
-- Break things down by continent 
SELECT continent,MAX (total_deaths) AS Highestdeathcount, Max ((cast (total_deaths AS decimal (20,10)) /population)*100) AS HighestdeathRate
FROM CovidDeath
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY Highestdeathcount DESC
-- correct query 
SELECT location,MAX (total_deaths) AS Highestdeathcount, Max ((cast (total_deaths AS decimal (20,10)) /population)*100) AS HighestdeathRate
FROM CovidDeath
WHERE continent is NULL
GROUP BY location
ORDER BY Highestdeathcount DESC
-- death and vaccinations
SELECT* FROM PortfolioProject..CovidDeath dea 
JOIN PortfolioProject..CovidVaccinations vac ON
dea.date=vac.date AND dea.location=vac.location;
-- Example of rolling count ( cumul) of new vaccinations by location and date: sum (xx) OVER (PARTITION BY LOCATION ORDER BY LOCATION)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (Convert(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS newvaccinationsAccumulation
FROM PortfolioProject..CovidDeath dea  JOIN  PortfolioProject..CovidVaccinations vac ON
dea.date=vac.date AND dea.location=vac.location
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3 

-- we can use the query above to create a CTE 
WITH PopvsVac (continent,location,date,population,new_vaccinations,newvaccinationsAccumulation)
AS -- make sure you have the same column numbers (with vs select)
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (Convert(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS newvaccinationsAccumulation
FROM PortfolioProject..CovidDeath dea  JOIN  PortfolioProject..CovidVaccinations vac ON
dea.date=vac.date AND dea.location=vac.location
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3
)
--SELECT* FROM PopvsVac --you should write after with (xx) select to avoid error

SELECT*, (newvaccinationsAccumulation/population)*100 AS VACCpercent 
FROM PopvsVac;
-- Create a genuine table instead of temporary one (CTE) 
DROP TABLE IF EXISTS POPVACC
CREATE TABLE POPVSVAC(
Continent nvarchar (255),
Location nvarchar (255),
date datetime,
Population numeric ,
New_vaccinations INT,
NewvaccinationsAccumulation INT)
INSERT INTO POPVSVAC 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (Convert(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS newvaccinationsAccumulation
FROM PortfolioProject..CovidDeath dea  JOIN  PortfolioProject..CovidVaccinations vac ON
dea.date=vac.date AND dea.location=vac.location
WHERE dea.continent IS NOT NULL

select* from POPVSVAC

-- CREATE view to store data later for 

CREATE VIEW popvaccview
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (Convert(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS newvaccinationsAccumulation
FROM PortfolioProject..CovidDeath dea  JOIN  PortfolioProject..CovidVaccinations vac ON
dea.date=vac.date AND dea.location=vac.location
WHERE dea.continent IS NOT NULL;

DROP VIEW if exists popvaccview
