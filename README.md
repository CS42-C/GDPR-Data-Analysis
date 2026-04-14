# GDPR & Data Protection Dashboard

**Multi-Domain GDPR Compliance Analysis — Power BI, SQL & Legal Analysis**  
Period: January 2022 – December 2024 | 3 Years | 6 Compliance Domains | 1,480 Records

---

## Overview

This project delivers a comprehensive GDPR compliance monitoring dashboard across six regulatory domains, grounded in Regulation (EU) 2016/679. The dataset comprises 1,480 records across six interrelated tables, processed through a SQLite database and visualised in Power BI using DirectQuery mode.

The dashboard was designed to go beyond operational reporting — connecting enforcement patterns, regulatory obligations, and compliance data into actionable legal and operational intelligence. Each domain maps directly to a specific GDPR article, with compliance targets benchmarked against regulatory expectations and EDPB guidelines.

---

## Business Problem

GDPR compliance is not a single metric — it spans breach notification, subject rights, fine management, audit governance, processing activity records, and data protection impact assessments. Organisations managing compliance across these domains typically lack a unified view, making it difficult to identify systemic risks, track remediation progress, or benchmark performance against legal thresholds.

This project addresses that gap by building a multi-domain compliance intelligence layer that surfaces:

- Real-time compliance status across all six GDPR domains
- Legal risk exposure by article, department, and severity
- Fine exposure and appeal performance across six supervisory authorities
- Audit finding trends, recurring failures, and remediation gaps
- Processing activity governance and DPIA completion tracking

---

## Compliance Status Summary

| Domain | Key Metric | Result | Target | Status |
|---|---|---|---|---|
| Breach Notification (Art. 33) | 72hr Compliance Rate | 53.25% | 90% | NON-COMPLIANT |
| Subject Rights (Art. 12) | 30-Day Response Rate | 66.36% | 95% | NON-COMPLIANT |
| Fine Management (Art. 83) | Appeal Reduction Rate | 9.49% | — | REVIEW |
| Audit Findings (Art. 24) | Remediation Rate | 72.80% | 80% | REVIEW NEEDED |
| Processing Activities (Art. 30) | Compliance Rate | 74.00% | 90% | NON-COMPLIANT |
| DPIA Completion (Art. 35) | % of Required Done | 71.43% | 100% | AT RISK |

---

## Key Findings

### Breach Notification — Article 33
- Overall 72-hour compliance rate of **53.25%** — critically below the legal threshold, placing the organisation in clear violation of Art. 33 for nearly half of all breaches
- Average notification time of **77.90 hours** exceeds the 72-hour limit — the average breach is already non-compliant before notification is made
- High severity breaches achieve **91.0% compliance** — escalation procedures work for visible incidents but systematically fail for routine ones
- Low severity breaches have the worst compliance rate at **16.4%** — 117 of 140 low severity breaches were notified late, indicating systematic deprioritisation
- Most frequent breach types: Accidental Disclosure (61) and Lost/Stolen Devices (57) — both preventable through training and device encryption policies
- Legal note: the 72-hour clock starts from awareness, not occurrence (EDPB Guidelines 9/2022). The persistent late notification of Low severity breaches suggests an incorrect triage policy applying a severity filter to a time-bound legal obligation

### Subject Rights Requests — Article 12
- **600 requests** processed over 3 years — 1 in 3 completed requests missed the 30-day legal deadline
- Average response time of **23.27 days** appears satisfactory but masks late outliers well beyond the statutory limit
- No department achieves the 95% compliance target — even the best performer (Finance at 75%) is 20 points below
- Marketing at 68.3% is particularly concerning given heavy reliance on Consent as lawful basis — objection rights under Art. 21 must be actioned promptly
- Refusal rate of 9.83% is a legitimate compliance tool under Art. 12(5), but requires documented justification and communication of the right to lodge a supervisory authority complaint

### Fine Exposure & Regulatory Actions
- **€1.89B in total fines issued** across six European supervisory authorities
- **€179.73M recovered through appeals** — 39.39% of appeals resulted in reduced fines, confirming legal challenge as a measurable compliance strategy
- DPA (Ireland) leads in total fines (€537.90M) — reflecting Ireland's role as lead supervisory authority for major technology companies under the one-stop-shop mechanism (Art. 60)
- Art. 32 (Security of Processing) is the most frequently enforced article — directly linked to the high breach volume
- Art. 25 (Privacy by Design) appearing second confirms systems are being built without embedded privacy controls
- Post-Schrems II: 66 cross-border transfers require Transfer Impact Assessments alongside SCCs — failure to conduct TIAs is an Art. 46 violation

