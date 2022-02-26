USE [Portfolio Project]
GO

----Total cases vs Total Deaths
select Location, 
		date,
		total_cases,
		total_deaths,
		((total_deaths/total_cases) *100) as DeathPopulation
From dbo.COVIDDEATHS
Where location IN ('Nigeria', 'United States')
order by location, date 
GO

---Replacing NULL with 'unknown' on total_death 
select Location, 
		date,
		total_cases,
		((total_deaths/total_cases) *100) as DeathPopulation,
CASE
	WHEN total_deaths is null THEN 'Unknown'
	else total_deaths
    END AS total_deaths
From dbo.COVIDDEATHS
Where location IN ('Nigeria', 'United States')
order by location, date 
GO


--Total cases vs Population
select Location,
		date,
		total_cases, 
		population,
		((total_cases/population) *100) as DeathPercent
from dbo.COVIDDEATHS
order by location,date
GO

---countries with highest total cases 
select Location,
		max(total_cases) as MaxCases, 
		population
from dbo.COVIDDEATHS
where continent is not null
group by location,population
order by MaxCases desc
GO

---Country with highest death count 

select Location,
		max(cast(total_deaths as int)) as MaxDeath,
		population
from dbo.COVIDDEATHS
where continent is not null
group by location,population
order by MaxDeath desc
GO
----total death count by continent
select continent ,
		max(cast(total_deaths as int)) as TotalDeathCount
from dbo.COVIDDEATHS
where continent is not null
group by continent
order by continent desc
GO

---Sum of Data across the world with new cases and new death
SELECT date, 
		sum(new_cases) as SumOfNewCases, 
		sum(cast(new_deaths as int)) as SumOfNewDeath,
		sum(cast(new_deaths as int))/sum(new_cases)*100 as PercentNewcaseNewDeath
FROM dbo.COVIDDEATHS
---where continent IS not null
group by date
GO

---sum of new cases vs new death
SELECT sum(new_cases) as SumOfNewCases,
		sum(cast(new_deaths as int)) as SumOfNewDeaths,
		sum(convert(int,new_deaths))/sum(new_cases)*100 as PercentNewcaseNewDeath
from dbo.COVIDDEATHS
where continent is not null
GO
 
----USE CTE
WITH DeathsVsVacc (Continent, Location, Date, Population, New_Vaccinations,
SumOfNewlyVaccinated)
as
(
SELECT cvd.continent,
		cvd.location,
		cvd.date,
		cvd.population, 
		cvc.new_vaccinations,
(convert(int,cvc.new_vaccinations)/cvd.population)*100 as SumOfNewlyVaccinated
FROM dbo.COVIDDEATHS cvd
join dbo.covidvacc cvc
	on cvd.location = cvc.location
	and cvd.date = cvc.date
where cvd.continent is not null
group by cvd.continent, 
		cvd.location, 
		cvd.date,
		cvd.population,
		cvc.new_vaccinations
)
select * 
from DeathsVsVacc
GO

----creating a view for temporary storage.
CREATE VIEW PercentNewlyVaccinated
AS
(
SELECT cvd.continent,
		cvd.location,
		cvd.date,
		cvd.population,
		cvc.new_vaccinations,
		(convert(int,cvc.new_vaccinations)/cvd.population)*100 as SumOfNewlyVaccinated
FROM dbo.COVIDDEATHS cvd
join dbo.covidvacc cvc
	on cvd.location = cvc.location
	and cvd.date = cvc.date
where cvd.continent is not null
group by cvd.continent, cvd.location, cvd.date, cvd.population, cvc.new_vaccinations
)
GO

select * 
from PercentNewlyVaccinated
