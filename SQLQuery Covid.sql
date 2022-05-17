
Select * 
From PortfolioProjects..CovidDeaths
order by 3,4

Select * 
From PortfolioProjects..CovidVaccinations
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..CovidDeaths
order by 1,2


-- Total cases vs Total Deaths in the Netherlands

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
Where location like 'Netherlands' 
order by 1,2


-- Total Cases vs Population in the Netherlands

Select Location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
From PortfolioProjects..CovidDeaths
Where location like 'Netherlands' 
order by 1,2


-- Infection Rate relative to Population

Select Location, population, MAX(total_cases) as MostInfectionCases, MAX((total_cases/population))*100 as PopulationInfected
From PortfolioProjects..CovidDeaths 
Group by location, population
order by PopulationInfected desc

-- Deaths relative to Population

Select Location, population, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX((total_deaths/population))*100 as PopulationDeaths
From PortfolioProjects..CovidDeaths
Where continent is not null
Group by location, population
order by TotalDeathCount desc

-- Deaths per Continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
Where continent is null
Group by  location
order by TotalDeathCount desc

Select  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
where continent is not null
Group by date
order by 1,2


-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2, 3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated 
From PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table

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
, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated 
From PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Create View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null