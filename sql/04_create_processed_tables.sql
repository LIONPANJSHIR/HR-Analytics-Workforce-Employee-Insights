/* ====================================================================================
   PROJET       : HR Analytics - Workforce & Employee Insights
   SCRIPT       : 004_create_processed_tables.sql
   BASE         : HR_Analytics
   COUCHE       : PROCESSED

OBJECTIF
   -------------------------------------------------------------------------------------
   Crée la strucutre de la couche PROCESSED à partir des résultats obtenus
   via la Data Quality Assement sur la couche RAW

PRINCIPES DE CONCEPTON 
   -------------------------------------------------------------------------------------
    - La table Raw.employees est la table source pour la création de 
     la table Processed.employees , elle ne sera donc pas modifier 

    - Nous allons exclure les variables qui ne sont pas pertinentes pour l'analyse 
    comme:  - EmployeeCount
            - StandardHours
            - Over18
    Qui sont des variables statiques et ne sont pas pertinentes pour l'analyse de l'attrition des employés

    - Nous allons standardiser certaines variables (Nom et ou Valeurs)
    - Nous allons créer de nouvelles variables à partir des variables existantes pour faciliter l'analyse

*/


USE HR_analytics;
GO

/*==========================================================
Q1. CREATION DE LA TABLE PROCESSED 
===========================================================*/

DROP TABLE IF EXISTS PROCESSED.employees ;
GO
CREATE TABLE PROCESSED.employees
(
    /* ---------------------------------------------------------------
       IDENTIFICATION
    ---------------------------------------------------------------- */

    EmployeeNumber INT NOT NULL,


    /* ---------------------------------------------------------------
       INFORMATIONS DÉMOGRAPHIQUES
    ---------------------------------------------------------------- */

    Age INT NOT NULL,
    Gender VARCHAR(10) NOT NULL,
    MaritalStatus VARCHAR(20) NOT NULL,


    /* ---------------------------------------------------------------
       STRUCTURE ORGANISATIONNELLE
    ---------------------------------------------------------------- */

    Department VARCHAR(50) NOT NULL,
    JobRole VARCHAR(100) NOT NULL,
    JobLevel INT NOT NULL,
    BusinessTravel VARCHAR(50) NOT NULL,


    /* ---------------------------------------------------------------
       FORMATION / PARCOURS
    ---------------------------------------------------------------- */

    Education INT NOT NULL,
    EducationField VARCHAR(50) NOT NULL,
    TotalWorkingYears INT NOT NULL,
    NumCompaniesWorked INT NOT NULL,
    TrainingTimesLastYear INT NOT NULL,


    /* ---------------------------------------------------------------
       RÉMUNÉRATION ET AVANTAGES
    ---------------------------------------------------------------- */

    MonthlyIncome INT NOT NULL,
    PercentSalaryHike INT NOT NULL,
    StockOptionLevel INT NOT NULL,

    HourlyRate INT NOT NULL,
    DailyRate INT NOT NULL,
    MonthlyRate INT NOT NULL,


    /* ---------------------------------------------------------------
       ENGAGEMENT / SATISFACTION / PERFORMANCE
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


    /* ---------------------------------------------------------------
       ANCIENNETÉ ET ÉVOLUTION
    ---------------------------------------------------------------- */

    YearsAtCompany INT NOT NULL,
    YearsInCurrentRole INT NOT NULL,
    YearsSinceLastPromotion INT NOT NULL,
    YearsWithCurrManager INT NOT NULL,


    /* ---------------------------------------------------------------
       VARIABLE CIBLE
    ---------------------------------------------------------------- */

    Attrition VARCHAR(10) NOT NULL,


    /* ---------------------------------------------------------------
       CONTRAINTE D'UNICITÉ
    ---------------------------------------------------------------- */

    CONSTRAINT PK_processed_employees
        PRIMARY KEY (EmployeeNumber)
);
GO
