SELECT  continent, MAX(CAST (total_deaths AS INT)) as TotalDeathCount
FROM Coba..CovidKematian
WHERE continent is not null
GROUP BY continent 
order by TotalDeathCount desc

SELECT  location, COUNT(location) as negararal
FROM Coba..CovidKematian
GROUP BY location

--Loking at total cases vs total deaths
SELECT Location,date,total_deaths,total_cases, (total_deaths/total_cases)*100 AS DeathPerecentage 
FROM Coba..CovidKematian
WHERE location like '%Islands%'
ORDER BY 1,2

--looking at total cases vs population
--show what precentage of population got covid
SELECT Location,date,population,total_cases, (total_cases/population)*100 AS DeathPerecentage 
FROM Coba..CovidKematian
--WHERE location like '%states%'
ORDER BY 1,2
/*
--looking at Countries with highest infection compared to population 
SELECT Location,population,MAX (total_cases)as HighestInfectionCount, MAX((total_cases/population))*100 AS PerecentagePopulationInfected
FROM Coba..CovidKematian
GROUP BY location, population
ORDER BY PerecentagePopulationInfected desc
*/
--Menampilkan Benua 
SELECT location, MAX(CAST (total_deaths as int)) as TotalDeathCount
FROM Coba..CovidKematian
--WHERE continent like '%Oceania%'
WHERE continent is null
GROUP BY location
order by TotalDeathCount desc

--GLOBAL NUMBERS
SELECT date, SUM(new_cases)as TotalCases,SUM(CAST(new_deaths AS INT)) as TotalDeaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM Coba..CovidKematian
WHERE continent is not null
GROUP BY DATE 
--WHERE location like '%states%'
ORDER BY 1,2
/*
SELECT SUM(new_cases)as TotalCases,SUM(CAST(new_deaths AS INT)) as TotalDeaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM Coba..CovidKematian
WHERE continent is not null
--GROUP BY DATE 
--WHERE location like '%states%'
ORDER BY 1,2
*/
/* 
*/

-- Menghitung jumlah vaksinasi tiap harinya  
SELECT kem.continent, kem.location, kem.date,kem.population, vac.new_vaccinations,
SUM(vac.new_vaccinations)over ()
FROM Coba..CovidKematian kem
JOIN Coba..CovidVaksins vac
on kem.location=vac.location
and kem.date=vac.date
WHERE kem.continent is not null
and kem.location  like '%thai%' 
ORDER BY 1,2,3 

-- Menghitung jumlah vaksinasi tiap harinya  

SELECT kem.continent, kem.location, kem.date,kem.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations))over(Partition BY kem.Location ORDER BY kem.location, kem.Date) AS jumlahVaksiAday
FROM Coba..CovidKematian kem
JOIN Coba..CovidVaksins vac
on kem.location=vac.location
and kem.date=vac.date
WHERE kem.continent is not null
and kem.location  like '%THAI%' 
ORDER BY 1,2,3 

-- Menghitung jumlah vaksinasi tiap harinya dan presentase

--USE CTE
WITH PopvsVac (continent,location,date,population,new_vaccinations,JumlahVaksinasi)
AS
(
SELECT kem.continent, kem.location, kem.date,kem.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations))over(Partition BY kem.Location ORDER BY kem.location, kem.Date) AS JumlahVaksinasi
FROM Coba..CovidKematian kem
JOIN Coba..CovidVaksins vac
on kem.location=vac.location
and kem.date=vac.date
WHERE kem.continent is not null
and kem.location  like '%INDONE%' 
--ORDER BY 1,2,3 
)
SELECT *, (JumlahVaksinasi/population)*100 AS PresentaseHari
FROM PopvsVac


--TEMP Table 

DROP Table if exists #percentPopulationVaksin
Create Table #percentPopulationVaksin
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
VaksinUntilToday numeric
)

Insert into #percentPopulationVaksin
Select kem.continent, kem.location, kem.date, kem.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by kem.Location Order by kem.location, kem.Date) as VaksinUntilToday
--, (RollingPeopleVaccinated/population)*100
From Coba..CovidKematian kem
Join Coba..CovidVaksins vac
	On kem.location = vac.location
	and kem.date = vac.date
	and kem.location  like '%Indonesia%' 
--where kem.continent is not null 
--order by 2,3

Select *, (VaksinUntilToday/Population)*100 as PrecentageVaksin
From #percentPopulationVaksin



--Create View to store data For later visualization

Create View PercentPopulationVaksin as
Select kem.continent, kem.location, kem.date, kem.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by kem.Location Order by kem.location, kem.Date) as VaksinUntilToday
From Coba..CovidKematian kem
Join Coba..CovidVaksins vac
	On kem.location = vac.location
	and kem.date = vac.date
	and kem.location  like '%Indonesia%' 
where kem.continent is not null 
--order by 2,3

SELECT *
FROM PercentPopulationVaksin