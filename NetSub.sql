---------------------------------------------------------------------
-- Comparing the Total Revenue, Revenue Growth, Total Number of Subscriptions, Subscription Growth, and Retention Rate from 2018 to 2019
--------------------------------------------------------------------------
with cte1 AS(
	SELECT 
		r.Year, r.Quarter, r.YearQuarter,
		SUM(r.Revenue) AS Revenue, 
		SUM(r.Revenue) - LAG(SUM(r.Revenue),1) OVER(PARTITION BY r.Quarter ORDER BY r.Year) AS RevGained,
		SUM(s.Subscribers) AS Subscribers,
		SUM(s.Subscribers) - (SUM(s.Subscribers) - LAG(SUM(s.Subscribers),1) OVER(PARTITION BY r.Quarter ORDER BY r.Year)) AS SubInitial,
		SUM(s.Subscribers) - LAG(SUM(s.Subscribers),1) OVER(PARTITION BY r.Quarter ORDER BY r.Year) AS SubGained
	FROM NetSub..Revenue r 
		INNER JOIN NetSub..Subscriber s
			ON r.Area = s.Area
			AND r.Quarter = s.Quarter
			AND r.Year = s.Year
			AND r.YearQuarter = s.YearQuarter
	WHERE (r.YearQuarter = '2018 Q4' OR r.YearQuarter = '2019 Q4')
	GROUP BY r.Year, r.Quarter, r.YearQuarter
	)
SELECT
	Year, Quarter, YearQuarter, Revenue, RevGained,
	ROUND((RevGained/Revenue),4) AS RevPGrowth,
	Subscribers, SubInitial, SubGained,
	ROUND((SubGained/Subscribers),4) AS SubGrowth,
	ROUND((Subscribers/SubInitial),4) AS RetentionRate
FROM cte1;


------------------------------------------------
-- Analyzing the Trend in Revenue and Subscribers by Region each Quarter from 2018 to 2019
------------------------------------------------
WITH cte2 AS (
	SELECT
		r.Area, r.YearQuarter, r.Revenue, 
		(LAG(r.Revenue, 1) OVER(PARTITION BY r.Area ORDER BY r.Year, r.Quarter)) AS RevInitial,
		r.Revenue - LAG(r.Revenue,1) OVER(PARTITION BY r.Area ORDER BY r.Year) AS RevAcquired,
		s.Subscribers,
		(LAG(s.Subscribers, 1) OVER(PARTITION BY r.Area ORDER BY r.Year, r.Quarter)) AS SubInitial,
		s.Subscribers - LAG(s.Subscribers,1) OVER(PARTITION BY r.Area ORDER BY r.Year) AS SubAcquired
	FROM NetSub..Revenue r 
		INNER JOIN NetSub..Subscriber s
			ON r.Area = s.Area
			AND r.Quarter = s.Quarter
			AND r.Year = s.Year
			AND r.YearQuarter = s.YearQuarter
	WHERE r.Year = 2018
		OR r.Year = 2019
	GROUP BY r.Area, r.Year, r.Quarter, r.Revenue, s.Subscribers, r.YearQuarter
)
SELECT
	Area, YearQuarter, Revenue, RevInitial, RevAcquired,
	ROUND((RevAcquired/RevInitial),4) AS RevGrowth,
	Subscribers, SubInitial, SubAcquired,
	ROUND((SubAcquired/SubInitial),4) AS SubGrowth,
	ROUND((Subscribers/SubInitial),4) AS RetentionRate
FROM cte2;

------------------------------------------------
-- YOY analysis comparing the Revenue and Subscribers by Region from 2018 to 2019
------------------------------------------------
with cte3 AS(
	SELECT 
		r.Area, r.Year, r.Quarter, r.YearQuarter,
		SUM(r.Revenue) AS Revenue, 
		(LAG(r.Revenue, 1) OVER(PARTITION BY r.Area ORDER BY r.Year, r.Quarter)) AS RevInitial,
		SUM(r.Revenue) - LAG(SUM(r.Revenue),1) OVER(PARTITION BY r.Area ORDER BY r.Year) AS RevGained,
		SUM(s.Subscribers) AS Subscription,
		SUM(s.Subscribers) - LAG(SUM(s.Subscribers),1) OVER(PARTITION BY r.Area ORDER BY r.Year) AS SubGained,
		(LAG(s.Subscribers, 1) OVER(PARTITION BY r.Area ORDER BY r.Year, r.Quarter)) AS SubInitial
	FROM NetSub..Revenue r 
		INNER JOIN NetSub..Subscriber s
			ON r.Area = s.Area
			AND r.Quarter = s.Quarter
			AND r.Year = s.Year
			AND r.YearQuarter = s.YearQuarter
	WHERE (r.YearQuarter = '2018 Q4' OR r.YearQuarter = '2019 Q4')
	GROUP BY r.Area, r.Year, r.Quarter, r.YearQuarter, r.Revenue, s.Subscribers
	)
SELECT
	Area, Year, Quarter, YearQuarter, Revenue, RevInitial, RevGained,
	ROUND((RevGained/Revenue),4) AS RevGrowth,
	Subscription, SubGained, SubInitial,
	ROUND((SubGained/Subscription),4) AS SubGrowth,
	ROUND((Subscription/SubInitial),4) AS RetentionRate
FROM cte3;
------------------------------------------------
-- Analyzing the Quarterly Pattern for the Total Number of Subscriptions and the Retention Rate
------------------------------------------------
SELECT
	Year, Quarter, YearQuarter,
	SUM(Subscribers) AS TotalSubs,
	ROUND((SUM(Subscribers)-LAG(SUM(Subscribers),1) OVER(ORDER BY YearQuarter)),5) AS SubDifference,
	ROUND(SUM(Subscribers)/LAG(SUM(Subscribers),1) OVER(ORDER BY YearQuarter),5) AS RetentionRate
FROM NetSub..Subscriber a
WHERE Year = 2018 OR Year = 2019
GROUP BY Year, Quarter, YearQuarter
ORDER BY Year, Quarter, YearQuarter;
