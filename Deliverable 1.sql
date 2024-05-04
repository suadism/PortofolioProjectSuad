                               -- Air Traffic Deliverable#1--
                               
                               
--  The purpose of this report is to analyse flight and Airport data from Bureau of Transportation Statistics to assist
-- Brainstation fund managers to decide which ariline stocks to invest in.  -- 

-- Selecting AirTraffic Database --
use AirTraffic
-- The below series of questions will be answered using SQL queries in order to provide insights--

-- Question#1 (a)How many flights were there in 2018 and 2019 separately?-- 

-- Query for Flights in 2018--
select count(*) as Total_2018_Flights from flights
where year(FlightDate)= 2018 
-- Query for flights in 2019 --
select count(*) as Total_2019_Flights from flights
where year(FlightDate)= 2019


-- Question#1 (b)In total, how many flights were cancelled or departed late over both years?-- 
select count(*) as Cancelled_and_Late_Flights from flights
where DepDelay > 0 or  Cancelled=1

-- Question#1 (c)Show the number of flights that were cancelled broken down by the reason for cancellation-- 

select count(*) as TotalCancelledFlights,CancellationReason  from flights
where Cancelled=1
group by CancellationReason

-- Question#1 (d) For each month in 2019, report both the total number of flights and percentage of flights cancelled.Based on your results, what might you say about the cyclic nature of airline revenue?--  
-- finding out the total flights in 2019 broken down by month
with total_2019_flights as 
(select month(Flightdate) as month, count(id) as TotalFlights  from flights
where year(FlightDate)= 2019
group by month(Flightdate) ),
-- finding out the total cancelled flights in 2019 --
total_cancelled_flights as 
(select month(Flightdate)as month ,count(id) as TotalFlightsCancelled from flights
where Cancelled=1 and year(FlightDate)= 2019
group by month(Flightdate) )
-- combining the total flights and total cancelled flight tables and calculated percent flights cancelled--
select total_2019_flights.month, TotalFlightsCancelled,TotalFlights , round(TotalFlightsCancelled/TotalFlights*100, 2) as PercentFlightsCancelled  
from total_2019_flights join total_cancelled_flights on total_cancelled_flights.month=total_2019_flights.month
 -- As the months go by the number of flights cancelled decreases. The percentage of flights cancelled is highest in beginiing of the year and lowest by december. 
 -- Therefore revenue is highest in the holiday seasons--                         
                          
                          
-- Question#2 (a)  Create two new tables, one for each year (2018 and 2019) showing the total miles traveled and number of flights broken down by airline.-- 

-- 2a and 2b total flights and total miles in 2018 and 2019 broken down by Airline  then finding year over year percent change--
with flights_2018 as 
(select AirlineName, count(id) as total_flights_2018, sum(distance) as total_distance_2018 from flights 
where year(FlightDate)= 2018 and Cancelled=0
group by AirlineName),

flights_2019 as (
 select AirlineName, count(id) as total_flights_2019, sum(distance) as total_distance_2019 from flights 
where year(FlightDate)= 2019 and Cancelled=0
group by AirlineName)

select flights_2018.AirlineName, round((total_distance_2019-total_distance_2018)/total_distance_2018*100, 2) as percentdistancechange,
 round((total_flights_2019-total_flights_2018)/total_flights_2018*100, 2) as percenttotalflightchange from flights_2018 join flights_2019 on
flights_2018.AirlineName=flights_2019.AirlineName
-- Based on the results of above query Delta Airlines increased its flights and made more trips between 2018 and 2019 by the biggest margin among the three airlines whereas 
-- Southwest  decreased its total flights and the distance travelled between 2018 and 2019. therefore investing in Delta is recommended as their are showing growth which will translate to increased profits--

-- Question#3 (a) Names of the 10 most popular destination airports overall
-- Query that first joins flights and airports then does the necessary aggregation.

select count(airports.AirportID) as Numberofflights , airports.AirportName from flights join airports on 
flights.DestAirportID=airports.AirportID
group by airports.AirportName order by count(airports.AirportID) desc limit 10


-- Question#3 (b) Using a subquery to aggregate & limit the flight data before joining with the airport information, hence optimizing query runtime

select top10.DestAirportID , airports.AirportName, top10.numberofflights from (select DestAirportID , count(DestAirportID) as numberofflights from flights group by DestAirportID 
order by count(DestAirportID) desc limit 10) as top10
join airports on top10.DestAirportID=airports.AirportID

-- The subquery where aggregation and subquey was done first followed by join was the faster query since this query has a smaller dataset to do a join query. If we join first then since the flights table
-- is very large it takes time to join it with the airports table--


