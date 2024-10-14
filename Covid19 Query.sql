Select *
From PortfolioProject..CovidDeaths
--Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Selecting the Data be used for the exploration

Select Location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

-- Exploring Total Cases Vs Total Death
-- Shows the Likelihood of dying if you have covid in a specific country

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%nigeria%'
and continent is not null
Order by 1,2

-- Exploring Total cases Vs Population
-- Shows the percentage of people infected with covid in a specific location

Select Location, Date, Population, total_cases, (total_cases/Population)* 100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%nigeria%'
Where continent is not null
Group by 
Order by 1,2

-- Looking at Countries with the Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/Population))* 100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%nigeria%'
Where continent is not null
Group by Location, Population
Order by 4 desc

-- Exploring Countries with the Highest Death Count Per Population

Select Location, MAX(cast(total_deaths as int))  as HighestTotalDeaths
From PortfolioProject..CovidDeaths
--Where location like '%nigeria%'
Where continent is not null
Group by Location
Order by 2 desc

--BREAKING IT UP BY CONTINENT
--Showing continent with the highest death count per population

Select continent, MAX(cast(total_deaths as int))  as TotalDeathCounts
From PortfolioProject..CovidDeaths
--Where location like '%nigeria%'
Where continent is not null
Group by continent
Order by 2 desc

--Globally

Select Date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(New_cases)*  100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Date
Order by 1

-- Exploring Total Population Vs People vaccinated


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
      SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
	  as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
    Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
      SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
	  as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
    Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaaccinated/population)*100 as PeopleVaccinatedPercent
From PopvsVac

--USE Temp table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
      SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
	  as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
    Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as PeopleVaccinatedPercent
From #PercentPopulationVaccinated

--Creating views to store data for later visualization

Create View RollingPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
      SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
	  as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
    Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From RollingPeopleVaccinated