/* =====================================================================
   PROJET       : HR Analytics - Workforce & Employee Insights
   SCRIPT       : 003_data_quality.sql
   BASE         : HR_Analytics
   TABLE SOURCE : RAW.employees

   OBJECTIF
   ---------------------------------------------------------------------
   Évaluer la qualité et la fiabilité des données RH brutes avant leur
   transformation et leur intégration dans la couche PROCESSED.

   DIMENSIONS DE QUALITÉ ÉVALUÉES
   ---------------------------------------------------------------------
   1. Complétude   - Détection des valeurs manquantes
   2. Unicité      - Vérification de l'unicité des employés
   3. Validité     - Contrôle des domaines et plages de valeurs
   4. Cardinalité  - Identification des variables constantes
   5. Cohérence    - Validation des relations logiques entre variables

   REMARQUE
   ---------------------------------------------------------------------
   Ce script réalise uniquement des contrôles de qualité.
   Aucune donnée de la couche RAW n'est modifiée.
===================================================================== */

USE HR_Analytics;
GO


/* =====================================================================
   01. VUE D'ENSEMBLE DU DATASET
   =====================================================================
   Objectif :
   Vérifier que le chargement des données a été effectué correctement
   et établir le nombre de lignes de référence.

   Résultat attendu :
   1 470 employés.
===================================================================== */

SELECT
    COUNT(*) AS TotalRows
FROM RAW.employees;
GO

-- Résultat : 1 470 observations chargées.


/* =====================================================================
   02. CONTRÔLE D'UNICITÉ
   =====================================================================
   Règle métier :
   EmployeeNumber doit identifier de manière unique chaque employé.

   Toute ligne retournée par la requête suivante indique la présence
   d'un identifiant employé dupliqué.
===================================================================== */

SELECT
    EmployeeNumber,
    COUNT(*) AS DuplicateCount
FROM RAW.employees
GROUP BY EmployeeNumber
HAVING COUNT(*) > 1;
GO

-- Résultat : aucun EmployeeNumber dupliqué détecté.


SELECT
    COUNT(DISTINCT EmployeeNumber) AS DistinctEmployeeCount
FROM RAW.employees;
GO

/*
Résultat :
1 470 identifiants distincts pour 1 470 observations.

Conclusion :
EmployeeNumber respecte la contrainte d'unicité attendue.
*/


/* =====================================================================
   03. CONTRÔLE DE COMPLÉTUDE
   =====================================================================
   Objectif :
   Identifier les valeurs NULL dans les variables considérées comme
   critiques pour l'analyse des effectifs et de l'attrition.
===================================================================== */

SELECT
    SUM(CASE WHEN EmployeeNumber IS NULL THEN 1 ELSE 0 END)
        AS NullEmployeeNumber,

    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END)
        AS NullAge,

    SUM(CASE WHEN Department IS NULL THEN 1 ELSE 0 END)
        AS NullDepartment,

    SUM(CASE WHEN JobRole IS NULL THEN 1 ELSE 0 END)
        AS NullJobRole,

    SUM(CASE WHEN MonthlyIncome IS NULL THEN 1 ELSE 0 END)
        AS NullMonthlyIncome,

    SUM(CASE WHEN YearsAtCompany IS NULL THEN 1 ELSE 0 END)
        AS NullYearsAtCompany,

    SUM(CASE WHEN PerformanceRating IS NULL THEN 1 ELSE 0 END)
        AS NullPerformanceRating,

    SUM(CASE WHEN JobSatisfaction IS NULL THEN 1 ELSE 0 END)
        AS NullJobSatisfaction,

    SUM(CASE WHEN OverTime IS NULL THEN 1 ELSE 0 END)
        AS NullOverTime,

    SUM(CASE WHEN Attrition IS NULL THEN 1 ELSE 0 END)
        AS NullAttrition

FROM RAW.employees;
GO

/*
Résultat :
Aucune valeur NULL détectée dans les variables RH critiques.

Conclusion :
Les variables essentielles satisfont le critère de complétude.
*/


/* =====================================================================
   04. VALIDITÉ DES VARIABLES CATÉGORIELLES
   =====================================================================
   Objectif :
   Examiner les modalités présentes dans les variables catégorielles.

   Ces contrôles permettent notamment d'identifier :
   - des catégories inattendues ;
   - des différences d'orthographe ;
   - des problèmes de casse ou d'espaces ;
   - des valeurs vides ou inconnues.
===================================================================== */

