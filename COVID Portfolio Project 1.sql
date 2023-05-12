SELECT *
FROM Projects..CovidDeaths
WHERE continent is not null
order by 3,4

/* SELECT *
FROM Projects..CovidVaccinations
order by 3,4 */

-- Select Data that we are going to be using

SELECT Location, Date, Total_Cases, New_cases, Total_deaths, population
FROM Projects..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contracted COVID in your country
SELECT Location, Date, Total_Cases, Total_deaths, (Total_Deaths/Total_Cases)*100 as DeathPercentage
FROM Projects..CovidDeaths
WHERE location like '%states%'
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population contracted COVID
SELECT Location, Date, Population, Total_Cases, (Total_Cases/Population)*100 as CasePercentage
FROM Projects..CovidDeaths
--WHERE location like '%states%'
order by 1,2


-- Identify which countries have the highest infection rates
SELECT Location, Population, MAX(Total_Cases) as HighestInfectionCount, MAX((Total_Cases/Population))*100 as CasePercentage
FROM Projects..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
order by CasePercentage DESC


--Showing countries with Higest Death Count per Population
SELECT location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM Projects..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null
GROUP BY location
order by TotalDeathCount DESC


-- Breakdown by continent

-- Showing continents with the highest death count per population
SELECT continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM Projects..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null
GROUP BY continent
order by TotalDeathCount DESC


-- Global numbers

SELECT SUM(Total_Cases) as TotalCaseCount, SUM(cast(new_deaths as int)) as TotalNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--, Total_deaths, (Total_Deaths/Total_Cases)*100 as DeathPercentage
FROM Projects..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY Date
order by 1,2


--Looking at Total Population vs Vaccinations

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(int, CV.new_vaccinations)) OVER (Partition by cd.location Order by cd.location,
cd.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Projects..CovidDeaths CD
JOIN Projects..CovidVaccinations CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE cd.continent is not null
ORDER BY 2,3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(int, CV.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location,
cd.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Projects..CovidDeaths CD
JOIN Projects..CovidVaccinations CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE cd.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table

DROP TABLE if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(int, CV.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location,
cd.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Projects..CovidDeaths CD
JOIN Projects..CovidVaccinations CV
	ON CD.location = CV.location
	AND CD.date = CV.date
--WHERE cd.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to Store data for later visualizations

Create View PercentPopulationVaccinated as 
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(int, CV.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location,
cd.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Projects..CovidDeaths CD
JOIN Projects..CovidVaccinations CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE cd.continent is not null
--ORDER BY 2,3

SELECT *
From PercentPopulationVaccinated