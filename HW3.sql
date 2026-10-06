-- CSC 151: HW #2
create database powerplants; -- creating database
use powerplants; -- selecting database to use
set SQL_SAFE_UPDATES=0;
set FOREIGN_KEY_CHECKS=0;

-- 6 tables created as csv files via Google Sheets and uploaded to the database
-- using Import Wizard

-- countries: countrycode (PK)
-- operators: operatorid (PK), headquarterscountry (FK)
-- fuel_types: fuelid (PK)
-- power_plants: plantid (PK), countrycode (FK), operatorid (FK), fuelid (FK)
-- generation_records: Composite Key-- plantid (FK/PK) & year (PK)
-- emission_records: Composite Key-- plantid (FK/PK) & year (PK)

-- 1. Retrieve the plant name, country name, operator name, fuel category, fuel name, 
-- capacity (in MW), and commission year for all power plants without using table aliases. 
-- Sort the results in descending order by capacity.
select power_plants.PlantName, countries.CountryName, operators.OperatorName,
fuel_types.FuelCategory, fuel_types.FuelName, power_plants.CapacityMW,
power_plants.CommissionYear
from power_plants natural join countries
				natural join operators
                natural join fuel_types
order by power_plants.CapacityMW desc;

-- 2. Retrieve the plant name, country code, calendar year, and annual generation (in GWh)
-- for all power plants for the year 2024 without using table aliases. Sort the results in 
-- descending order by generation.
select power_plants.PlantName, power_plants.CountryCode,
generation_records.year, generation_records.generationgwh
from power_plants natural join generation_records
where generation_records.year = 2024
order by generation_records.generationgwh desc;

-- 3. Retrieve the plant name, country code, calendar year, annual generation (in GWh), 
-- and CO2 emissions (in tonnes) for all power plants for the year 2024 without using table aliases. 
-- Sort the results in ascending order by CO2 emissions.
select power_plants.PlantName, power_plants.CountryCode,
generation_records.year, generation_records.generationgwh,
emission_metrics.co2emissionstonnes
from power_plants natural join generation_records
				natural join emission_metrics
where generation_records.year = 2024
order by emission_metrics.co2emissionstonnes asc;

-- 4. Write a SQL query using a Common Table Expression (CTE) to calculate the total cumulative power
-- generation (in GWh) for each operator across all available years without using table aliases. 
-- Retrieve the operator name, headquarters country, and their total generated power, and sort the results
-- in descending order by total generation.
with cumul_power_gen as(
	select power_plants.OperatorID, sum(generationgwh) as cpg
    from power_plants natural join generation_records
    group by power_plants.OperatorID)
    
select operators.OperatorName, operators.HeadquartersCountry,
cumul_power_gen.cpg
from operators natural join cumul_power_gen
order by cumul_power_gen.cpg desc;

-- 5. Write a SQL query using two separate Common Table Expressions (CTEs)--one to calculate total power
-- generation by country code and another to calculate total CO2 emissions by country code without using table aliases. 
-- Then, join these CTEs with the countries table to display the country name, total generation (in GWh), 
-- and total CO2 emissions (in tonnes). Sort the results in descending order by total generation.
with country_total_power as(
	select sum(generation_records.generationgwh) as country_tpg,
    power_plants.CountryCode
    from generation_records natural join power_plants
    group by power_plants.CountryCode),
    
country_total_emission as(
	select sum(emission_metrics.co2emissionstonnes) as country_tce,
    power_plants.CountryCode
    from emission_metrics natural join power_plants
    group by power_plants.CountryCode)
    
select countries.CountryName, country_total_power.country_tpg,
country_total_emission.country_tce
from countries natural join country_total_power
			natural join country_total_emission
order by country_total_power.country_tpg desc;