-- Répartition des employés par département
SELECT
    Department,
    COUNT(*) AS EmployeeCount
FROM RAW.employees
GROUP BY Department
ORDER BY Department;
GO


-- Répartition par poste
SELECT
    JobRole,
    COUNT(*) AS EmployeeCount
FROM RAW.employees
GROUP BY JobRole
ORDER BY JobRole;
GO


-- Répartition de l'attrition
SELECT
    Attrition,
    COUNT(*) AS EmployeeCount
FROM RAW.employees
GROUP BY Attrition
ORDER BY Attrition;
GO


-- Répartition par genre
SELECT
    Gender,
    COUNT(*) AS EmployeeCount
FROM RAW.employees
GROUP BY Gender
ORDER BY Gender;
GO


-- Répartition par statut marital
SELECT
    MaritalStatus,
    COUNT(*) AS EmployeeCount
FROM RAW.employees
GROUP BY MaritalStatus
ORDER BY MaritalStatus;
GO


-- Répartition selon la fréquence des déplacements professionnels
SELECT
    BusinessTravel,
    COUNT(*) AS EmployeeCount
FROM RAW.employees
GROUP BY BusinessTravel
ORDER BY BusinessTravel;
GO


-- Répartition des heures supplémentaires
SELECT
    OverTime,
    COUNT(*) AS EmployeeCount
FROM RAW.employees
GROUP BY OverTime
ORDER BY OverTime;
GO


-- Contrôle de la variable Over18
SELECT
    Over18,
    COUNT(*) AS EmployeeCount
FROM RAW.employees
GROUP BY Over18
ORDER BY Over18;
GO

/*
Résultat :
Aucune modalité catégorielle manifestement invalide n'a été détectée.

Remarque :
Over18 ne contient qu'une seule modalité. Cette variable sera donc
réévaluée lors du contrôle de cardinalité.
*/


/* =====================================================================
   05. VALIDITÉ DES PRINCIPALES VARIABLES NUMÉRIQUES
   =====================================================================
   Objectif :
   Examiner les valeurs minimales et maximales des principales
   variables numériques afin d'identifier d'éventuelles valeurs
   impossibles ou incohérentes.
===================================================================== */

SELECT
    MIN(Age)               AS MinAge,
    MAX(Age)               AS MaxAge,
    MIN(MonthlyIncome)     AS MinMonthlyIncome,
    MAX(MonthlyIncome)     AS MaxMonthlyIncome,
    MIN(YearsAtCompany)    AS MinYearsAtCompany,
    MAX(YearsAtCompany)    AS MaxYearsAtCompany,
    MIN(PerformanceRating) AS MinPerformanceRating,
    MAX(PerformanceRating) AS MaxPerformanceRating,
    MIN(JobSatisfaction)   AS MinJobSatisfaction,
    MAX(JobSatisfaction)   AS MaxJobSatisfaction
FROM RAW.employees;
GO

/*
Plages observées :
- Age               : 18 à 60 ans
- MonthlyIncome     : 1 009 à 19 999
- YearsAtCompany    : 0 à 40 ans
- PerformanceRating : 3 à 4
- JobSatisfaction   : 1 à 4

Conclusion :
Aucune valeur manifestement invalide n'a été détectée.

Point d'attention :
PerformanceRating présente une faible variabilité puisque seuls les
niveaux 3 et 4 sont observés. Il ne s'agit pas nécessairement d'un
problème de qualité, mais cette caractéristique devra être prise en
compte lors de l'analyse exploratoire.
*/


/* =====================================================================
   06. DISTRIBUTION DES VARIABLES ORDINALES PRINCIPALES
===================================================================== */

SELECT
    PerformanceRating,
    COUNT(*) AS EmployeeCount
FROM RAW.employees
GROUP BY PerformanceRating
ORDER BY PerformanceRating;
GO


SELECT
    JobSatisfaction,
    COUNT(*) AS EmployeeCount
FROM RAW.employees
GROUP BY JobSatisfaction
ORDER BY JobSatisfaction;
GO


/* =====================================================================
   07. CONTRÔLES COMPLÉMENTAIRES DE VALIDITÉ NUMÉRIQUE
   =====================================================================
   Principe :
   Toute observation retournée par une requête de contrôle représente
   une anomalie potentielle nécessitant une investigation.
===================================================================== */


/* ---------------------------------------------------------------------
   07.1 Distance domicile-travail

   Règle :
   DistanceFromHome doit être positive ou nulle.
--------------------------------------------------------------------- */

SELECT
    MIN(DistanceFromHome) AS MinDistanceFromHome,
    MAX(DistanceFromHome) AS MaxDistanceFromHome
FROM RAW.employees;

SELECT
    EmployeeNumber,
    DistanceFromHome
FROM RAW.employees
WHERE DistanceFromHome < 0;
GO


/* ---------------------------------------------------------------------
   07.2 Expérience professionnelle totale

   Règle :
   TotalWorkingYears ne peut pas être négatif.
--------------------------------------------------------------------- */

SELECT
    MIN(TotalWorkingYears) AS MinTotalWorkingYears,
    MAX(TotalWorkingYears) AS MaxTotalWorkingYears
FROM RAW.employees;

SELECT
    EmployeeNumber,
    TotalWorkingYears
FROM RAW.employees
WHERE TotalWorkingYears < 0;
GO


/* ---------------------------------------------------------------------
   07.3 Ancienneté dans le poste actuel
--------------------------------------------------------------------- */

SELECT
    MIN(YearsInCurrentRole) AS MinYearsInCurrentRole,
    MAX(YearsInCurrentRole) AS MaxYearsInCurrentRole
FROM RAW.employees;

SELECT
    EmployeeNumber,
    YearsInCurrentRole
FROM RAW.employees
WHERE YearsInCurrentRole < 0;
GO


/* ---------------------------------------------------------------------
   07.4 Nombre d'années depuis la dernière promotion
--------------------------------------------------------------------- */

SELECT
    MIN(YearsSinceLastPromotion) AS MinYearsSinceLastPromotion,
    MAX(YearsSinceLastPromotion) AS MaxYearsSinceLastPromotion
FROM RAW.employees;

SELECT
    EmployeeNumber,
    YearsSinceLastPromotion
FROM RAW.employees
WHERE YearsSinceLastPromotion < 0;
GO


/* ---------------------------------------------------------------------
   07.5 Ancienneté avec le manager actuel
--------------------------------------------------------------------- */

SELECT
    MIN(YearsWithCurrManager) AS MinYearsWithCurrManager,
    MAX(YearsWithCurrManager) AS MaxYearsWithCurrManager
FROM RAW.employees;

SELECT
    EmployeeNumber,
    YearsWithCurrManager
FROM RAW.employees
WHERE YearsWithCurrManager < 0;
GO


/* ---------------------------------------------------------------------
   07.6 Nombre d'entreprises précédemment fréquentées
--------------------------------------------------------------------- */

SELECT
    MIN(NumCompaniesWorked) AS MinCompaniesWorked,
    MAX(NumCompaniesWorked) AS MaxCompaniesWorked
FROM RAW.employees;

SELECT
    EmployeeNumber,
    NumCompaniesWorked
FROM RAW.employees
WHERE NumCompaniesWorked < 0;
GO


/* ---------------------------------------------------------------------
   07.7 Nombre de formations suivies durant l'année précédente
--------------------------------------------------------------------- */

SELECT
    MIN(TrainingTimesLastYear) AS MinTrainingTimes,
    MAX(TrainingTimesLastYear) AS MaxTrainingTimes
FROM RAW.employees;

SELECT
    EmployeeNumber,
    TrainingTimesLastYear
FROM RAW.employees
WHERE TrainingTimesLastYear < 0;
GO


/* ---------------------------------------------------------------------
   07.8 Pourcentage d'augmentation salariale

   Règle :
   PercentSalaryHike doit appartenir à l'intervalle [0 ; 100].
--------------------------------------------------------------------- */

SELECT
    MIN(PercentSalaryHike) AS MinSalaryHike,
    MAX(PercentSalaryHike) AS MaxSalaryHike
FROM RAW.employees;

SELECT
    EmployeeNumber,
    PercentSalaryHike
FROM RAW.employees
WHERE PercentSalaryHike NOT BETWEEN 0 AND 100;
GO


/* =====================================================================
   08. VALIDITÉ DES ÉCHELLES ORDINALES
   =====================================================================
   Objectif :
   Vérifier que les scores RH respectent les domaines attendus.
===================================================================== */

-- Échelle attendue : 1 à 4
SELECT *
FROM RAW.employees
WHERE EnvironmentSatisfaction NOT BETWEEN 1 AND 4;
GO

-- Échelle attendue : 1 à 4
SELECT *
FROM RAW.employees
WHERE RelationshipSatisfaction NOT BETWEEN 1 AND 4;
GO

-- Échelle attendue : 1 à 4
SELECT *
FROM RAW.employees
WHERE WorkLifeBalance NOT BETWEEN 1 AND 4;
GO

-- Échelle attendue : 1 à 4
SELECT *
FROM RAW.employees
WHERE JobInvolvement NOT BETWEEN 1 AND 4;
GO

-- Échelle attendue : 1 à 5
SELECT *
FROM RAW.employees
WHERE Education NOT BETWEEN 1 AND 5;
GO

-- Échelle attendue : 1 à 5
SELECT *
FROM RAW.employees
WHERE JobLevel NOT BETWEEN 1 AND 5;
GO

-- Échelle attendue : 0 à 3
SELECT *
FROM RAW.employees
WHERE StockOptionLevel NOT BETWEEN 0 AND 3;
GO

/*
Résultat :
Aucune observation située en dehors des domaines attendus
n'a été détectée.
*/


/* =====================================================================
   09. CONTRÔLE DES VARIABLES DE TAUX
   =====================================================================
   Objectif :
   Détecter d'éventuelles valeurs négatives impossibles.

   Remarque :
   HourlyRate, DailyRate et MonthlyRate sont contrôlées indépendamment.
   Aucune relation directe avec MonthlyIncome n'est supposée.
===================================================================== */

SELECT
    MIN(HourlyRate)  AS MinHourlyRate,
    MAX(HourlyRate)  AS MaxHourlyRate,
    MIN(DailyRate)   AS MinDailyRate,
    MAX(DailyRate)   AS MaxDailyRate,
    MIN(MonthlyRate) AS MinMonthlyRate,
    MAX(MonthlyRate) AS MaxMonthlyRate
FROM RAW.employees;
GO

SELECT
    EmployeeNumber,
    HourlyRate,
    DailyRate,
    MonthlyRate
FROM RAW.employees
WHERE HourlyRate < 0
   OR DailyRate < 0
   OR MonthlyRate < 0;
GO

/*
Plages observées :
- HourlyRate  : 30 à 100
- DailyRate   : 102 à 1 499
- MonthlyRate : 2 094 à 26 999

Conclusion :
Aucune valeur négative détectée.
*/


/* =====================================================================
   10. CONTRÔLE DE CARDINALITÉ
   =====================================================================
   Objectif :
   Identifier les variables constantes ou n'apportant aucune capacité
   de différenciation entre les employés.
===================================================================== */

SELECT
    COUNT(DISTINCT EmployeeCount) AS EmployeeCountDistinctValues,
    COUNT(DISTINCT StandardHours) AS StandardHoursDistinctValues,
    COUNT(DISTINCT Over18)        AS Over18DistinctValues
FROM RAW.employees;
GO

/*
Résultat :
- EmployeeCount : 1 valeur distincte
- StandardHours : 1 valeur distincte
- Over18        : 1 valeur distincte

Conclusion :
Ces trois variables sont constantes sur l'ensemble du dataset.
Elles n'apportent donc aucune information discriminante pour
l'analyse RH.

Décision :
- Conservation dans RAW.employees afin de préserver la source originale.
- Exclusion recommandée de la couche analytique PROCESSED.
*/


/* =====================================================================
   11. CONTRÔLES DE COHÉRENCE INTER-VARIABLES
   =====================================================================
   Objectif :
   Vérifier la cohérence logique entre différentes variables temporelles
   décrivant l'expérience professionnelle et l'ancienneté.

   Principe :
   Une requête retournant zéro ligne signifie que la règle métier
   testée est respectée pour l'ensemble des employés.
===================================================================== */


/* ---------------------------------------------------------------------
   RÈGLE 11.1 - Ancienneté vs expérience totale

   L'ancienneté dans l'entreprise ne peut pas être supérieure à
   l'expérience professionnelle totale.

   Attendu :
   YearsAtCompany <= TotalWorkingYears
--------------------------------------------------------------------- */

SELECT
    EmployeeNumber,
    TotalWorkingYears,
    YearsAtCompany
