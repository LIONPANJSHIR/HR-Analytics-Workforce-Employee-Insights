/* =====================================================================
   PROJET       : HR Analytics - Workforce & Employee Insights
   SCRIPT       : 005_transform_processed.sql
   BASE         : HR_Analytics
   SOURCE       : RAW.employees
   CIBLE        : PROCESSED.employees

   OBJECTIF
   ---------------------------------------------------------------------
   Alimenter la couche PROCESSED à partir des données RAW en appliquant
   les transformations nécessaires à l'analyse.

===================================================================== */

USE HR_Analytics;
GO


/* =====================================================================
   01. RÉINITIALISATION DE LA TABLE CIBLE
   =====================================================================
   La table PROCESSED.employees est vidée avant rechargement afin
   d'éviter les doublons en cas de réexécution du script.
===================================================================== */

TRUNCATE TABLE PROCESSED.employees;
GO


/* =====================================================================
   02. CHARGEMENT ET TRANSFORMATION DES DONNÉES
===================================================================== */

INSERT INTO PROCESSED.employees
(
    EmployeeNumber,
    Age,
    Gender,
    MaritalStatus,
    Department,
    JobRole,
    JobLevel,
    BusinessTravel,
    Education,
    EducationField,
    TotalWorkingYears,
    NumCompaniesWorked,
    TrainingTimesLastYear,
    MonthlyIncome,
    PercentSalaryHike,
    StockOptionLevel,
    HourlyRate,
    DailyRate,
    MonthlyRate,
    EnvironmentSatisfaction,
    JobSatisfaction,
    RelationshipSatisfaction,
    WorkLifeBalance,
    JobInvolvement,
    PerformanceRating,
    DistanceFromHome,
    OverTime,
    YearsAtCompany,
    YearsInCurrentRole,
    YearsSinceLastPromotion,
    YearsWithCurrManager,
    Attrition
)
SELECT
    EmployeeNumber,

    Age,

    TRIM(Gender) AS Gender,

    TRIM(MaritalStatus) AS MaritalStatus,

    TRIM(Department) AS Department,

    TRIM(JobRole) AS JobRole,

    JobLevel,

    TRIM(BusinessTravel) AS BusinessTravel,

    Education,

    TRIM(EducationField) AS EducationField,

    TotalWorkingYears,

    NumCompaniesWorked,

    TrainingTimesLastYear,

    MonthlyIncome,

    PercentSalaryHike,

    StockOptionLevel,

    HourlyRate,

    DailyRate,

    MonthlyRate,

    EnvironmentSatisfaction,

    JobSatisfaction,

    RelationshipSatisfaction,

    WorkLifeBalance,

    JobInvolvement,

    PerformanceRating,

    DistanceFromHome,

    TRIM(OverTime) AS OverTime,

    YearsAtCompany,

    YearsInCurrentRole,

    YearsSinceLastPromotion,

    YearsWithCurrManager,

    TRIM(Attrition) AS Attrition

FROM RAW.employees;
GO