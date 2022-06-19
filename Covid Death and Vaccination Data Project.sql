-- Covid19 Deaths 
SELECT *
FROM [Covid Death and Vaccination Data Project]..CovidDeaths
WHERE continent is not null
ORDER by 3,4

-- Covid19 Vaccination
SELECT *
FROM [Covid Death and Vaccination Data Project]..CovidVaccinations
ORDER by 3,4

-- Usable Data for Covid Deaths
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Covid Death and Vaccination Data Project]..CovidDeaths
WHERE continent is not null
ORDER by 1,2

-- Percentage of Total Cases Versus Total Deaths (shows the likelihood of dying if you contract in Nigeria)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Covid Death and Vaccination Data Project]..CovidDeaths
WHERE location like '%nigeria%'
and continent is not null
ORDER by 1,2

-- Percentage of Total Cases Versus Population (shows percentage of population each country that got Covid)
SELECT location, date, population, total_cases, (total_cases/ population)*100 as PercentagePopulationInfected
FROM [Covid Death and Vaccination Data Project]..CovidDeaths
WHERE continent is not null
ORDER by 1,2

-- Percentage of Total Cases Versus Population (shows percentage of population in Nigeria that got Covid)
SELECT location, date, population, total_cases, (total_cases/ population)*100 as PercentPopulationInfected
FROM [Covid Death and Vaccination Data Project]..CovidDeaths
WHERE location like '%nigeria%'
and continent is not null
ORDER by 1,2

-- Countries with the Highest Rate of Infection by Population Percentage
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/ population))*100 as PercentPopulationInfected
FROM [Covid Death and Vaccination Data Project]..CovidDeaths
WHERE continent is not null
GROUP by location, Population
ORDER by PercentPopulationInfected desc

-- Countries with the Highest Rate of Death Count by Population Percentage
SELECT location, MAX(cast (total_deaths as int)) as TotalDeathCount
FROM [Covid Death and Vaccination Data Project]..CovidDeaths
WHERE continent is not null
GROUP by location
ORDER by TotalDeathCount desc

-- TOTAL DEATH COUNTS BY CONTINENTS
-- Continent with the highest death count per opulation
SELECT continent, MAX(cast (total_deaths as int)) as TotalDeathCount
FROM [Covid Death and Vaccination Data Project]..CovidDeaths
WHERE continent is not null
GROUP by continent
ORDER by TotalDeathCount desc

-- GLOBAL NUMBERS
-- Global Numbers (Total)
SELECT SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_death, SUM(cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercent
FROM [Covid Death and Vaccination Data Project]..CovidDeaths
-- WHERE location like '%nigeria%'
WHERE continent is not null
order by 1,2

-- Global Numbers (Daily)
SELECT date, SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_death, SUM(cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercent
FROM [Covid Death and Vaccination Data Project]..CovidDeaths
-- WHERE location like '%nigeria%'
WHERE continent is not null
GROUP by date
order by 1,2

-- JOINING COVID DEATH TABLE WITH COVID VACCINATION TABLE USING DATE AND LOCATION

-- Global Numbers, Total Population Versus Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [Covid Death and Vaccination Data Project]..CovidDeaths dea
JOIN [Covid Death and Vaccination Data Project]..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
WHERE dea.continent is not null
ORDER by 2,3

-- Global Numbers, Total Population Versus Vaccinations (Rolling Count)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert (bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingCountPeopleVaccinated
-- , (RollingCountPeopleVaccinated/population)*100
FROM [Covid Death and Vaccination Data Project]..CovidDeaths dea
JOIN [Covid Death and Vaccination Data Project]..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
WHERE dea.continent is not null
ORDER by 2,3

-- USING CTE
With PopvsVac (Continent, Location, Date, Population, New_VAccinations, RollingCountPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert (bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingCountPeopleVaccinated
-- , (RollingCountPeopleVaccinated/population)*100
FROM [Covid Death and Vaccination Data Project]..CovidDeaths dea
JOIN [Covid Death and Vaccination Data Project]..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
WHERE dea.continent is not null
-- ORDER by 2,3
)
Select *, (RollingCountPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingCountPeopleVaccinated numeric
)

Insert into  #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert (bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingCountPeopleVaccinated
-- , (RollingCountPeopleVaccinated/population)*100
FROM [Covid Death and Vaccination Data Project]..CovidDeaths dea
JOIN [Covid Death and Vaccination Data Project]..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
-- WHERE dea.continent is not null
-- ORDER by 2,3

Select *, (RollingCountPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- USABLE VIEWS

-- VIEW FOR total death percent worldwide
Create view GlobalDeathPercent as
SELECT SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_death, SUM(cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercent
FROM [Covid Death and Vaccination Data Project]..CovidDeaths
-- WHERE location like '%nigeria%'
WHERE continent is not null

SELECT *
From GlobalDeathPercent


-- VIEW FOR Continent with the highest death count per population
Create view ContinentHighestDeathPopulation as
SELECT continent, MAX(cast (total_deaths as int)) as TotalDeathCount
FROM [Covid Death and Vaccination Data Project]..CovidDeaths
WHERE continent is not null
GROUP by continent

SELECT *
From ContinentHighestDeathPopulation

-- VIEW FOR Percent of Population that got Vaccinated
Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert (bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingCountPeopleVaccinated
-- , (RollingCountPeopleVaccinated/population)*100
FROM [Covid Death and Vaccination Data Project]..CovidDeaths dea
JOIN [Covid Death and Vaccination Data Project]..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date

SELECT *
FROM PercentPopulationVaccinated