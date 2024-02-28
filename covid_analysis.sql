SELECT *
from portfolio_project.dbo.CovidDeaths
where continent is not null
ORDER by 3,4


--SELECT *
--from portfolio_project.dbo.CovidVaccinations
--ORDER by 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
from  portfolio_project.dbo.CovidDeaths
order by 1 ,2 

--total deaths vs total cases
--shows the likehood of dying if you get incontact with covid
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_per 
from  portfolio_project.dbo.CovidDeaths
where location LIKE '%India%'
order by 1,date ASC

--total cases vs total population
--shows percentage of population got covid
SELECT location,date,total_cases,population,(total_cases/population)*100 as population_per
from  portfolio_project.dbo.CovidDeaths
where location LIKE '%India%'
order by 1,date ASC

--country with max infection
SELECT location , max(total_cases) as max_in_country,population,max((total_cases/population))*100 as max_pop_per
from  portfolio_project.dbo.CovidDeaths
--where location LIKE '%India%
Group by Location,population
order by max_pop_per desc

--showing countries with highest death per population
SELECT location , max(total_deaths) as death_per_population
from  portfolio_project.dbo.CovidDeaths
--where location LIKE '%India%
where continent is not null
Group by Location 
order by death_per_population desc

--SORTING BY CONTINENTS

SELECT continent , max(total_deaths) as death_per_population
from  portfolio_project.dbo.CovidDeaths
--where location LIKE '%India%
where continent is not null
Group by continent 
order by death_per_population desc

--SORTING BY CONTINENTS

SELECT location , max(total_deaths) as total_death_count
from  portfolio_project.dbo.CovidDeaths
--where location LIKE '%India%
where continent is  null
Group by Location 
order by total_death_count desc


--death percentage globally everyday
SELECT date,sum(new_cases) as total_cases,sum(new_deaths) as total_deaths,(sum(new_deaths)/sum(new_cases))*100 as death_per_globally
from  portfolio_project.dbo.CovidDeaths
where continent is not null
GROUP by date
order by 1,2

--total death percentage overall world
SELECT sum(new_cases) as total_cases,sum(new_deaths) as total_deaths,(sum(new_deaths)/sum(new_cases))*100 as death_per_globally
from  portfolio_project.dbo.CovidDeaths
where continent is not null
--GROUP by date
order by 1,2


SELECT *
from portfolio_project.dbo.CovidVaccinations
where continent is not null
ORDER by 3,4

--JOINING TWO TABLES
SELECT *
from portfolio_project.dbo.CovidDeaths dea
    JOIN portfolio_project.dbo.CovidVaccinations vac
        on dea.location = vac.location AND
            dea.date = vac.date
    
--showing new vaccinations
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from portfolio_project.dbo.CovidDeaths dea
    JOIN portfolio_project.dbo.CovidVaccinations vac
        on dea.location = vac.location AND
            dea.date = vac.date
WHERE dea.continent is not null
ORDER by 2,3 

--population vs vaccine
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(CAST(vac.new_vaccinations as int)) 
OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from portfolio_project.dbo.CovidDeaths dea
    JOIN portfolio_project.dbo.CovidVaccinations vac
        on dea.location = vac.location AND
            dea.date = vac.date
WHERE dea.continent is not null
ORDER by 2,3 

--use cte

with popvsvac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) as 
(
    SELECT dea.continent,dea.location,dea.date,CAST(population as float),vac.new_vaccinations,
sum(CAST(vac.new_vaccinations as int)) 
OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from portfolio_project.dbo.CovidDeaths dea
    JOIN portfolio_project.dbo.CovidVaccinations vac
        on dea.location = vac.location AND
            dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3 
)
SELECT * , (RollingPeopleVaccinated/population) * 100 as PopVsVaccPer
from popvsvac
ORDER by [location]

--temp table

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
 SELECT dea.continent,dea.location,dea.date,CAST(population as float),vac.new_vaccinations,
sum(CAST(vac.new_vaccinations as int)) 
OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from portfolio_project.dbo.CovidDeaths dea
    JOIN portfolio_project.dbo.CovidVaccinations vac
        on dea.location = vac.location AND
            dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3 

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--create view
Create View PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(CAST(vac.new_vaccinations as int)) 
OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from portfolio_project.dbo.CovidDeaths dea
    JOIN portfolio_project.dbo.CovidVaccinations vac
        on dea.location = vac.location AND
            dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated