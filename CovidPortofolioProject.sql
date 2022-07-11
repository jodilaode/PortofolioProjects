select * 
from PortofolioProject..CovidDeaths
order by 3,4

--select *
--from PortofolioProject..CovidVaccinations
--order by 3,4

-- # Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject..CovidDeaths
order by 1,2

-- # Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathsPercentage
from PortofolioProject..CovidDeaths
where location like '%afg%'
order by 1,2

-- (Line 29)  Sehingga bisa diketahui, dari total_cases = 40  dengan total_deaths = 1,
-- memberi kita tingkat kematian sebanyak 2,5%
-- Dan sampai tanggal 05-07-2022 di Afghanistan, total kasus sebanyak 182793 dengan
-- total kematian 7725, sehingga peluang untuk mati di Afghanistan sebanyak 4,2%

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathsPercentage
from PortofolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Puncak kasus di US terjadi pada mei hingga juni 2020 dengan peluang kematian sebanyak 5-6%.
--Pada akhir tahun 2020, total kasus mencapai 20191301 dan total mati 351039 dan peluang kematian menurun mencapai 1,7%


-- # Looking at Total Cases vs Population
-- # Show what percentage of population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 PercentPopulationInfected
from PortofolioProject..CovidDeaths
where location like '%indo%'
order by 1,2

--Pada akhir tahun 2021, kasus Covid di Indonesia 4262720 kasus dengan persentase peluang kematian mencapai 1,5% dari total populasi. Sedangkan
--Pada bulan Juni sampai awal Juli, kasus Covid mencapai 6097928 dengan peluang kematian mencapai 2,2% dari total populasi

-- # Looking at countries with highest infection rate compared to populations

Select location, population, Max(total_cases) HighestInfectionCount, Max((total_cases/population))*100 PercentPopulationInfected
from PortofolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

-- Disini kita bisa melihat jumlah populasi yang dimiliki sebuah negara terinfeksi Covid

-- # Showing countries with highest deaths count per population

Select location, Max(cast(total_deaths as int)) TotalDeathCount
From PortofolioProject..CovidDeaths
Where continent is not Null
Group by location
Order by TotalDeathCount desc


-- # LET'S BREAK THINGS DOWN BY CONTINENT
-- # Showing continents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) TotalDeathCount
From PortofolioProject..CovidDeaths
Where continent is not Null
Group by continent
Order by TotalDeathCount desc


-- # Jumlah kasus dan kematian baru

Select SUM(new_cases) Total_Cases,  SUM(cast(new_deaths as int)) Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 Death_Percentage
From PortofolioProject..CovidDeaths
Where continent is not null
-- Group by 
Order by 1,2

-- Jadi secara keseluruhan, total kasus baru dan kematian baru memiliki persentase kematian sedikit diatas 1%


-- # Showing table death and vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Date) as RollingPeopleVaccinated
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Pada Negara Albania, vaksinasi dimulai pada pertengahan januari 2021, dan data tersebut terus bertambah

-- Use CTE
with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac
order by 2,3

-- Dari query diatas, bisa diketahui persentase vaksinasi setiap harinya dari total populasi. Contohnya yaitu pada negara Albania,
-- sampai tanggal 05 Juli 2022, jumlah vaksinasi mencapai 1417691 dari total populasi 2872934, dan persentase yang telah vaksinasi di Albania
-- mencapai 49,3%



-- # TEMP TABLE $EROR$
Drop Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--Where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From PercentPopulationVaccinated


-- # Creating view to store data for later visualizations

create view PercentPopulationVaccinateddd as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinateddd