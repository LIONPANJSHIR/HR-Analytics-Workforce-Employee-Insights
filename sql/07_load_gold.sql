/* =====================================================================
   PROJET       : HR Analytics - Workforce & Employee Insights
   SCRIPT       : 007_load_gold.sql
   BASE         : HR_Analytics
   SOURCE       : PROCESSED.employees
   CIBLE        : GOLD.employee_analytics

   OBJECTIF
   ---------------------------------------------------------------------
   Alimenter la couche analytique GOLD à partir des données nettoyées
   disponibles dans PROCESSED.employees.

   ENRICHISSEMENTS ANALYTIQUES
   ---------------------------------------------------------------------
   Création des variables dérivées suivantes :

   - AgeGroup        : segmentation des employés par tranche d'âge
   - ExperienceGroup : segmentation selon l'expérience professionnelle
   - IncomeBand      : segmentation dynamique du revenu par quartiles
   - OverTimeFlag    : conversion de Yes/No en indicateur binaire
   - TenureGroup     : segmentation selon l'ancienneté
   - AttritionFlag   : conversion de Yes/No en indicateur binaire

   GRANULARITÉ
   ---------------------------------------------------------------------
   1 ligne = 1 employé
===================================================================== */

USE HR_Analytics;
GO


/* =====================================================================
   01. RÉINITIALISATION DE LA TABLE GOLD
   =====================================================================
   La table cible est vidée avant chaque chargement.

   Cette approche permet de rejouer le pipeline sans dupliquer les
   employés déjà présents dans la couche GOLD.
===================================================================== */

TRUNCATE TABLE GOLD.employee_analytics;
GO


/* =====================================================================
   02. PRÉPARATION DES VARIABLES ANALYTIQUES
   =====================================================================
   Le revenu mensuel est segmenté en quatre groupes de taille
   approximativement équivalente à l'aide de NTILE(4).

   Cette méthode permet de construire les catégories de revenu à partir
   de la distribution réelle des données plutôt qu'à partir de seuils
   définis arbitrairement.

   IncomeQuartile :
       1 = 25 % des revenus les plus faibles
       2 = tranche intermédiaire basse
       3 = tranche intermédiaire haute
       4 = 25 % des revenus les plus élevés
===================================================================== */

WITH EmployeeIncomeQuartiles AS
(
    SELECT
        *,
        NTILE(4) OVER (
            ORDER BY MonthlyIncome
        ) AS IncomeQuartile

    FROM PROCESSED.employees
)


/* =====================================================================
   03. CHARGEMENT DE LA TABLE GOLD
===================================================================== */

INSERT INTO GOLD.employee_analytics
(
    EmployeeNumber,

    Age,
    AgeGroup,
    Gender,
    MaritalStatus,

    Department,
    JobRole,
    JobLevel,
    BusinessTravel,

    Education,
    EducationField,
    TotalWorkingYears,
    ExperienceGroup,
    NumCompaniesWorked,
    TrainingTimesLastYear,

    MonthlyIncome,
    IncomeBand,
    PercentSalaryHike,
    StockOptionLevel,

    EnvironmentSatisfaction,
    JobSatisfaction,
    RelationshipSatisfaction,
    WorkLifeBalance,
    JobInvolvement,
    PerformanceRating,

    DistanceFromHome,
    OverTime,
    OverTimeFlag,

    YearsAtCompany,
    TenureGroup,
    YearsInCurrentRole,
    YearsSinceLastPromotion,
    YearsWithCurrManager,

    Attrition,
    AttritionFlag
)

