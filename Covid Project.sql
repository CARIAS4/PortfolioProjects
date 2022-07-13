Select *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Order by 3,4

--Select *
--FROM PortfolioProject..CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using

Select Location, date,total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Order by 1,2


--Looking at Total Cases vs Total Deaths


Select Location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
and continent is not null
Order by 1,2



--Looking at Total Case vs Population 
--Shows what percentage of population got Covid

Select Location, date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%' 
Order by 1,2



--Looking at Countries with Highest infection rate compared to Population

Select Location,population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%' 
Group by Location, population
Order by PercentPopulationInfected desc

--Showing Countires with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%' 
WHERE continent is not null
Group by Location
Order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT


--Showing continents with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%' 
WHERE continent is null
Group by location
Order by TotalDeathCount desc

--GLOBAL NUMBERS

Select date,SUM (new_cases) as total_cases, SUM (cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM (NEW_cases) *100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
where continent is not null
Group By date
Order by 1,2



--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinaed/population) *100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
Order by 2,3

--CTE

With PopvsVac (Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinaed/population) *100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location Nvarchar (255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinaed/population) *100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date= vac.date
--where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




--Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinaed/population) *100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated