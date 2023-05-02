SELECT *
FROM [Portfolio Project]..CovidDeaths
WHERE continent is null
order by 3,4

--SELECT *
--FROM [Portfolio Project]..CovidVaccinations
--order by 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
WHERE continent is null
order by 1, 2


-- TOTAL CASES VS TOTAL DEATHS
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%states%'
WHERE continent is null
order by 1, 2

-- Looking at Total Cases vs Population
--Shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null
order by 1, 2

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null
group by location, population
order by 4 DESC


-- Showing countries with the highest Death Count per Population

SELECT location, MAX(cast(TOTAL_DEATHS as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null
group by location
order by TotalDeathCount DESC


--EXPLORING DATA BY CONTINENT
-- Showing the continents with the highest death count
SELECT location, MAX(cast(TOTAL_DEATHS as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null
group by location
order by TotalDeathCount DESC



-- Global numbers

SELECT SUM(new_cases) as TotalCases, SUM(CAST(NEW_DEATHS AS INT)) as TotalDeaths, sum(CAST(NEW_DEATHS AS INT))/sum(new_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is NOT null
--group by date
order by 2 desc



--Looking at Total Population vs Vaccinations


SELECT *
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated,
	--(RollingPeopleVaccinated/dea.population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3

--Using CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/dea.population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/dea.population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating view to store data for later viz

CREATE VIEW PercentPopulationVaccinated1 as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/dea.population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated

