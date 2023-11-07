SELECT *
FROM project_portfolio..CovidDeaths
ORDER by 3, 4

SELECT *
FROM project_portfolio..CovidVaccinations
ORDER by 3, 4

-- select data that we are going to be using
SELECT Location,date, total_cases, new_cases, total_deaths, population
FROM project_portfolio..CovidDeaths
ORDER by 1 , 2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country 
SELECT Location,date, total_cases,  total_deaths, (total_deaths/total_cases) *100 as Deathpercentage
FROM project_portfolio..CovidDeaths
WHERE location  LIKE '%kenya%'
ORDER by 1 , 2 

--looking at the totalcases vs population 
--shows what percentage of population has gotten covid 
SELECT Location,date, total_cases,  population, (total_cases/population) *100 as covidperpopulation
FROM project_portfolio..CovidDeaths
WHERE location  LIKE '%kenya%'
ORDER by 1 , 2 

--looking at countries with highest infection rate compared to population 
SELECT Location,population, MAX(total_cases) AS Highestinfection,   MAX((total_cases/population)) *100 as percentagepopulationinfected 
FROM project_portfolio..CovidDeaths
--WHERE location  LIKE '%kenya%'
GROUP BY location ,population
ORDER by percentagepopulationinfected DESC

--showing countries with highest death count per popluation 
SELECT Location,population, MAX(total_deaths) AS Highestdeath,   MAX((total_deaths/population)) *100 as percentagepopulationdead
FROM project_portfolio..CovidDeaths
WHERE continent IS not NULL  
GROUP BY location ,population
ORDER by percentagepopulationdead DESC

SELECT location, MAX(CAST(Total_deaths as int)) as Totaldeathcount FROM project_portfolio..CovidDeaths
WHERE continent IS not NULL
GROUP BY location 
ORDER BY Totaldeathcount DESC

--lets break things down by continent
SELECT location, MAX(CAST(Total_deaths as int)) as Totaldeathcount FROM project_portfolio..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY Totaldeathcount DESC

--GLOBAL NUMBERS
SELECT  SUM(new_cases) AS totalcases, SUM(CAST(new_deaths AS INT)) as totaldeaths ,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as Deathpercentage
FROM project_portfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER by 1 , 2 

--looking at the total population vs vaccinations
--use CTE
WITH popvsvac(continent,location,date,population,new_vaccinations,Rollingnewvaccinations)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) as Rollingnewvaccinations

FROM project_portfolio..CovidDeaths dea
JOIN project_portfolio..CovidVaccinations vac ON dea.location =vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL
)
SELECT *,(Rollingnewvaccinations/population)*100
FROM popvsvac

--TEMP TABLE 
DROP TABLE if EXISTS percentagepeoplevaccinated
CREATE TABLE percentagepeoplevaccinated
(
 continent NVARCHAR(255),
 location NVARCHAR(255),
 date DATETIME,
 population NUMERIC,
 new_vaccinations NUMERIC,
 Rollingpeoplevaccinated NUMERIC,
)
INSERT INTO percentagepeoplevaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) as Rollingpeoplevaccinated
FROM project_portfolio..CovidDeaths dea
JOIN project_portfolio..CovidVaccinations vac ON dea.location =vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL


SELECT *,(Rollingpeoplevaccinated/population)*100
FROM percentagepeoplevaccinated

--creating view to store data for later visualizations

CREATE VIEW  percentagepopulationvaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) as Rollingpeoplevaccinated
FROM project_portfolio..CovidDeaths dea
JOIN project_portfolio..CovidVaccinations vac ON dea.location =vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *
FROM percentagepopulationvaccinated