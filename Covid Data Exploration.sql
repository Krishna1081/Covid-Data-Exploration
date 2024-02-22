-- select * from PortfolioProject..CovidDeaths order by 3,4;
-- select * from PortfolioProject..CovidVaccinations order by 3,4;

-- Select Data that we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths order by 1,2;	

-- Select Data Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract the disease

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2;

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got Covid

Select Location, date, Population, total_cases,(total_cases/population)*100 as PercentPopulationInfected 
from PortfolioProject..CovidDeaths
-- where location like '%states%'
order by 1,2;


-- Looking at countries with the highest infection rate compared to population
Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population) * 100) 
as PercentPopulationInfected 
from PortfolioProject..CovidDeaths
group by Location, Population
order by PercentPopulationInfected desc;

-- Total Death Count per population excluding continents 
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
Where continent is not null	
group by Location
order by TotalDeathCount desc;

-- Breaking things down by continent 
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
Where continent is not null	
group by continent
order by TotalDeathCount desc;


-- Select Location, Max(cast(total_deaths as int)) as TotalDeathCount 
-- from PortfolioProject..CovidDeaths
-- Where continent is null	
-- group by Location
-- order by TotalDeathCount desc;

-- Global Numbers
Select SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) AS total_deaths, (SUM(cast(new_deaths as int)) /SUM(new_cases)) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
-- Group by date 
order by 1,2; 


--Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
order by 1,2,3;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 