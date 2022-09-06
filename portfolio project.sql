
Select *
From PortfolioProject..CovidDeaths
Order by 3,4

--Select *
--From PortfolioProject..CovidVacination
--Order by 3,4

--Select Data that we are going to use
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

--Looking at total cases vs total deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%nigeria%'
Order by 1,2

-- Looking at Total Cases vs Population
Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where Location like '%nigeria%'
Order by 1,2

Select Location, MAX(total_cases) as Highest_Infection_Count, population, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where Location like '%nigeria%'
Group by Location, population
Order by PercentPopulationInfected desc

-- Showing countries with Highest Death count per population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is not null
Group by Location
order by TotalDEathCount  desc

--LET"S BREAK THINGS DOWN BY CONTINENT
-- Showing continent with the Highest Death count
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent is not null
Group by continent
Order by TotalDeathCount desc

--GLOBAL NUMBERS
SELECT  SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE Continent is not null
--Group by date
Order by 1,2

--looking at total population vs vacination
SELECT dea.date,dea.continent,dea.population,dea.location,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location,dea.date) as Rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..covidvacination vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
Order by 2,3

--using CTE
with PopvsVac (date, continent, population,location, new_vaccinations, RolligPeopleVaccinated)
as
(SELECT dea.date,dea.continent,dea.population,dea.location,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..covidvacination vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RolligPeopleVaccinated/population)*100 as PercentageofpeopleVaccinated
FROM PopvsVac

-- TEMP TABLE

Drop Table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Date datetime,
Continent nvarchar(255),
Population numeric,
Location nvarchar(255),
New_vaccination numeric,
Rollingpeoplevaccinated numeric,
)
insert into #PercentPopulationVaccinated
SELECT dea.date,dea.continent,dea.population,dea.location,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..covidvacination vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
SELECT *, (Rollingpeoplevaccinated/population)*100 as PercentageofpeopleVaccinated
FROM #PercentPopulationVaccinated

--Create View for Later Visualisation
Create View PercentPopulationVaccinated as
SELECT dea.date,dea.continent,dea.population,dea.location,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..covidvacination vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3


SELECT *
FROM PercentPopulationVaccinated


--queries for Tableau Visualization
--1
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%nigeria%'
where continent is not null 
--Group By date
order by 1,2

--2
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

--3
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--4
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc