-- ============================================================
-- GDPR Dashboard — SQL Script 04
-- Audit Findings & Processing Activities Analysis
-- Author: GDPR Analytics Portfolio Project
-- ============================================================

-- ------------------------------------------------------------
-- 1. Audit findings summary
-- ------------------------------------------------------------
SELECT
    COUNT(*)                                                        AS TotalFindings,
    SUM(CASE WHEN Remediated = 1 THEN 1 ELSE 0 END)                AS Remediated,
    SUM(CASE WHEN Remediated = 0 THEN 1 ELSE 0 END)                AS Outstanding,
    ROUND(100.0 * SUM(CASE WHEN Remediated=1 THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                            AS RemediationRate_Pct,
    ROUND(AVG(CASE WHEN RemediationDays IS NOT NULL
              THEN CAST(RemediationDays AS FLOAT) END), 1)          AS AvgRemediationDays,
    SUM(CASE WHEN Recurring = 1 THEN 1 ELSE 0 END)                 AS RecurringFindings,
    ROUND(100.0 * SUM(CASE WHEN Recurring=1 THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                            AS RecurringRate_Pct
FROM Audit_Findings;


-- ------------------------------------------------------------
-- 2. Findings by risk level
-- ------------------------------------------------------------
SELECT
    RiskLevel,
    COUNT(*)                                                        AS TotalFindings,
    SUM(CASE WHEN Remediated = 1 THEN 1 ELSE 0 END)                AS Remediated,
    SUM(CASE WHEN Remediated = 0 THEN 1 ELSE 0 END)                AS Outstanding,
    ROUND(100.0 * SUM(CASE WHEN Remediated=1 THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                            AS RemediationRate_Pct,
    ROUND(AVG(CASE WHEN RemediationDays IS NOT NULL
              THEN CAST(RemediationDays AS FLOAT) END), 1)          AS AvgRemediationDays,
    SUM(CASE WHEN Recurring = 1 THEN 1 ELSE 0 END)                 AS RecurringCount
FROM Audit_Findings
GROUP BY RiskLevel
ORDER BY CASE RiskLevel
    WHEN 'Critical' THEN 1 WHEN 'High' THEN 2
    WHEN 'Medium'   THEN 3 ELSE 4 END;


-- ------------------------------------------------------------
-- 3. Findings by department — risk exposure
-- ------------------------------------------------------------
SELECT
    Department,
    COUNT(*)                                                        AS TotalFindings,
    SUM(CASE WHEN RiskLevel IN ('Critical','High') THEN 1 ELSE 0 END) AS HighCriticalCount,
    SUM(CASE WHEN Remediated = 0 THEN 1 ELSE 0 END)                AS OutstandingFindings,
    SUM(CASE WHEN Recurring = 1 THEN 1 ELSE 0 END)                 AS RecurringFindings,
    ROUND(100.0 * SUM(CASE WHEN Remediated=1 THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                            AS RemediationRate_Pct
FROM Audit_Findings
GROUP BY Department
ORDER BY HighCriticalCount DESC;


-- ------------------------------------------------------------
-- 4. Finding types — most common issues
-- ------------------------------------------------------------
SELECT
    FindingType,
    COUNT(*)                                                        AS TotalFindings,
    SUM(CASE WHEN RiskLevel = 'Critical' THEN 1 ELSE 0 END)        AS CriticalCount,
    SUM(CASE WHEN Remediated = 0 THEN 1 ELSE 0 END)                AS Outstanding,
    ROUND(AVG(CASE WHEN RemediationDays IS NOT NULL
              THEN CAST(RemediationDays AS FLOAT) END), 1)          AS AvgRemediationDays
FROM Audit_Findings
GROUP BY FindingType
ORDER BY TotalFindings DESC;


-- ------------------------------------------------------------
-- 5. Processing activities compliance (Article 30 register)
-- ------------------------------------------------------------
SELECT
    COUNT(*)                                                        AS TotalActivities,
    SUM(CASE WHEN Compliant = 1 THEN 1 ELSE 0 END)                 AS CompliantActivities,
    ROUND(100.0 * SUM(CASE WHEN Compliant=1 THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                            AS ComplianceRate_Pct,
    SUM(CASE WHEN DPIARequired = 1 THEN 1 ELSE 0 END)              AS DPIARequired,
    SUM(CASE WHEN DPIACompleted = 1 THEN 1 ELSE 0 END)             AS DPIACompleted,
    ROUND(100.0 * SUM(CASE WHEN DPIACompleted=1 THEN 1 ELSE 0 END)
          / NULLIF(SUM(CASE WHEN DPIARequired=1 THEN 1 ELSE 0 END),0),2) AS DPIACompletionRate_Pct,
    SUM(CASE WHEN CrossBorderTransfer = 1 THEN 1 ELSE 0 END)       AS CrossBorderTransfers,
    SUM(CASE WHEN ThirdPartySharing = 1 THEN 1 ELSE 0 END)         AS ThirdPartySharing
FROM Processing_Activities;


-- ------------------------------------------------------------
-- 6. Lawful basis breakdown (Article 6)
-- ------------------------------------------------------------
SELECT
    LawfulBasis,
    COUNT(*)                                                        AS TotalActivities,
    ROUND(100.0 * COUNT(*) /
          (SELECT COUNT(*) FROM Processing_Activities), 2)          AS SharePct,
    SUM(CASE WHEN Compliant = 1 THEN 1 ELSE 0 END)                 AS CompliantCount,
    ROUND(100.0 * SUM(CASE WHEN Compliant=1 THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                            AS ComplianceRate_Pct
FROM Processing_Activities
GROUP BY LawfulBasis
ORDER BY TotalActivities DESC;


-- ------------------------------------------------------------
-- 7. Cross-border transfers — transfer mechanism usage
-- ------------------------------------------------------------
SELECT
    TransferMechanism,
    COUNT(*)                                                        AS TotalActivities,
    SUM(CASE WHEN Compliant = 1 THEN 1 ELSE 0 END)                 AS Compliant,
    ROUND(100.0 * SUM(CASE WHEN Compliant=1 THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                            AS ComplianceRate_Pct
FROM Processing_Activities
WHERE CrossBorderTransfer = 1
GROUP BY TransferMechanism
ORDER BY TotalActivities DESC;


-- ------------------------------------------------------------
-- 8. Outstanding critical and high audit findings — action list
-- ------------------------------------------------------------
SELECT
    FindingID,
    AuditDate,
    Department,
    FindingType,
    RiskLevel,
    Recurring,
    ROUND(JULIANDAY('now') - JULIANDAY(AuditDate))                  AS DaysOpen
FROM Audit_Findings
WHERE Remediated = 0
  AND RiskLevel IN ('Critical', 'High')
ORDER BY CASE RiskLevel WHEN 'Critical' THEN 1 ELSE 2 END,
         AuditDate ASC;
