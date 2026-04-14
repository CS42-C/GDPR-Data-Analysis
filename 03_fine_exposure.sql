-- ============================================================
-- GDPR Dashboard — SQL Script 03
-- Fine Exposure & Regulatory Actions Analysis
-- Author: GDPR Analytics Portfolio Project
-- ============================================================

-- ------------------------------------------------------------
-- 1. Total fine exposure summary
-- ------------------------------------------------------------
SELECT
    COUNT(*)                                                        AS TotalActions,
    ROUND(SUM(FineAmountEUR), 2)                                    AS TotalFineIssuedEUR,
    ROUND(SUM(FinalAmountEUR), 2)                                   AS TotalFineFinalEUR,
    ROUND(SUM(FineAmountEUR) - SUM(FinalAmountEUR), 2)              AS TotalReductionEUR,
    ROUND(AVG(FineAmountEUR), 2)                                    AS AvgFineEUR,
    MAX(FineAmountEUR)                                              AS MaxFineEUR,
    SUM(CASE WHEN Appealed = 1 THEN 1 ELSE 0 END)                  AS AppealsLodged,
    ROUND(100.0 * SUM(CASE WHEN Appealed=1 THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                            AS AppealRate_Pct
FROM Regulatory_Actions;


-- ------------------------------------------------------------
-- 2. Fines by supervisory authority
-- ------------------------------------------------------------
SELECT
    SupervisoryAuth,
    COUNT(*)                                                        AS TotalActions,
    ROUND(SUM(FineAmountEUR), 2)                                    AS TotalFinesEUR,
    ROUND(AVG(FineAmountEUR), 2)                                    AS AvgFineEUR,
    MAX(FineAmountEUR)                                              AS MaxFineEUR,
    SUM(CASE WHEN Appealed = 1 THEN 1 ELSE 0 END)                  AS Appeals,
    ROUND(100.0 * SUM(CASE WHEN Appealed=1 THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                            AS AppealRate_Pct
FROM Regulatory_Actions
GROUP BY SupervisoryAuth
ORDER BY TotalFinesEUR DESC;


-- ------------------------------------------------------------
-- 3. Most frequently breached GDPR articles
-- ------------------------------------------------------------
SELECT
    ArticleBreached,
    COUNT(*)                                                        AS TotalActions,
    ROUND(SUM(FineAmountEUR), 2)                                    AS TotalFinesEUR,
    ROUND(AVG(FineAmountEUR), 2)                                    AS AvgFineEUR,
    MAX(FineAmountEUR)                                              AS MaxFineEUR
FROM Regulatory_Actions
GROUP BY ArticleBreached
ORDER BY TotalFinesEUR DESC;


-- ------------------------------------------------------------
-- 4. Appeal outcomes analysis
-- ------------------------------------------------------------
SELECT
    AppealOutcome,
    COUNT(*)                                                        AS TotalAppeals,
    ROUND(SUM(FineAmountEUR), 2)                                    AS OriginalFineEUR,
    ROUND(SUM(FinalAmountEUR), 2)                                   AS FinalFineEUR,
    ROUND(SUM(FineAmountEUR) - SUM(FinalAmountEUR), 2)              AS TotalSavedEUR,
    ROUND(100.0 * (SUM(FineAmountEUR) - SUM(FinalAmountEUR))
          / NULLIF(SUM(FineAmountEUR), 0), 2)                       AS ReductionRate_Pct
FROM Regulatory_Actions
WHERE Appealed = 1
GROUP BY AppealOutcome
ORDER BY TotalAppeals DESC;


-- ------------------------------------------------------------
-- 5. Fine trend by year and country
-- ------------------------------------------------------------
SELECT
    SUBSTR(IssueDate, 1, 4)                                         AS Year,
    Country,
    COUNT(*)                                                        AS TotalActions,
    ROUND(SUM(FineAmountEUR), 2)                                    AS TotalFinesEUR,
    ROUND(AVG(FineAmountEUR), 2)                                    AS AvgFineEUR
FROM Regulatory_Actions
GROUP BY SUBSTR(IssueDate, 1, 4), Country
ORDER BY Year, TotalFinesEUR DESC;


-- ------------------------------------------------------------
-- 6. Department-level fine exposure from breaches
-- ------------------------------------------------------------
SELECT
    b.Department,
    COUNT(b.BreachID)                                               AS TotalBreaches,
    SUM(CASE WHEN b.FineIssued = 1 THEN 1 ELSE 0 END)              AS BreachesWithFines,
    ROUND(SUM(b.FineAmountEUR), 2)                                  AS TotalFineExposureEUR,
    ROUND(AVG(CASE WHEN b.FineAmountEUR > 0
              THEN b.FineAmountEUR END), 2)                         AS AvgFineWhenIssuedEUR,
    SUM(b.SubjectsAffected)                                         AS TotalSubjectsAffected
FROM Breaches b
GROUP BY b.Department
ORDER BY TotalFineExposureEUR DESC;


-- ------------------------------------------------------------
-- 7. Top 10 largest individual fines
-- ------------------------------------------------------------
SELECT
    ActionID,
    IssueDate,
    SupervisoryAuth,
    Country,
    ArticleBreached,
    ROUND(FineAmountEUR, 2)                                         AS FineIssuedEUR,
    Appealed,
    AppealOutcome,
    ROUND(FinalAmountEUR, 2)                                        AS FinalAmountEUR,
    Severity
FROM Regulatory_Actions
ORDER BY FineAmountEUR DESC
LIMIT 10;
