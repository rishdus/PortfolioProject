Select *
from PortfolioProject..CovidDeaths
order by 3,4

--Select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, Total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- shows likelihood if you contract covid in your country 
Select location, date, total_cases, Total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%india%'
order by 1,2

-- shows what percentage of population got infected
Select location, date, population, total_cases,  (total_cases/population)*100 AS InfectionPercentage
from PortfolioProject..CovidDeaths
--Where location like '%india%'
order by 1,2

-- looking at countries with highest infection rate	compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 AS InfectionPercentage
from PortfolioProject..CovidDeaths
--Where location like '%india%'
Group by  location, population
order by InfectionPercentage desc

--country wise death count
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--Where location like '%india%'
Where continent is not null
Group by  location
order by TotalDeathCount desc

-- continent wise death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--Where location like '%india%'
Where continent is not null
Group by  continent
order by TotalDeathCount desc

-- global numbers
Select date, SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

Select SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

-- looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vacciantions numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--CREATE VIEW TO STORE DATA FOR LATER VISUALISATION

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated