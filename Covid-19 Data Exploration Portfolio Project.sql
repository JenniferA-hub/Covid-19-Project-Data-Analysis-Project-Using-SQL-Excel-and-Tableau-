Select *
From [Portfolio Project]..['COVID DEATHS$']
where continent is not null 
order by 3,4



Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..['COVID DEATHS$']
where continent is not null
order by 1,2

--I'm now looking at the total cases vs total deaths
--shows ilkelihood of dying if someone contracted covid 19 in South Africa

Select location, date ,total_cases,total_deaths,(total_deaths /total_cases)*100 as Covid_deathpercentage
from [Portfolio Project].. ['COVID DEATHS$']
Where location like '%South Africa%'
order by 1,2 


--Looking at the total cases versus the population
--shows what percentage of SA has covid

Select location, date , total_cases, population, (total_cases/population)*100 as confirmed_cases_percentage
from [Portfolio Project]..['COVID DEATHS$']
Where location like '%South Africa%'
and continent is not null
Order by 1,2 

--looking at which countries have the highest infection rates vs population


Select location, population,max(total_cases) as highest_infection_count ,max(total_cases/population)*100 as percentage_population_infected
From [Portfolio Project]..['COVID DEATHS$']
where continent is not null
group by location, population
order by percentage_population_infected desc

Select location,DATE, population,max(total_cases) as highest_infection_count ,max(total_cases/population)*100 as percentage_population_infected
From [Portfolio Project]..['COVID DEATHS$']
where continent is not null
group by location, population, DATE
order by percentage_population_infected desc



--Countries with highest death count per population

select location  ,max(cast(total_deaths as int)) as total_deathcount
from [Portfolio Project]..['COVID DEATHS$']
where continent is not null
group by location
order by total_deathcount desc
--doesn't carry on query resuLts onto next query,so we need to say this in each query


--Showing continents with highest death count

Select continent, max(cast(total_deaths as int)) as total_deathcount
from [Portfolio Project]..['COVID DEATHS$']
Where continent is not null
group by continent
order by total_deathcount desc


Select location, sum(cast(new_deaths as int)) as totaldeathcount
from [Portfolio Project]..['COVID DEATHS$']
where continent is null
and location not in ('World', 'European Union','High income','lower middle income','Low income' ,'Upper middle income', 'International')
group by location



--Global Numbers
-- The total number of deaths vs the total number of global cases
Select date,sum(new_cases) as total_cases, sum(cast(new_deaths as int))  as total_deaths
from  [Portfolio Project]..['COVID DEATHS$']
group by date
order by 1,2 desc



--Global death percentage

Select date,sum(new_cases) as total_cases, sum(cast(new_deaths as int))  as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as globaldeath_percentage
from  [Portfolio Project]..['COVID DEATHS$']
where continent is not null
group by date
order by 1,2 desc


--Total Vaccinations vs Total Populations

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(bigint ,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from [Portfolio Project]..['COVID DEATHS$'] dea
join [Portfolio Project]..['COVID VACCINATIONS$'] vac
  on dea.location = vac.location
  and dea.date= vac.date
  where dea.continent is not null
  order by 2,3

  --Creating a CTE/ With Clause so we can obtain total vaccinated people over total population

  With PopulationVsVaccination (Continent, Location, Date, Population,new_vaccinations, rolling_people_vaccinated)
  as
  (
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(bigint ,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from [Portfolio Project]..['COVID DEATHS$'] dea
join [Portfolio Project]..['COVID VACCINATIONS$'] vac
  on dea.location = vac.location
  and dea.date= vac.date
  where dea.continent is not null
  )
Select *, (rolling_people_vaccinated/Population)*100 AS rollingpeople_vaccination_vs_population_percentage
From PopulationVsVaccination

--Creating a view for visualizations

Create view PercentagePeopleVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(bigint ,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from [Portfolio Project]..['COVID DEATHS$'] dea
join [Portfolio Project]..['COVID VACCINATIONS$'] vac
  on dea.location = vac.location
  and dea.date= vac.date
  where dea.continent is not null



  Select *
  from PercentagePeopleVaccinated
