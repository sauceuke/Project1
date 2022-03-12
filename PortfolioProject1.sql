SELECT *
FROM Project1.coviddeathcount
WHERE continent IS NOT null
ORDER BY 3,4;

-- SELECT *
-- FROM Project1.covidvaccinations
-- ORDER BY 3,4;

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Project1.coviddeathcount
ORDER by 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows the Likelihood of you contracting and dying from Covid-19 today

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM Project1.coviddeathcount
WHERE continent LIKE '%States%'
ORDER BY 1,2;

-- Looking at Total Cases vs Population 
-- Shows percentage of Population that has contracted Covid-19

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationPercentage 
FROM Project1.coviddeathcount
WHERE continent LIKE '%States%'
ORDER BY 1,2;

-- Looking at Countries with Highest infection rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PopulationInfectedPercentage 
FROM Project1.coviddeathcount
-- WHERE location LIKE '%States%'
GROUP BY continent, population
ORDER BY PopulationInfectedPercentage DESC;

-- Showing Countries with Highest death count per Population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM Project1.coviddeathcount
WHERE continent IS NOT null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Let's Break down the stats by Continent

SELECT continent, MAX(CAST(total_death) AS int) AS TotalDeathCount
FROM Project1.coviddeathcount
WHERE continent IS NOT null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global Numbers

SELECT location, date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM Project1.coviddeathcount
-- WHERE location LIKE '%states%'
WHERE continent IS NOT null
-- GROUP BY date
ORDER BY 1,2;

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(COVERT(int,vac.new_vaccinations, int)) OVER (Partition by dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM Project1.coviddeathcount AS dea
JOIN Project1.covidvaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER BY 2,3;

-- Use CTE

With PopvsVac (Continent, Location, Date, New_Vaccinations, Population, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(COVERT(int,vac.new_vaccinations, int)) OVER (Partition by dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM Project1.coviddeathcount AS dea
JOIN Project1.covidvaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT null
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE

DROP Table if exists
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea,population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated 
-- , RollingPeopleVaccinated/population)*100
FROM Project1.coviddeathcount AS dea
JOIN Project1.covidvaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date 
-- WHERE dea.continent IS NOT null
-- ORDER by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Project1.coviddeathcount AS dea
JOIN Project1.covidvaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT null
-- ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated









