
-- Reviewing Both Tables 

select * 
from CovidProject..CovidDeaths$
select *
from CovidProject..CovidVaccinations$ 

-- Selecting Data that is going to be Used 

SELECT location,population,date, total_cases, new_cases, total_deaths
from CovidDeaths$
order by 1,2

--Percentage of people that have died due to Covid (Total Cases Vs Total Deaths)
--Percentage of people who lost thier lives due to Cvoid in Kuwait 

SELECT location,date, total_cases, total_deaths, (total_cases/total_deaths)*100 as DeathPercentage 
from CovidDeaths$
Where total_deaths is not null AND location = 'kuwait'
order by 1,2

--Percentage of Population that was infected
--Total Cases Vs Population 

SELECT location,date, total_cases, population, (total_cases/population)*100 as Infected
from CovidDeaths$
Where total_deaths is not null AND location = 'Kuwait'
order by 1,2

--Countries with the Highest Infection Rate compared to thier population 
--Comparison with Date

Select Location, Population,date, MAX (total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
Group by Location, Population, date
order by 1,2,PercentPopulationInfected desc

--comparison without the Date

SELECT location,population, MAX(total_cases) as HighestInfectioncount, max ((total_cases/population))*100 as PercentageofInfected
from CovidDeaths$
Group by Location, population
order by PercentageofInfected desc

--Countries with the Highest Death Rate Compared to thier Population

  SELECT location,population, MAX(total_deaths) as highestdeathcount, MAX((total_deaths/population))*100 AS deathperpopulationcount
  from CovidDeaths$
  where continent is not null 
  group by  location, population 
  order by deathperpopulationcount desc

--Breaking things down by Continents 

-- continents with the highest death rate according to thier population

  SELECT continent, MAX(total_deaths) as highestdeathcount
  from CovidDeaths$
  where continent is not null 
  group by  continent 
  order by highestdeathcount desc


--Global Number of total new cases n deaths (according to countries)

SELECT date, SUM(new_cases) as Sum_of_New_Cases, SUM(new_deaths) as Sum_of_New_Deaths, SUM(total_cases)/SUM(total_deaths)*100 as NewDeath_NewCasePercentage 
from CovidDeaths$
where continent is not null
group by date
order by 1,2


-- (European Union is part of Europe so we wont be including that in this calculation) 
-- Looking at the total Number of Deaths

Select location, SUM(new_deaths) as TotalDeathCount
From CovidDeaths$
Where continent is null 
and location not in ('World', 'European Union')
and location not like '%income'
Group by location
order by TotalDeathCount desc


-- Total Number of New Cases and New Deaths 

SELECT SUM(new_cases) as Sum_of_New_Cases, SUM(new_deaths) as Sum_of_New_Deaths, SUM(total_cases)/SUM(total_deaths)*100 as NewDeath_NewCasePercentage 
from CovidDeaths$
where continent is not null
order by 1,2


--Joining CovidVaccinations$ and CovidDeaths$ 

--Looking at the Total Number of People that have recived the vaccination

SELECT dea.continent, Dea.location, Dea.date,dea.population, vac.total_vaccinations
FROM CovidVaccinations$ vac
join CovidDeaths$ Dea
on vac.date = Dea.date
and vac.location = Dea.location
where dea.continent is not null and vac.total_vaccinations is not null 
order by 2,3

-- Total Population VS Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as Peoplevaccinated
--, (Peoplevaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and new_vaccinations is not null
order by 2,3

-- Creating a CTE to perform Calculation on (Partition By) for the above query 


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
and new_vaccinations is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as percentage_of_People_vaccinated
From PopvsVac


-- Creating a Temp Table 

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
, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
and new_vaccinations is not null
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as percentage_of_People_vaccinated
From #PercentPopulationVaccinated


-- Creating Views to store data for later visualizations using Tableau

Create View Total_Death_count_Per_Continent as
Select location,Date, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths$
Where continent is null 
and location not in ('World', 'European Union', 'International')
and location not like '%income%'
Group by location,Date
--order by TotalDeathCount desc

Create View New_Vaccination_Distribution as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
and new_vaccinations is not null 

create view Continents_with_the_Highest_Death_Rate as
  SELECT continent, MAX(total_deaths) as highestdeathcount
  from CovidDeaths$
  where continent is not null 
  group by  continent 
  --order by highestdeathcount desc

 create view Percentage_of_Population_Infected as
 SELECT location,population, MAX(total_cases) as HighestInfectioncount, max ((total_cases/population))*100 as PercentageofInfected
from CovidDeaths$
Group by Location, Population
--order by PercentageofInfected desc

Create view Total_Death_Percentage as 
SELECT date, SUM(new_cases) as Sum_of_New_Cases, SUM(new_deaths) as Sum_of_New_Deaths, SUM(total_cases)/SUM(total_deaths)*100 as NewDeath_NewCasePercentage 
from CovidDeaths$
where continent is not null
group by date
--order by 1,2

create view Total_vaccination_distribution as 
SELECT dea.continent, Dea.location, Dea.date,dea.population, vac.total_vaccinations
FROM CovidVaccinations$ vac
join CovidDeaths$ Dea
on vac.date = Dea.date
and vac.location = Dea.location
where dea.continent is not null and vac.total_vaccinations is not null 
--order by 2,3