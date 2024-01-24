
/*
Covid 19 Data Exploration project 

Skills used: Joins, CTE's, Temp Tables Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM sqlproject..CovidDeaths
WHERE continent is not null 



-- Select Data that we are going to be starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM sqlproject..CovidDeaths
WHERE continent is not null 
ORDER BY  1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM sqlproject..CovidDeaths
WHERE location like '%states%'
and continent is not null 
ORDER BY  1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, date, Population, total_cases,  (total_cases/population)*100 AS PercentPopulationInfected
FROM sqlproject..CovidDeaths
ORDER BY  1,2


-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  Max((total_cases/population))*100 AS PercentPopulationInfected
FROM sqlproject..CovidDeaths
GROUP BY  Location, Population
ORDER BY  PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths AS INT)) AS TotalDeathCount
FROM sqlproject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY  Location
ORDER BY  TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths AS INT)) AS TotalDeathCount
FROM sqlproject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY  TotalDeathCount DESC



-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM sqlproject..CovidDeaths
WHERE continent IS NOT NULL 
--Group By date
ORDER BY  1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
FROM sqlproject..CovidDeaths dea
JOIN sqlproject..CovidVacination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
FROM sqlproject..CovidDeaths dea
JOIN sqlproject..CovidVacination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE  #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY  dea.Location ORDER BY  dea.location, dea.Date) AS RollingPeopleVaccinated
FROM sqlproject..CovidDeaths dea
JOIN sqlproject..CovidVacination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--where dea.continent is not null 

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated




-- Creating View to store data for  visualizations

CREATE VIEW  PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY  dea.location, dea.Date) AS RollingPeopleVaccinated
FROM sqlproject..CovidDeaths dea
JOIN sqlproject..CovidVacination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

