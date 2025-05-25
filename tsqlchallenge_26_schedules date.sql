/* tsqlchallenge_26_v1.sql */
/* To remove duplicate schedules, uncomment DISTINCT in the aggregate expression. 
* 

IF OBJECT_ID('TC26_TrainingInfo') IS NOT NULL BEGIN
	DROP TABLE TC26_TrainingInfo
END
GO

CREATE TABLE TC26_TrainingInfo (
	TrainingID INT IDENTITY PRIMARY KEY,
	Training VARCHAR(20),
	ClassRoom VARCHAR(20),
	StartTime CHAR(5),
	Duration CHAR(5),
	Wk CHAR(2)
)
GO

INSERT INTO TC26_TrainingInfo (
	Training, ClassRoom, StartTime, Duration, Wk )
SELECT 'SQL Server','Silver-Room','10:00','02:00','M' UNION ALL
SELECT 'SQL Server','Silver-Room','10:00','02:00','W' UNION ALL
SELECT 'SQL Server','Silver-Room','10:00','02:00','T' UNION ALL
SELECT 'SQL Server','Silver-Room','10:00','02:00','F' UNION ALL
SELECT 'ASP.NET','Cloud-Room','11:00','01:45','F' UNION ALL
SELECT 'ASP.NET','Cloud-Room','11:00','01:45','M' UNION ALL
SELECT 'ASP.NET','Cloud-Room','11:00','01:45','TH'
* */

SELECT 
   Training, 
   ClassRoom AS Classroom,
   StartTime + ' - ' + CONVERT(char(5), CONVERT(datetime, StartTime) + CONVERT(datetime, Duration), 108) AS Timing,
   CASE WeekdayBits 
      WHEN 1 THEN 'Mon'
      WHEN 2 THEN 'Tue'
      WHEN 3 THEN 'Mon,Tue'
      WHEN 4 THEN 'Wed'
      WHEN 5 THEN 'Mon,Wed'
      WHEN 6 THEN 'Tue,Wed'
      WHEN 7 THEN 'Mon,Tue,Wed'
      WHEN 8 THEN 'Thu'
      WHEN 9 THEN 'Mon,Thu'
      WHEN 10 THEN 'Tue,Thu'
      WHEN 11 THEN 'Mon,Tue,Thu'
      WHEN 12 THEN 'Wed,Thu'
      WHEN 13 THEN 'Mon,Wed,Thu'
      WHEN 14 THEN 'Tue,Wed,Thu'
      WHEN 15 THEN 'Mon,Tue,Wed,Thu'
      WHEN 16 THEN 'Fri'
      WHEN 17 THEN 'Mon,Fri'
      WHEN 18 THEN 'Tue,Fri'
      WHEN 19 THEN 'Mon,Tue,Fri'
      WHEN 20 THEN 'Wed,Fri'
      WHEN 21 THEN 'Mon,Wed,Fri'
      WHEN 22 THEN 'Tue,Wed,Fri'
      WHEN 23 THEN 'Mon,Tue,Wed,Fri'
      WHEN 24 THEN 'Thu,Fri'
      WHEN 25 THEN 'Mon,Thu,Fri'
      WHEN 26 THEN 'Tue,Thu,Fri'
      WHEN 27 THEN 'Mon,Tue,Thu,Fri'
      WHEN 28 THEN 'Wed,Thu,Fri'
      WHEN 29 THEN 'Mon,Wed,Thu,Fri'
      WHEN 30 THEN 'Tue,Wed,Thu,Fri'
      WHEN 31 THEN 'Mon,Tue,Wed,Thu,Fri'
      ELSE '' END AS Schedule
FROM (
   SELECT 
      Training, 
      ClassRoom, 
      StartTime, 
      Duration, 
      SUM( /* DISTINCT */ CASE Wk 
         WHEN 'M' THEN 1
         WHEN 'T' THEN 2
         WHEN 'W' THEN 4
         WHEN 'TH' THEN 8
         WHEN 'F' THEN 16
         ELSE 0 END
      ) AS WeekdayBits
   FROM dbo.TC26_TrainingInfo
   GROUP BY Training, ClassRoom, StartTime, Duration
) AGG
