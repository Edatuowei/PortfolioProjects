Select *
From PortfolioProject..CovidDeaths$
Where continent is not NULL
Order by 3, 4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order by 1,2

--Looking at Total Cases vs Total Deaths in the U.S. over time

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths$
Where Location like'%states%'
Order by 1,2

--Looking at Total Cases vs the population
--Prevalence of covid in the population

Select Location, date, total_cases, population, (total_cases/population)*100 AS CovidPrevalence
From PortfolioProject..CovidDeaths$
Where Location like '%states%'
Order by 1,2

--Looking at Countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Group by Location, Population
Order by PercentPopulationInfected desc

--Looking at Countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not NULL
Group by Location
Order by TotalDeathCount desc

--Correct: Highest death count grouped by continent

--Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--From PortfolioProject..CovidDeaths$
--Where continent is null
--Group by location
--Order by TotalDeathCount desc


--Death count grouped by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global Numbers

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by date
Order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 1,2
	

--Percentage of the Population Vaccinated using CTE

With PopVsVac (Continent, Location, Date, Population, new_vaccinations, CumulativeVaccinations)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS CumulativeVaccinations
--, (CumulativeVaccinations/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (CumulativeVaccinations/Population)*100 AS PercentPopVaccinated
From PopVsVac

-- Percent of Population Vaccinated using a Temp Table

--Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativeVaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS CumulativeVaccinations
--, (CumulativeVaccinations/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select *, (CumulativeVaccinations/Population)*100 AS PercentPopVaccinated
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS CumulativeVaccinations
--, (CumulativeVaccinations/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

SELECT *
FROM PercentPopulationVaccinated