FROM RAW.employees
WHERE YearsAtCompany > TotalWorkingYears;
GO

-- Résultat : aucune incohérence détectée.


/* ---------------------------------------------------------------------
   RÈGLE 11.2 - Ancienneté dans le poste

   La durée passée dans le poste actuel ne peut pas être supérieure
   à l'ancienneté totale dans l'entreprise.

   Attendu :
   YearsInCurrentRole <= YearsAtCompany
--------------------------------------------------------------------- */

SELECT
    EmployeeNumber,
    YearsAtCompany,
    YearsInCurrentRole
FROM RAW.employees
WHERE YearsInCurrentRole > YearsAtCompany;
GO

-- Résultat : aucune incohérence détectée.


/* ---------------------------------------------------------------------
   RÈGLE 11.3 - Dernière promotion

   Le nombre d'années écoulées depuis la dernière promotion ne peut
   pas être supérieur à l'ancienneté totale dans l'entreprise.

   Attendu :
   YearsSinceLastPromotion <= YearsAtCompany
--------------------------------------------------------------------- */

SELECT
    EmployeeNumber,
    YearsAtCompany,
    YearsSinceLastPromotion
FROM RAW.employees
WHERE YearsSinceLastPromotion > YearsAtCompany;
GO

-- Résultat : aucune incohérence détectée.


/* ---------------------------------------------------------------------
   RÈGLE 11.4 - Ancienneté avec le manager actuel

   La durée passée avec le manager actuel ne peut pas dépasser
   l'ancienneté totale dans l'entreprise.

   Attendu :
   YearsWithCurrManager <= YearsAtCompany
--------------------------------------------------------------------- */

SELECT
    EmployeeNumber,
    YearsAtCompany,
    YearsWithCurrManager
FROM RAW.employees
WHERE YearsWithCurrManager > YearsAtCompany;
GO

-- Résultat : aucune incohérence détectée.


/* ---------------------------------------------------------------------
   RÈGLE 11.5 - Expérience professionnelle vs âge

   Hypothèse :
   Pour ce contrôle, l'âge minimal plausible de début d'une activité
   professionnelle est fixé à 16 ans.

   Attendu :
   TotalWorkingYears <= Age - 16

   Attention :
   Il s'agit d'une hypothèse analytique et non d'une contrainte stricte
   issue du système source.
--------------------------------------------------------------------- */

SELECT
    EmployeeNumber,
    Age,
    TotalWorkingYears
FROM RAW.employees
WHERE TotalWorkingYears > Age - 16;
GO

-- Résultat : aucune incohérence détectée.


/* =====================================================================
   12. SYNTHÈSE DU DATA QUALITY ASSESSMENT
   =====================================================================

   COMPLÉTUDE
   OK - Aucune valeur manquante détectée dans les variables critiques.

   UNICITÉ
   OK - Les 1 470 observations possèdent un EmployeeNumber unique.

   VALIDITÉ
   OK - Aucune valeur hors des domaines et plages définis n'a été
        identifiée lors des contrôles.

   COHÉRENCE
   OK - Aucune incohérence logique détectée entre les variables
        temporelles testées.

   CARDINALITÉ
   À TRAITER - EmployeeCount, StandardHours et Over18 sont constantes
               et n'apportent aucune information analytique.

   EXACTITUDE / ACCURACY
   NON ÉVALUÉE - Impossible à vérifier sans disposer d'une source RH
                 externe faisant autorité.

   ACTUALITÉ / TIMELINESS
   NON ÉVALUÉE - Le dataset est considéré comme un snapshot statique.

   ---------------------------------------------------------------------
   CONCLUSION GÉNÉRALE

   Les données de la couche RAW présentent un niveau satisfaisant de
   complétude, d'unicité, de validité et de cohérence interne selon les
   règles de qualité implémentées.

   Le dataset peut être utilisé pour alimenter la couche PROCESSED.

   RECOMMANDATIONS POUR LA COUCHE PROCESSED

   1. Préserver RAW.employees sans modification afin de conserver
      une copie fidèle de la source.

   2. Exclure les variables constantes :
      - EmployeeCount
      - StandardHours
      - Over18

   3. Standardiser les variables catégorielles si nécessaire.

   4. Enrichir les données avec des variables dérivées pertinentes
      pour l'analyse RH et l'étude de l'attrition.
===================================================================== */