SELECT

    /* ================================================================
       IDENTIFICATION
    ================================================================= */

    EmployeeNumber,


    /* ================================================================
       PROFIL DÉMOGRAPHIQUE
    ================================================================= */

    Age,

    CASE
        WHEN Age BETWEEN 18 AND 24 THEN '18-24'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS AgeGroup,

    Gender,

    MaritalStatus,


    /* ================================================================
       STRUCTURE ORGANISATIONNELLE
    ================================================================= */

    Department,

    JobRole,

    JobLevel,

    BusinessTravel,


    /* ================================================================
       FORMATION ET EXPÉRIENCE PROFESSIONNELLE
    ================================================================= */

    Education,

    EducationField,

    TotalWorkingYears,

    CASE
        WHEN TotalWorkingYears BETWEEN 0 AND 2
            THEN '0-2 ans'

        WHEN TotalWorkingYears BETWEEN 3 AND 5
            THEN '3-5 ans'

        WHEN TotalWorkingYears BETWEEN 6 AND 10
            THEN '6-10 ans'

        WHEN TotalWorkingYears BETWEEN 11 AND 20
            THEN '11-20 ans'

        ELSE '20+ ans'

    END AS ExperienceGroup,

    NumCompaniesWorked,

    TrainingTimesLastYear,


    /* ================================================================
       RÉMUNÉRATION
       ================================================================
       Les catégories sont construites dynamiquement à partir des
       quartiles de MonthlyIncome.
    ================================================================= */

    MonthlyIncome,

    CASE IncomeQuartile

        WHEN 1 THEN 'Faible'

        WHEN 2 THEN 'Intermédiaire'

        WHEN 3 THEN 'Élevé'

        WHEN 4 THEN 'Très élevé'

    END AS IncomeBand,

    PercentSalaryHike,

    StockOptionLevel,


    /* ================================================================
       SATISFACTION, ENGAGEMENT ET PERFORMANCE
    ================================================================= */

    EnvironmentSatisfaction,

    JobSatisfaction,

    RelationshipSatisfaction,

    WorkLifeBalance,

    JobInvolvement,

    PerformanceRating,


    /* ================================================================
       CONDITIONS DE TRAVAIL
    ================================================================= */

    DistanceFromHome,

    OverTime,

    CASE
        WHEN OverTime = 'Yes' THEN 1
        WHEN OverTime = 'No'  THEN 0
    END AS OverTimeFlag,


    /* ================================================================
       ANCIENNETÉ ET PARCOURS DANS L'ENTREPRISE
    ================================================================= */

    YearsAtCompany,

    CASE
        WHEN YearsAtCompany BETWEEN 0 AND 2
            THEN '0-2 ans'

        WHEN YearsAtCompany BETWEEN 3 AND 5
            THEN '3-5 ans'

        WHEN YearsAtCompany BETWEEN 6 AND 10
            THEN '6-10 ans'

        WHEN YearsAtCompany BETWEEN 11 AND 20
            THEN '11-20 ans'

        ELSE '20+ ans'

    END AS TenureGroup,

    YearsInCurrentRole,

    YearsSinceLastPromotion,

    YearsWithCurrManager,


    /* ================================================================
       ATTRITION
    ================================================================= */

    Attrition,

    CASE
        WHEN Attrition = 'Yes' THEN 1
        WHEN Attrition = 'No'  THEN 0
    END AS AttritionFlag

FROM EmployeeIncomeQuartiles;
GO


/* =====================================================================
   04. CONTRÔLE DU NOMBRE DE LIGNES
   =====================================================================
   La couche GOLD doit conserver la même granularité que la couche
   PROCESSED : une ligne par employé.
===================================================================== */

SELECT
    (SELECT COUNT(*)
     FROM PROCESSED.employees) AS ProcessedRows,

    (SELECT COUNT(*)
     FROM GOLD.employee_analytics) AS GoldRows;
GO


/* =====================================================================
   05. CONTRÔLE DE L'UNICITÉ
===================================================================== */

SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT EmployeeNumber) AS UniqueEmployees
FROM GOLD.employee_analytics;
GO


/* =====================================================================
   06. CONTRÔLE DES VARIABLES DÉRIVÉES
===================================================================== */

SELECT TOP 20

    EmployeeNumber,

    Age,
    AgeGroup,

    MonthlyIncome,
    IncomeBand,

    TotalWorkingYears,
    ExperienceGroup,

    YearsAtCompany,
    TenureGroup,

    OverTime,
    OverTimeFlag,

    Attrition,
    AttritionFlag

FROM GOLD.employee_analytics

ORDER BY EmployeeNumber;
GO


/* =====================================================================
   07. CONTRÔLE DE LA DISTRIBUTION DES GROUPES DE REVENU
===================================================================== */

SELECT
    IncomeBand,
    COUNT(*) AS EmployeeCount,
    MIN(MonthlyIncome) AS MinMonthlyIncome,
    MAX(MonthlyIncome) AS MaxMonthlyIncome
FROM GOLD.employee_analytics
GROUP BY IncomeBand
ORDER BY MIN(MonthlyIncome);
GO


/* =====================================================================
   08. CONTRÔLE DE LA DISTRIBUTION DES GROUPES D'ÂGE
===================================================================== */

SELECT
    AgeGroup,
    COUNT(*) AS EmployeeCount
FROM GOLD.employee_analytics
GROUP BY AgeGroup
ORDER BY MIN(Age);
GO


/* =====================================================================
   09. CONTRÔLE DE LA DISTRIBUTION DE L'ANCIENNETÉ
===================================================================== */

SELECT
    TenureGroup,
    COUNT(*) AS EmployeeCount
FROM GOLD.employee_analytics
GROUP BY TenureGroup
ORDER BY MIN(YearsAtCompany);
GO


/* =====================================================================
   10. VALIDATION DES FLAGS BINAIRES
===================================================================== */

SELECT
    Attrition,
    AttritionFlag,
    COUNT(*) AS EmployeeCount
FROM GOLD.employee_analytics
GROUP BY
    Attrition,
    AttritionFlag
ORDER BY AttritionFlag;
GO


SELECT
    OverTime,
    OverTimeFlag,
    COUNT(*) AS EmployeeCount
FROM GOLD.employee_analytics
GROUP BY
    OverTime,
    OverTimeFlag
ORDER BY OverTimeFlag;
GO


/* ================================================================
   TEST 02 — Unicité de EmployeeNumber
   ================================================================ */

SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT EmployeeNumber) AS UniqueEmployees
FROM GOLD.employee_analytics;

SELECT
    EmployeeNumber,
    COUNT(*) AS Nb
FROM GOLD.employee_analytics
GROUP BY EmployeeNumber
HAVING COUNT(*) > 1;


/* ================================================================
   TEST 03 — Valeurs NULL sur les variables créées
   ================================================================ */

SELECT
    SUM(CASE WHEN AgeGroup IS NULL THEN 1 ELSE 0 END) AS NullAgeGroup,
    SUM(CASE WHEN ExperienceGroup IS NULL THEN 1 ELSE 0 END) AS NullExperienceGroup,
    SUM(CASE WHEN IncomeBand IS NULL THEN 1 ELSE 0 END) AS NullIncomeBand,
    SUM(CASE WHEN TenureGroup IS NULL THEN 1 ELSE 0 END) AS NullTenureGroup,
    SUM(CASE WHEN OverTimeFlag IS NULL THEN 1 ELSE 0 END) AS NullOverTimeFlag,
    SUM(CASE WHEN AttritionFlag IS NULL THEN 1 ELSE 0 END) AS NullAttritionFlag
FROM GOLD.employee_analytics;


SELECT
    AgeGroup,
    COUNT(*) AS Employees
FROM GOLD.employee_analytics
GROUP BY AgeGroup
ORDER BY MIN(Age);

/* ================================================================
   TEST 06 — Validation de IncomeBand
   ================================================================ */

SELECT
    IncomeBand,
    COUNT(*) AS Employees,
    MIN(MonthlyIncome) AS MinIncome,
    MAX(MonthlyIncome) AS MaxIncome
FROM GOLD.employee_analytics
GROUP BY IncomeBand
ORDER BY MIN(MonthlyIncome);


SELECT 'RAW' AS Layer, COUNT(*) AS Rows
FROM RAW.employees

UNION ALL

SELECT 'PROCESSED', COUNT(*)
FROM PROCESSED.employees

UNION ALL

SELECT 'GOLD', COUNT(*)
FROM GOLD.employee_analytics;