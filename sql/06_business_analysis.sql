/* =====================================================================
   PROJET       : HR Analytics - Workforce & Employee Insights
   SCRIPT       : 006_create_gold_tables.sql
   BASE         : HR_Analytics
   SOURCE       : PROCESSED.employees
   COUCHE       : GOLD

   OBJECTIF
   ---------------------------------------------------------------------
   Créer une table analytique enrichie destinée aux analyses RH,
   aux KPI et aux visualisations Power BI.

   Cette table conserve une granularité simple :
   1 ligne = 1 employé.

   ENRICHISSEMENTS PRÉVUS
   ---------------------------------------------------------------------
   - AttritionFlag
   - OverTimeFlag
   - AgeGroup
   - IncomeBand
   - TenureGroup
   - ExperienceGroup

   Ces variables dérivées permettront de simplifier les analyses
   statistiques et les calculs de KPI.
===================================================================== */

USE HR_Analytics;
GO


/* =====================================================================
   01. CRÉATION DU SCHÉMA GOLD
   =====================================================================
   Le schéma est créé uniquement s'il n'existe pas déjà.
===================================================================== */

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'GOLD'
)
BEGIN
    EXEC('CREATE SCHEMA GOLD');
END;
GO


/* =====================================================================
   02. SUPPRESSION DE LA TABLE ANALYTIQUE SI ELLE EXISTE
===================================================================== */

DROP TABLE IF EXISTS GOLD.employee_analytics;
GO


/* =====================================================================
   03. CRÉATION DE LA TABLE GOLD.employee_analytics
   =====================================================================
   Granularité :
   Une ligne correspond à un employé.

   La table contient :
   - les variables RH nécessaires à l'analyse ;
   - plusieurs variables dérivées destinées à faciliter la segmentation
     et le calcul des KPI.
===================================================================== */

CREATE TABLE GOLD.employee_analytics
(
    /* ---------------------------------------------------------------
       IDENTIFICATION
    ---------------------------------------------------------------- */

    EmployeeNumber INT NOT NULL,


    /* ---------------------------------------------------------------
       PROFIL DÉMOGRAPHIQUE
    ---------------------------------------------------------------- */

    Age INT NOT NULL,
    AgeGroup VARCHAR(20) NOT NULL,

    Gender VARCHAR(10) NOT NULL,
    MaritalStatus VARCHAR(20) NOT NULL,


    /* ---------------------------------------------------------------
       ORGANISATION
    ---------------------------------------------------------------- */

    Department VARCHAR(50) NOT NULL,
    JobRole VARCHAR(100) NOT NULL,
    JobLevel INT NOT NULL,
    BusinessTravel VARCHAR(50) NOT NULL,


    /* ---------------------------------------------------------------
       FORMATION ET EXPÉRIENCE
    ---------------------------------------------------------------- */

    Education INT NOT NULL,
    EducationField VARCHAR(50) NOT NULL,

    TotalWorkingYears INT NOT NULL,
    ExperienceGroup VARCHAR(30) NOT NULL,

    NumCompaniesWorked INT NOT NULL,
    TrainingTimesLastYear INT NOT NULL,


    /* ---------------------------------------------------------------
       RÉMUNÉRATION
    ---------------------------------------------------------------- */

    MonthlyIncome INT NOT NULL,
    IncomeBand VARCHAR(30) NOT NULL,

    PercentSalaryHike INT NOT NULL,
    StockOptionLevel INT NOT NULL,


    /* ---------------------------------------------------------------
       SATISFACTION / ENGAGEMENT / PERFORMANCE
    ---------------------------------------------------------------- */

    EnvironmentSatisfaction INT NOT NULL,
    JobSatisfaction INT NOT NULL,
    RelationshipSatisfaction INT NOT NULL,
    WorkLifeBalance INT NOT NULL,
    JobInvolvement INT NOT NULL,
    PerformanceRating INT NOT NULL,


    /* ---------------------------------------------------------------
       CONDITIONS DE TRAVAIL
    ---------------------------------------------------------------- */

    DistanceFromHome INT NOT NULL,

    OverTime VARCHAR(10) NOT NULL,
    OverTimeFlag TINYINT NOT NULL,


    /* ---------------------------------------------------------------
       ANCIENNETÉ ET ÉVOLUTION
    ---------------------------------------------------------------- */

    YearsAtCompany INT NOT NULL,
    TenureGroup VARCHAR(30) NOT NULL,

    YearsInCurrentRole INT NOT NULL,
    YearsSinceLastPromotion INT NOT NULL,
    YearsWithCurrManager INT NOT NULL,


    /* ---------------------------------------------------------------
       ATTRITION
    ---------------------------------------------------------------- */

    Attrition VARCHAR(10) NOT NULL,
    AttritionFlag TINYINT NOT NULL,


    /* ---------------------------------------------------------------
       CONTRAINTE
    ---------------------------------------------------------------- */

    CONSTRAINT PK_gold_employee_analytics
        PRIMARY KEY (EmployeeNumber)
);
GO