-- Question#4 (a)  --
-- Determining the number of unique aircraft each airline operated in total over 2018-2019
select AirlineName, count(distinct Tail_Number) as NumberofAircrafts from flights
group by AirlineName

-- Question#4 (b) --
-- Determining average distance traveled per aircraft for each of the three airlines -- 

select AirlineName, round(sum(Distance)/count(distinct Tail_Number)) as AVGdistance from flights where Cancelled=0
group by AirlineName

-- Determining total distance traveled for each of the three airlines -- 
select AirlineName, sum(Distance) as totaldistance from flights where Cancelled=0
group by AirlineName
-- Comment: Delta has lowest average distance traveled per aircraft so has lowest operating costs. It also has lowest distance travelled so fuel costs are lowest in Delta aircrafts. Therefore Delta
-- is the most cost effective airline as they have the lowest costs and show the highest growth in flights 

-- Question#5(a)--
-- Finding the average departure delay for each time-of-day across the whole data set
-- First we are seperating the dataset by time of day
SELECT round(avg(DepDelay)), CASE
    WHEN HOUR(CRSDepTime) BETWEEN 7 AND 11 THEN "1-morning"
    WHEN HOUR(CRSDepTime) BETWEEN 12 AND 16 THEN "2-afternoon"
    WHEN HOUR(CRSDepTime) BETWEEN 17 AND 21 THEN "3-evening"
    ELSE "4-night"
END AS "time_of_day"
-- Then selecting only delayed flights and then grouping them by time of day --
from (select id, Reporting_Airline, DepDelay, CRSDepTime, case when DepDelay >0 then 'late' else 'ontime' end as 'status' from flights  ) as only_delayed_flights
where status='late'
group by time_of_day
-- Comment: Delays are longer in the evening departing flights. On average a flight is delayed by about 36 mins in evening and lowest in morning where you can expect about a 26 min delay

 
-- Question 5(b)--
-- Finding the average departure delay for each airport and time-of-day combination -- 

SELECT AirportName, avg(DepDelay), CASE
    WHEN HOUR(CRSDepTime) BETWEEN 7 AND 11 THEN "1-morning"
    WHEN HOUR(CRSDepTime) BETWEEN 12 AND 16 THEN "2-afternoon"
    WHEN HOUR(CRSDepTime) BETWEEN 17 AND 21 THEN "3-evening"
    ELSE "4-night"
END AS "time_of_day"
from (select flights.id, airports.AirportName, flights.OriginAirportID, flights.DepDelay, flights.CRSDepTime, 
case when DepDelay <= 0 then 'ontime' else 'late' end as 'status' 
from flights join airports on airports.AirportID=flights.OriginAirportID) as only_delayed
where status='late'
group by AirportName, time_of_day

-- Question 5 (c)-- limiting  average departure delay to morning delays and airports with at least 10,000 flight

-- creating column to identify morning flights-- 

select Averagedelay ,AirportName, time_of_day from 
-- isolating average delays in airports with atleast 10000 flights-- 
(SELECT AirportName, avg(DepDelay) as Averagedelay, CASE
    WHEN HOUR(CRSDepTime) BETWEEN 7 AND 11 THEN "1-morning"
    ELSE "not_morning"
END AS "time_of_day"
-- identifying late flights--
from 
(select flights.id, mostused_airport.AirportName, flights.OriginAirportID, flights.DepDelay, flights.CRSDepTime, 
case when DepDelay <= 0 then 'ontime' else 'late' end as 'status' 
from flights join 
-- making a table of all airports with more than 10000 flights
 (select count(flights.id), airports.AirportName, airports.AirportID
from flights join airports on airports.AirportID=flights.OriginAirportID 
group by airports.AirportName, flights.OriginAirportID
HAVING count(flights.id) > 10000) as mostused_airport
-- joining flights table with table of airports with atleast 10000 flights--
 on mostused_airport.AirportID=flights.OriginAirportID) as only_delayed
 -- selecting only late flights --
where status='late' and DepDelay is not null
group by AirportName, time_of_day) as averagedelays_inmostpopular_airports
where time_of_day='1-morning'


-- Question#5(d) Finding out the top-10 airports and their respective cities with the highest average morning delay--

SELECT AirportName, round(avg(DepDelay)) as AverageDelay, City
from (select flights.id, airports.AirportName, flights.OriginAirportID, flights.DepDelay, flights.CRSDepTime, airports.City,
case when DepDelay > 0 then 'late' else 'ontime' end as 'status' 
from flights join airports on airports.AirportID=flights.OriginAirportID) as only_delayed
where status='late' and HOUR(CRSDepTime) IN (7,8,9,10,11)
group by AirportName, City
order by round(avg(DepDelay)) desc
 limit 10


