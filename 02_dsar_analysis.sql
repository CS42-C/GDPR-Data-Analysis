-- ============================================================
-- GDPR Dashboard — SQL Script 02
-- Subject Rights Requests Analysis (Article 12)
-- Author: GDPR Analytics Portfolio Project
-- ============================================================

-- ------------------------------------------------------------
-- 1. Overall DSAR compliance summary
-- ------------------------------------------------------------
SELECT
    COUNT(*)                                                        AS TotalRequests,
    SUM(CASE WHEN Completed = 1 THEN 1 ELSE 0 END)                 AS CompletedRequests,
    SUM(CASE WHEN Completed = 0 THEN 1 ELSE 0 END)                 AS PendingRequests,
    SUM(CASE WHEN Within30Days = 1 THEN 1 ELSE 0 END)              AS RespondedOnTime,
    ROUND(100.0 * SUM(Within30Days) /
          NULLIF(SUM(CASE WHEN Completed = 1 THEN 1 ELSE 0 END),0),2) AS ComplianceRate_Pct,
    ROUND(AVG(CASE WHEN ResponseDays IS NOT NULL
              THEN ResponseDays END), 1)                            AS AvgResponseDays
FROM Subject_Requests;


-- ------------------------------------------------------------
-- 2. Request volume and compliance by type
-- ------------------------------------------------------------
SELECT
    RequestType,
    COUNT(*)                                                        AS TotalRequests,
    SUM(CASE WHEN Completed = 1 THEN 1 ELSE 0 END)                 AS Completed,
    SUM(CASE WHEN Within30Days = 1 THEN 1 ELSE 0 END)              AS OnTime,
    ROUND(100.0 * SUM(Within30Days) /
          NULLIF(SUM(CASE WHEN Completed=1 THEN 1 ELSE 0 END),0),2) AS ComplianceRate_Pct,
    ROUND(AVG(CASE WHEN ResponseDays IS NOT NULL
              THEN CAST(ResponseDays AS FLOAT) END), 1)             AS AvgResponseDays,
    MAX(CASE WHEN ResponseDays IS NOT NULL
        THEN ResponseDays END)                                      AS MaxResponseDays
FROM Subject_Requests
GROUP BY RequestType
ORDER BY TotalRequests DESC;


-- ------------------------------------------------------------
-- 3. Department workload — requests received
-- ------------------------------------------------------------
SELECT
    Department,
    COUNT(*)                                                        AS TotalRequests,
    SUM(CASE WHEN Completed = 1 THEN 1 ELSE 0 END)                 AS Completed,
    SUM(CASE WHEN Completed = 0 THEN 1 ELSE 0 END)                 AS Pending,
    ROUND(100.0 * SUM(Within30Days) /
          NULLIF(SUM(CASE WHEN Completed=1 THEN 1 ELSE 0 END),0),2) AS ComplianceRate_Pct,
    ROUND(AVG(CASE WHEN ResponseDays IS NOT NULL
              THEN CAST(ResponseDays AS FLOAT) END), 1)             AS AvgResponseDays
FROM Subject_Requests
GROUP BY Department
ORDER BY TotalRequests DESC;


-- ------------------------------------------------------------
-- 4. Request outcomes breakdown
-- ------------------------------------------------------------
SELECT
    Outcome,
    COUNT(*)                                                        AS Total,
    ROUND(100.0 * COUNT(*) /
          (SELECT COUNT(*) FROM Subject_Requests WHERE Completed = 1), 2) AS SharePct
FROM Subject_Requests
WHERE Completed = 1
GROUP BY Outcome
ORDER BY Total DESC;


-- ------------------------------------------------------------
-- 5. Monthly DSAR trend
-- ------------------------------------------------------------
SELECT
    SUBSTR(RequestDate, 1, 7)                                       AS YearMonth,
    COUNT(*)                                                        AS TotalRequests,
    SUM(CASE WHEN Completed = 1 THEN 1 ELSE 0 END)                 AS Completed,
    SUM(CASE WHEN Within30Days = 1 THEN 1 ELSE 0 END)              AS OnTime,
    ROUND(100.0 * SUM(Within30Days) /
          NULLIF(SUM(CASE WHEN Completed=1 THEN 1 ELSE 0 END),0),2) AS ComplianceRate_Pct
FROM Subject_Requests
GROUP BY SUBSTR(RequestDate, 1, 7)
ORDER BY YearMonth;


-- ------------------------------------------------------------
-- 6. Late responses — overdue requests list
-- ------------------------------------------------------------
SELECT
    RequestID,
    RequestDate,
    RequestType,
    Department,
    Country,
    ResponseDays,
    ResponseDays - 30                                               AS DaysOverdue,
    Outcome
FROM Subject_Requests
WHERE Completed = 1
  AND Within30Days = 0
ORDER BY ResponseDays DESC
LIMIT 50;


-- ------------------------------------------------------------
-- 7. Country-level DSAR volume
-- ------------------------------------------------------------
SELECT
    Country,
    COUNT(*)                                                        AS TotalRequests,
    ROUND(100.0 * SUM(Within30Days) /
          NULLIF(SUM(CASE WHEN Completed=1 THEN 1 ELSE 0 END),0),2) AS ComplianceRate_Pct,
    ROUND(AVG(CASE WHEN ResponseDays IS NOT NULL
              THEN CAST(ResponseDays AS FLOAT) END), 1)             AS AvgResponseDays
FROM Subject_Requests
GROUP BY Country
ORDER BY TotalRequests DESC;