### Audit Findings — Article 24
- **250 findings** across 3 years — 68 remain outstanding including critical items
- Remediation rate of **72.80%** is below the 80% target
- Recurring rate of **28.80%** is the most legally significant metric — nearly 1 in 3 findings reappears, indicating root causes are not being addressed
- Recurring findings constitute an aggravating factor under Art. 83(2)(d) in any regulatory investigation
- Technical Vulnerabilities and Access Control Issues combined account for 36.4% of all findings

### Processing Activities Register — Article 30
- **74% compliance** — 39 of 150 activities operate without full GDPR compliance
- Vital Interests applied to 27 activities is legally problematic — Art. 6(1)(d) is intended for genuine life-or-death situations, not routine processing
- **25 outstanding DPIAs** represent the highest legal risk — processing cannot lawfully proceed for high-risk activities without a completed DPIA under Art. 35
- Legitimate Interests (Art. 6(1)(f)) is the most frequently misapplied lawful basis — all 23 activities require a documented Legitimate Interests Assessment

---

## Dashboard Structure

The Power BI dashboard is organised across six report pages, each mapping to a specific GDPR obligation:

| Page | GDPR Article | Content |
|---|---|---|
| Overview | — | Top-line KPIs across all six domains |
| Breach Analysis | Art. 33 | 72hr compliance, breach types, severity breakdown, monthly trend |
| Subject Rights (DSAR) | Art. 12 | Request volume, outcomes, department compliance, response times |
| Fine Exposure | Art. 83 | Fines by authority, appeal outcomes, most breached articles |
| Audit Findings | Art. 24 | Finding types, risk levels, remediation rate, recurring patterns |
| Processing Register | Art. 30 | Activity compliance, lawful basis breakdown, DPIA status, cross-border transfers |

---

## Technical Stack

### SQL (SQLite)
The dataset was structured as a relational database with six interrelated tables, queried using SQLite before being connected to Power BI via DirectQuery.

```sql
-- 72-Hour Compliance Rate by Severity
SELECT
    severity,
    COUNT(*) AS total_breaches,
    SUM(CASE WHEN notification_hours <= 72 THEN 1 ELSE 0 END) AS notified_on_time,
    ROUND(
        100.0 * SUM(CASE WHEN notification_hours <= 72 THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS compliance_rate_pct
FROM breaches
GROUP BY severity
ORDER BY compliance_rate_pct DESC;

-- DSAR 30-Day Compliance by Department
SELECT
    department,
    COUNT(*) AS total_requests,
    SUM(CASE WHEN response_days <= 30 THEN 1 ELSE 0 END) AS completed_on_time,
    ROUND(
        100.0 * SUM(CASE WHEN response_days <= 30 THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS compliance_rate_pct,
    ROUND(AVG(response_days), 2) AS avg_response_days
FROM dsar_requests
WHERE status = 'Completed'
GROUP BY department
ORDER BY compliance_rate_pct ASC;

-- Fine Exposure by Supervisory Authority with Appeal Outcomes
SELECT
    authority,
    country,
    SUM(fine_issued) AS total_issued,
    SUM(fine_final) AS total_final,
    SUM(fine_issued - fine_final) AS total_saved,
    ROUND(100.0 * SUM(fine_issued - fine_final) / SUM(fine_issued), 2) AS savings_rate_pct,
    COUNT(CASE WHEN appeal_status = 'Appealed' THEN 1 END) AS appeals_filed
FROM fines
GROUP BY authority, country
ORDER BY total_issued DESC;

-- Recurring Audit Findings Analysis
SELECT
    finding_type,
    COUNT(*) AS total_findings,
    SUM(CASE WHEN is_recurring = 1 THEN 1 ELSE 0 END) AS recurring_count,
    ROUND(
        100.0 * SUM(CASE WHEN is_recurring = 1 THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS recurring_rate_pct,
    SUM(CASE WHEN remediated = 0 THEN 1 ELSE 0 END) AS outstanding
FROM audit_findings
GROUP BY finding_type
ORDER BY recurring_rate_pct DESC;

-- Processing Activities — Lawful Basis & DPIA Compliance
SELECT
    lawful_basis,
    COUNT(*) AS total_activities,
    SUM(CASE WHEN dpia_required = 1 AND dpia_completed = 0 THEN 1 ELSE 0 END) AS dpia_outstanding,
    SUM(CASE WHEN cross_border_transfer = 1 THEN 1 ELSE 0 END) AS cross_border_count,
    SUM(CASE WHEN compliant = 1 THEN 1 ELSE 0 END) AS compliant_count,
    ROUND(100.0 * SUM(CASE WHEN compliant = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS compliance_rate
FROM processing_activities
GROUP BY lawful_basis
ORDER BY total_activities DESC;
```

