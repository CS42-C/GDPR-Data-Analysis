-- ============================================================
-- GDPR Dashboard — SQL Script 01
-- Breach Notification Compliance (Article 33)
-- Author: GDPR Analytics Portfolio Project
-- ============================================================

-- ------------------------------------------------------------
-- 1. Overall 72-hour notification compliance rate
-- ------------------------------------------------------------
SELECT
    COUNT(*)                                                        AS TotalBreaches,
    SUM(Within72Hours)                                              AS NotifiedOnTime,
    COUNT(*) - SUM(Within72Hours)                                   AS NotifiedLate,
    ROUND(100.0 * SUM(Within72Hours) / COUNT(*), 2)                 AS ComplianceRate_Pct,
    ROUND(AVG(NotificationHours), 1)                                AS AvgNotificationHours
FROM Breaches;


-- ------------------------------------------------------------
-- 2. Compliance rate by year
-- ------------------------------------------------------------
SELECT
    SUBSTR(DetectionDate, 1, 4)                                     AS Year,
    COUNT(*)                                                        AS TotalBreaches,
    SUM(Within72Hours)                                              AS CompliantCount,
    ROUND(100.0 * SUM(Within72Hours) / COUNT(*), 2)                 AS ComplianceRate_Pct,
    ROUND(AVG(NotificationHours), 1)                                AS AvgNotificationHours
FROM Breaches
GROUP BY SUBSTR(DetectionDate, 1, 4)
ORDER BY Year;


-- ------------------------------------------------------------
-- 3. Compliance rate by severity
-- ------------------------------------------------------------
SELECT
    Severity,
    COUNT(*)                                                        AS TotalBreaches,
    SUM(Within72Hours)                                              AS CompliantCount,
    COUNT(*) - SUM(Within72Hours)                                   AS NonCompliantCount,
    ROUND(100.0 * SUM(Within72Hours) / COUNT(*), 2)                 AS ComplianceRate_Pct,
    ROUND(AVG(NotificationHours), 1)                                AS AvgNotificationHours,
    MAX(NotificationHours)                                          AS MaxNotificationHours
FROM Breaches
GROUP BY Severity
ORDER BY CASE Severity
    WHEN 'Critical' THEN 1 WHEN 'High' THEN 2
    WHEN 'Medium'   THEN 3 ELSE 4 END;


-- ------------------------------------------------------------
-- 4. Breach volume and subjects affected by type
-- ------------------------------------------------------------
SELECT
    BreachType,
    COUNT(*)                                                        AS TotalBreaches,
    SUM(SubjectsAffected)                                           AS TotalSubjectsAffected,
    ROUND(AVG(SubjectsAffected), 0)                                 AS AvgSubjectsAffected,
    SUM(CASE WHEN Severity IN ('High','Critical') THEN 1 ELSE 0 END) AS HighCriticalCount,
    ROUND(100.0 * SUM(Within72Hours) / COUNT(*), 2)                 AS ComplianceRate_Pct
FROM Breaches
GROUP BY BreachType
ORDER BY TotalBreaches DESC;


-- ------------------------------------------------------------
-- 5. Department risk ranking — breaches + subjects affected
-- ------------------------------------------------------------
SELECT
    Department,
    COUNT(*)                                                        AS TotalBreaches,
    SUM(CASE WHEN Severity = 'Critical' THEN 1 ELSE 0 END)         AS CriticalBreaches,
    SUM(CASE WHEN Severity = 'High'     THEN 1 ELSE 0 END)         AS HighBreaches,
    SUM(SubjectsAffected)                                           AS TotalSubjectsAffected,
    SUM(FineAmountEUR)                                              AS TotalFineExposureEUR,
    ROUND(100.0 * SUM(Within72Hours) / COUNT(*), 2)                 AS ComplianceRate_Pct
FROM Breaches
GROUP BY Department
ORDER BY TotalSubjectsAffected DESC;


-- ------------------------------------------------------------
-- 6. Monthly breach trend — rolling view
-- ------------------------------------------------------------
SELECT
    SUBSTR(DetectionDate, 1, 7)                                     AS YearMonth,
    COUNT(*)                                                        AS TotalBreaches,
    SUM(CASE WHEN Severity = 'Critical' THEN 1 ELSE 0 END)         AS CriticalBreaches,
    SUM(SubjectsAffected)                                           AS SubjectsAffected,
    ROUND(100.0 * SUM(Within72Hours) / COUNT(*), 2)                 AS ComplianceRate_Pct
FROM Breaches
GROUP BY SUBSTR(DetectionDate, 1, 7)
ORDER BY YearMonth;


-- ------------------------------------------------------------
-- 7. Non-compliant critical breaches — high priority list
-- ------------------------------------------------------------
SELECT
    BreachID,
    DetectionDate,
    NotificationDate,
    ROUND(NotificationHours, 1)                                     AS NotificationHours,
    BreachType,
    Department,
    DataCategory,
    SubjectsAffected,
    SupervisoryAuth,
    FineAmountEUR
FROM Breaches
WHERE Severity = 'Critical'
  AND Within72Hours = 0
ORDER BY SubjectsAffected DESC;
