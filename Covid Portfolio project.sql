select * from CovidDeaths
where continent is not null
order by 3,4

--select * from CovidVaccination
--order by 3,4


--Data that we are using

select Location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2


---total cases vs total deaths
--calculating percentage of total death
--shows the likelihood of dying if you contract in your country
select Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from CovidDeaths
where location like '%india%'
and continent is not null
order by 1,2


---looking at total cases vs population
--shows what percentage of population got covid

select Location,date,population,total_cases, (total_cases/population)*100 AS percentofpopulationinfected
from CovidDeaths
--where location like '%india%'
where continent is not null
order by 1,2

--looking at countries with highest infection rate compared to population

select Location,population,max(total_cases) as highestinfectioncount, max(total_cases/population)*100 AS percentofpopulationinfected
from CovidDeaths
--where location like '%india%'
where continent is not null
group by location,population
order by highestinfectioncount desc

--shwing countries with highest death count per population


select Location,population,max(cast(total_deaths as int)) as totaldeathcount, max(total_deaths/population)*100 AS percentofpopulationdied
from CovidDeaths
--where location like '%india%'
where continent is not null
group by location,population
order by totaldeathcount desc

--lets break thing down by continent

---showing the continent with highest dathcount

select continent,max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by totaldeathcount desc


--Global Numbers

select  SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,
sum (cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from CovidDeaths
--where location like '%india%'
where continent is not null
--group by date
order by 1,2


--lokkig at total population vss vaccination  

 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 ,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated 
 from CovidDeaths dea
 join CovidVaccination vac 
 on dea.location=vac.location and dea.date= vac.date
 where dea.continent is not null
 order by 1,2,3

 --
----select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
-- ,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated 
-- ,(rollingpeoplevaccinated/population)*100from CovidDeaths dea
-- join CovidVaccination vac 
-- on dea.location=vac.location and dea.date= vac.date
-- where dea.continent is not null
-- order by 1,2,3
!
!
v

 --use CTE HERE WE ARE USING CTE for above querry because as when we try to do rollingpeoplevaccinatin by population for percentage
 --it will show an error..bcz of that we are using this we can also use TEMP 

 --USE CTE

 WITH popvsvac (continent,location,date,population,new_vaccinations ,rollingpeoplevaccinated) 
 as 
 (
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 ,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated 
 from CovidDeaths dea
 join CovidVaccination vac 
 on dea.location=vac.location and dea.date= vac.date
 where dea.continent is not null
 )
 select *,(rollingpeoplevaccinated/population )*100 as percentagerollingpeoplevaccinated
 from popvsvac


--Temp table for same content
--Use: "drop table if exists" if you want to do any altration

create table #percentpopulationvaccinated
(
continent nvarchar(255),location nvarchar(255),date datetime,
population numeric,new_vaccinations numeric,rollingpeoplevaccinated numeric)

insert into #percentpopulationvaccinated
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 ,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated 
 from CovidDeaths dea
 join CovidVaccination vac 
 on dea.location=vac.location and dea.date= vac.date
 where dea.continent is not null
 
 select *,(rollingpeoplevaccinated/population )*100 as percentagerollingpeoplevaccinated
 from #percentpopulationvaccinated


 --creating view to store data for later visulalization

 create view percentpopulationvaccinated as 
  select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 ,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated 
 from CovidDeaths dea
 join CovidVaccination vac 
 on dea.location=vac.location and dea.date= vac.date
 where dea.continent is not null

 select * from percentpopulationvaccinated