### Power BI
- **DirectQuery mode** — live connection to SQLite database, enabling real-time data refresh without import limitations
- **Power Query (M)** — data type standardisation, null handling, and column normalisation across all six tables
- **DAX measures** — compliance rate calculations, time-intelligence trends, and conditional KPI status indicators
- **Data modelling** — six-table relational schema with fact and dimension separation

### DAX — Key Measures

```dax
-- 72-Hour Breach Compliance Rate
72hr Compliance Rate =
DIVIDE(
    COUNTROWS(FILTER(Breaches, Breaches[Notification_Hours] <= 72)),
    COUNTROWS(Breaches),
    0
)

-- DSAR 30-Day Compliance Rate
30-Day Compliance Rate =
DIVIDE(
    COUNTROWS(FILTER(DSAR_Requests,
        DSAR_Requests[Response_Days] <= 30 &&
        DSAR_Requests[Status] = "Completed")),
    COUNTROWS(FILTER(DSAR_Requests, DSAR_Requests[Status] = "Completed")),
    0
)

-- Fine Appeal Savings
Appeal Savings =
SUMX(
    Fines,
    Fines[Fine_Issued] - Fines[Fine_Final]
)

-- Audit Remediation Rate
Remediation Rate =
DIVIDE(
    COUNTROWS(FILTER(Audit_Findings, Audit_Findings[Remediated] = 1)),
    COUNTROWS(Audit_Findings),
    0
)

-- DPIA Completion Rate
DPIA Completion Rate =
DIVIDE(
    COUNTROWS(FILTER(Processing_Activities,
        Processing_Activities[DPIA_Required] = 1 &&
        Processing_Activities[DPIA_Completed] = 1)),
    COUNTROWS(FILTER(Processing_Activities,
        Processing_Activities[DPIA_Required] = 1)),
    0
)
```

---

## Database Schema

```
gdpr_compliance.db
│
├── breaches              ← Art. 33 — breach records, severity, notification timing
├── dsar_requests         ← Art. 12 — subject rights requests, response times, outcomes
├── fines                 ← Art. 83 — regulatory fines, appeals, supervisory authorities
├── audit_findings        ← Art. 24 — audit results, risk levels, remediation status
├── processing_activities ← Art. 30 — processing register, lawful basis, DPIA status
└── dates                 ← Date dimension table for time-intelligence
```

---

## Files in This Repository

```
gdpr-data-protection-dashboard/
│
├── README.md
├── data/
│   ├── 01_breach_compliance
│   ├── 02_dsar_analysis
│   ├── 03_fine_exposure
│   ├── 04_audit_findings
├── sql_database/
│   └── gdpr_dataprotection                 
├── dashboard/
│   └── GDPR & Data Protection Dashboard.pdf
├── EDA Notebook/
│   └── GDPR_EDA_Notebook.ipynb
└── docs/
    └── GDPR_Full_Insights_Report.pdf
```

---

## What I Learned

This project started as a technical exercise and became something more interesting — a case study in how legal knowledge and data analysis reinforce each other.

The most revealing moment was the Low severity breach finding. On the surface, a 16.4% compliance rate looks like an operational failure. But drilling into it revealed something more specific: the organisation appeared to be applying a severity filter to decide whether to notify at all — which is legally incorrect. The 72-hour obligation runs from awareness regardless of severity. The data wasn't showing a process breakdown; it was showing a misunderstanding of the legal obligation. That distinction matters enormously in a regulatory investigation, and it only becomes visible when you read the data through a legal lens.

The recurring audit finding rate of 28.80% was the other number that stuck with me. A recurring finding is not just an operational gap — under Art. 83(2)(d) it is an aggravating factor in fine calculation. The data was flagging not just a compliance problem but a potential legal liability that would compound in any supervisory investigation.

Building the database in SQLite before connecting to Power BI via DirectQuery also changed how I think about dashboard architecture. The discipline of writing queries first — defining exactly what question each query answers before building any visual — produces cleaner, more defensible outputs than starting with the dashboard and working backwards.

---

## Legal Framework

This project is grounded in Regulation (EU) 2016/679 (GDPR), with reference to:

- EDPB Guidelines 9/2022 on breach notification and awareness thresholds
- Schrems II ruling (C-311/18) on cross-border transfer mechanisms and Transfer Impact Assessments
- Art. 83(2) aggravating and mitigating factors in fine calculation
- One-stop-shop mechanism (Art. 60) and lead supervisory authority framework

---

## About

Built by **Francisco Costa** — Customs Analyst with a Master's degree in Civil Law and a background spanning legal analysis, trade compliance, and data analytics. This project reflects the intersection of regulatory expertise and analytical capability that defines my professional approach.

[LinkedIn](https://linkedin.com/in/francscosta) · franciscostabusiness@gmail.com
