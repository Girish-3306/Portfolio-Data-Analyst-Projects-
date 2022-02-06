
Select *
from PortfolioProject..CovidDeaths
where continent is not Null
order by 3,4;

--Select *
--from PortfolioProject..CovidVaccinations
--order by 3,4;

--Select the data that we are going to be using 
Select Location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
where continent is not Null
order by 1,2;


--Looking at Total cases vs Total Deaths
--Show likelihood of dying if you contract covid in your coutry
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not Null
order by 1,2;

-- Looking at Total cases vs Population
-- Shows what percentage of population got Covid
Select Location, date,population, total_cases, (total_cases/population)*100  as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100  as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
--and continent is not Null
Group by Location, Population 
order by PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not Null
Group by Location
order by TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT	

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not Null
Group by continent
order by TotalDeathCount DESC


Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is Null
Group by location
order by TotalDeathCount DESC


--Showing continents with highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not Null
Group by continent
order by TotalDeathCount DESC


--GLOBAL NUMBERS

Select  date, sum(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases )*100 as DeathPercentage --total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage 
From PortfolioProject..CovidDeaths
--where location like '%states%'
WHERE continent is not Null
--GROUP BY date 
order by 1,2;

Select sum(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases )*100 as DeathPercentage --total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage 
From PortfolioProject..CovidDeaths
--where location like '%states%'
WHERE continent is not Null
--GROUP BY date 
order by 1,2;



--Looking at Total population Vs Vaccinations 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null   
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 from PopvsVac
 


 --Temp Table

DROP Table if exists #PrecntPopulationVaccinated
Create Table #PrecntPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingpeopleVaccinated numeric,
)

Insert into #PrecntPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100 from #PrecntPopulationVaccinated


--Creating view to store data for later visualization 
Create View PercentpopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3


Select * from PercentpopulationVaccinated

