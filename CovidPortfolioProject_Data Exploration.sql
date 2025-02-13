SELECT *
FROM PortfolioProject..CovidDeaths
--Where continent is not null
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

--SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
--FROM PortfolioProject..CovidDeaths
--WHERE location like '%states'
--ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY 1,2



-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY 1,2



-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC



-- Countries with Highest Death Count per Population
-- Changed DataType of total_deaths using CAST

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
--WHERE location = 'India'
GROUP BY location
ORDER BY TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
-- Where continent is null
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is null
--WHERE location = 'India'
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT continent, location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where continent is null
--WHERE location = 'India'
GROUP BY continent, location
ORDER BY continent,TotalDeathCount DESC


-- Showing contintents with the highest death count per population
-- Where continent is not null
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
-- WHERE location = 'India'
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths as int)) AS Total_deaths,
		SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
--group by date
ORDER BY 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- Using CONVERT instead of CAST, both functions same
-- Bigint is used instead of just int as the sum is huge

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
		SUM(CONVERT(bigint, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
		ON Dea.location = Vac.location
		AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
ORDER BY 2, 3


-- Using CTE to perform Calculation on RollingPeopleVaccinated to Check percentage population vaccinated
-- as we cannot perform query on same column that we just created in the same query

With PopvsVac as
(SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
		SUM(CONVERT(bigint, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
		ON Dea.location = Vac.location
		AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100 as PopvsVacPercentage
FROM PopvsVac 



-- Using Temp To perform Calculation on RollingPeopleVaccinated to Check percentage population vaccinated

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
( continent nvarchar (225),
  location nvarchar (225),
  date datetime,
  population numeric,
  new_vaccination  numeric,
  RollingPeopleVaccinated numeric,
 )

Insert into #PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
		SUM(CONVERT(bigint, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
		ON Dea.location = Vac.location
		AND Dea.date = Vac.date
--WHERE Dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population)*100 as PopvsVacPercentage
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
		SUM(CONVERT(bigint, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
		ON Dea.location = Vac.location
		AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated






