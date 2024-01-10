-- Select from CovidDeath table

SELECT *
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
ORDER BY 3, 4;

-- Select from CovidVaccinations table

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3, 4;

-- Calculate DeathPercentage for Morocco

SELECT
    Location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeath
WHERE location LIKE '%morocco%'
ORDER BY 1, 2;

-- Alter data type of new_vaccinations column in Covidvaccinations table

ALTER TABLE Covidvaccinations
ALTER COLUMN new_vaccinations FLOAT;

-- Execute sp_help for 'coviddeath' table

EXEC sp_help 'coviddeath';

-- Calculate CasebyPopulation for Morocco

SELECT
    Location,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 AS CasebyPopulation
FROM PortfolioProject..CovidDeath
WHERE location LIKE '%morocco%'
ORDER BY 1, 2;

-- Countries with the highest infection rate compared to the population

SELECT
    Location,
    Population,
    MAX(total_cases) AS HighestInfectioncount,
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeath
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

-- Countries with the highest death count per Population

SELECT
    Location,
    MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- Breakdown by continent for death count

SELECT
    continent,
    MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Continent with the highest death count per population

SELECT
    continent,
    MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global Numbers
-- Total population vs. vaccination using CTE

WITH PopvsVac (Continent, Location, date, population, new_vaccinations, Totalvaccination) AS (
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Totalvaccination
    FROM PortfolioProject..CovidVaccinations vac
    JOIN PortfolioProject..CovidDeath dea ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (Totalvaccination / population) * 100 AS RollingPopulationVaccinated
FROM PopvsVac;

-- Temporary table for PercentagePopulationVaccinated

DROP TABLE IF EXISTS #PercentagePopulationVaccinated;
CREATE TABLE #PercentagePopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPopulationVaccinated NUMERIC
);

-- Insert data into the temporary table

INSERT INTO #PercentagePopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Totalvaccination
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeath dea ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- Select data from the temporary table

SELECT *, (RollingPopulationVaccinated / population) * 100
FROM #PercentagePopulationVaccinated;

-- Create a view to store data for later visualization

CREATE VIEW testPercentagePopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Totalvaccination
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeath dea ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- Select from the temporary table

SELECT *
FROM #PercentagePopulationVaccinated;
