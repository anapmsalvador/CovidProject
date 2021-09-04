

-- Select the data that we will be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..Death
WHERE continent IS NOT NULL 
ORDER BY 1,2


-- Looking at Total Cases vs. Total Deaths 

SELECT 
	location,
	date,
	Total_Deaths,
	Total_Cases,
	ROUND( 100 * (Total_Deaths / Total_Cases) ,2 ) as Death_Percentage 
FROM CovidProject..Death
WHERE continent IS NOT NULL 
ORDER BY 1,2 


-- Looking at New Cases vs. New Deaths
SELECT 
	location,
	date,
	New_Deaths,
	New_Cases,
	100 * (New_Deaths / NULLIF(New_Cases,0)) as New_Death_Percentage 
FROM CovidProject..Death
WHERE continent IS NOT NULL 
ORDER BY 1,2 


-- Looking at Total Cases vs Population ; Shows percentage of population contracted COVID 

SELECT 
	location,
	date,
	( total_cases / population) * 100  AS Infection_Rate 
FROM CovidProject..Death
WHERE continent IS NOT NULL 
ORDER BY 1,2 

-- Looking at Countries with the Highest infection Rate compared to Population 

With population_cases_cte AS (

SELECT
	location,
	population,
	MAX(Total_Cases) as total_infected 
FROM CovidProject..Death
WHERE continent IS NOT NULL 
GROUP BY location, population
)

SELECT
	location, 
	total_infected,
	(total_infected  / population ) * 100 AS Highest_Infection_Rate 
FROM population_cases_cte

ORDER BY 3 DESC 

-- Showing Countries with Highest Death Count Per Population 

SELECT 
	location,
	MAX(CAST(Total_deaths as int)) AS HighestDeath,
	( MAX(CAST(Total_deaths as int)) / population ) * 100 AS DeathPercentage 
FROM CovidProject..Death
WHERE continent IS NOT NULL
GROUP BY location, population 
ORDER BY 2 DESC 



-- Showing continents with highest death count per population 

SELECT 
	location,
	MAX(CAST(Total_deaths as int)) AS HighestDeath,
	( MAX(CAST(Total_deaths as int)) / population ) * 100 AS DeathPercentage 
FROM CovidProject..Death
WHERE continent IS NULL
GROUP BY location, population 
ORDER BY 2 DESC ;


-- Global Numbers of Total Death to Total Cases per day 

SELECT 
	date,
	SUM(new_cases) AS TotalCases,
	SUM(CAST(new_deaths as INT)) AS TotalDeaths,
	(SUM(CAST(new_deaths as INT)) / SUM(new_cases) )* 100 as World_Death_Percentage 
FROM CovidProject..Death
WHERE continent IS NOT NULL 
GROUP BY date 
ORDER BY 1


-- Total Population vs Vaccinations, including Rolling Count of Vaccinations per Day per Country 

SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
From CovidProject..Death dea
Join CovidProject..Vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to Peform a Calculation on Above Query : Getting the ratio of newly vaccinated to total population 

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT 
	dea.continent,
	 dea.location, 
	 dea.date, 
	 dea.population, 
	 vac.new_vaccinations,
	 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidProject..Death dea
Join CovidProject..Vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS Percentage_Rolling 
FROM PopvsVac





