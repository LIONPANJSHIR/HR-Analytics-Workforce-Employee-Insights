/* =====================================================================
   PROJET       : HR Analytics - Workforce & Employee Insights
   SCRIPT       : 008_business_analysis.sql
   BASE         : HR_Analytics
   SOURCE       : GOLD.employee_analytics

   OBJECTIF
   ---------------------------------------------------------------------
   Réaliser l'analyse métier de l'attrition et identifier les principaux
   facteurs associés aux départs des collaborateurs.

   STRUCTURE DE L'ANALYSE
   ---------------------------------------------------------------------
   01. Workforce Overview
   02. Attrition Segmentation
   03. Working Conditions
   04. Satisfaction & Engagement
   05. Compensation
   06. Career & Tenure
   07. Multi-factor Analysis
   08. Key Findings
===================================================================== */

USE HR_Analytics;
GO


/* =====================================================================
   01. WORKFORCE OVERVIEW
===================================================================== */


/* ---------------------------------------------------------------------
   01.1 KPI principaux
   ---------------------------------------------------------------------
   Objectif :
   Obtenir une vue globale de l'effectif et de l'attrition.
--------------------------------------------------------------------- */

SELECT
    COUNT(*) AS TotalEmployees,

    SUM(AttritionFlag) AS EmployeesLeft,

    COUNT(*) - SUM(AttritionFlag) AS EmployeesStayed,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics;
GO

/*--------------------------------------------------------------------------
                       1.2  PROFIL DEMOGRAPHIQUE
--------------------------------------------------------------------------*/
SELECT 
AgeGroup ,
Effectifs ,
CAST(
    100 * Effectifs / SUM(Effectifs) OVER()
     AS DECIMAL(5,2)
     ) AS WorforcePct
FROM
(
    SELECT 
    AgeGroup,
    COUNT(*) AS Effectifs 
    FROM GOLD.employee_analytics
    GROUP BY AgeGroup
)  As AgeDistribution
Order By 
    CASE AgeGroup
        WHEN '18-24' THEN 1
        WHEN '25-34' THEN 2
        WHEN '35-44' THEN 3
        WHEN '45-54' THEN 4
        ELSE 5
        
END ASC;

SELECT 
Attrition,
AVG(Age) AS AverageAge ,
MIN(Age) AS MinAge ,
MAX(Age) AS MaxAge 
FROM GOLD.employee_analytics
GROUP BY Attrition ;

GO 

SELECT 
Gender , 
COUNT(*) AS Effectifs
FROM GOLD.employee_analytics
GROUP BY Gender ;

SELECT 
MaritalStatus , 
COUNT(*) AS Effectifs
FROM GOLD.employee_analytics
GROUP BY MaritalStatus ;

/* ---------------------------------------------------------------------
   01.3 Rémunération globale
--------------------------------------------------------------------- */

SELECT
    CAST(
        AVG(CAST(MonthlyIncome AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS AverageMonthlyIncome,

    MIN(MonthlyIncome) AS MinMonthlyIncome,

    MAX(MonthlyIncome) AS MaxMonthlyIncome

FROM GOLD.employee_analytics;
GO

/* ---------------------------------------------------------------------
   01.4 Revenu médian
--------------------------------------------------------------------- */

SELECT DISTINCT

    CAST(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY MonthlyIncome
        )
        OVER ()
        AS DECIMAL(10,2)
    ) AS MedianMonthlyIncome

FROM GOLD.employee_analytics;
GO

/* ---------------------------------------------------------------------
   01.5 Ancienneté dans l'entreprise
--------------------------------------------------------------------- */

SELECT
    CAST(
        AVG(CAST(YearsAtCompany AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS AverageYearsAtCompany,

    MIN(YearsAtCompany) AS MinYearsAtCompany,

    MAX(YearsAtCompany) AS MaxYearsAtCompany

FROM GOLD.employee_analytics;
GO

/* ---------------------------------------------------------------------
   01.6 Ancienneté médiane
--------------------------------------------------------------------- */

SELECT DISTINCT

    CAST(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY YearsAtCompany
        )
        OVER ()
        AS DECIMAL(10,2)
    ) AS MedianYearsAtCompany

FROM GOLD.employee_analytics;
GO

/* ---------------------------------------------------------------------
   01.7 Part des employés réalisant des heures supplémentaires
--------------------------------------------------------------------- */

SELECT 
COUNT(*) AS TotalEmployee , 
SUM(OverTimeFlag) As EmployeeWithOverTime ,
CAST (
    100 * SUM(OverTimeFlag) / COUNt(*)
    AS DECIMAL (5,2)
) AS OvertimeRatePct
FROM GOLD.employee_analytics

/* ---------------------------------------------------------------------
   01.8 STRUCTURE ORGANISATIONNELLE
--------------------------------------------------------------------- */

SELECT
    Department,
    COUNT(*) AS Effectifs,

    CAST(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()
        AS DECIMAL(5,2)
    ) AS EmployeeInDepartmentRatePct

FROM GOLD.employee_analytics

GROUP BY Department

ORDER BY EmployeeInDepartmentRatePct DESC;

/* ---------------------------------------------------------------------
   01.9 Répartition des effectifs par métier
--------------------------------------------------------------------- */

SELECT
    JobRole,

    COUNT(*) AS EmployeeCount,

    CAST(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER ()
        AS DECIMAL(5,2)
    ) AS WorkforceSharePct

FROM GOLD.employee_analytics

GROUP BY JobRole

ORDER BY EmployeeCount DESC;
GO


-- SELECT 
-- AVG(JobSatisfaction)
-- FROM GOLD.employee_analytics
-- GROUP BY JobSatisfaction


-- SELECT 
-- Attrition,
-- AVG(YearsAtCompany)
-- FROM GOLD.employee_analytics
-- GROUP BY Attrition$
-- SELECT 
-- YearsAtCompany,
-- COUNT(YearsAtCompany)
-- FROM GOLD.employee_analytics 
-- GROUP BY YearsAtCompany ;


/*-----------------------------------------------------------------------------------------------
                        02. Attrition  Segmentation

Obkectif :
Identifier les populations présentant le taux d'attrition les plus élevés .

Benchmark entreprise :
Taux global d'attrition = 16.12%
-----------------------------------------------------------------------------------------------*/

/*----------------------------------------------
2.1 Attrition par tranche d'age
-----------------------------------------------*/

SELECT 
AgeGroup,
COUNT(*) AS TotalEmployees,
SUM(AttritionFlag) AS EmployeesLeft,
COUNT(*) -SUM(AttritionFlag) AS EmployeesStayed,
CAST (
    100.0 * SUM(AttritionFlag) / COUNT(*) 
    AS DECIMAL (5,2)
) AS AttritionRatePct
FROM GOLD.employee_analytics
GROUP BY AgeGroup 
ORDER BY AttritionRatePct DESC ;
GO

-- L'attrition est particulièrement élevée chez les 18-24 ans,
-- avec un taux proche de 40 %. Les jeunes collaborateurs apparaissent
-- ainsi comme une population particulièrement exposée au départ.
-- Cependant la taille de l'effectifs reste toutefois moins important par rapport aux employées
-- Agé entre 25-34 ans

/*----------------------------------------------
2.2 Attrition Selon le département de l'employé
-----------------------------------------------*/

SELECT 
Department,
COUNT(*) AS TotalEmployees,
SUM(AttritionFlag) AS EmployeesLeft,
COUNT(*) -SUM(AttritionFlag) AS EmployeesStayed,
CAST (
    100.0 * SUM(AttritionFlag) / COUNT(*) 
    AS DECIMAL (5,2)
) AS AttritionRatePct
FROM GOLD.employee_analytics
GROUP BY Department 
ORDER BY AttritionRatePct DESC ;
GO

-- Le département Sales présente le taux d'attrition le plus élevé,
-- avec environ 20 % de ses effectifs ayant quitté l'entreprise.
-- Il est suivi par Human Resources (~19 %), puis Research & Development.

-- Toutefois, le taux d'attrition doit être mis en perspective avec la taille
-- des départements. Sales et R&D concentrent une part importante des effectifs
-- de l'entreprise et constituent donc des populations prioritaires à approfondir
-- dans l'analyse des facteurs associés aux départs.

/* ---------------------------------------------------------------------
   02.3 Attrition par métier
--------------------------------------------------------------------- */

SELECT
    JobRole,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    COUNT(*) - SUM(AttritionFlag) AS EmployeesStayed,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY JobRole

ORDER BY AttritionRatePct DESC;
GO

-- Les Sales Representatives présentent le taux d'attrition le plus élevé,
-- avec près de 40 % des employés de ce métier ayant quitté l'entreprise.

-- Les Laboratory Technicians arrivent en deuxième position, avec un taux
-- d'attrition proche de 24 %. Toutefois, en volume, ils enregistrent le
-- plus grand nombre de départs : 62 employés, contre 33 chez les
-- Sales Representatives.

-- Ces résultats font apparaître deux problématiques distinctes :
-- les Sales Representatives présentent le risque relatif de départ le plus
-- élevé, tandis que les Laboratory Technicians représentent le plus fort
-- volume de départs.


SELECT
    JobLevel,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    COUNT(*) - SUM(AttritionFlag) AS EmployeesStayed,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY JobLevel

ORDER BY AttritionRatePct DESC;
GO



/* ---------------------------------------------------------------------
   02.5 Attrition par genre
--------------------------------------------------------------------- */

SELECT
    Gender,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY Gender

ORDER BY AttritionRatePct DESC;
GO


/* ---------------------------------------------------------------------
   02.6 Attrition par situation familiale
--------------------------------------------------------------------- */

SELECT
    MaritalStatus,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY MaritalStatus

ORDER BY AttritionRatePct DESC;
GO


/* ---------------------------------------------------------------------
   02.7 Attrition par ancienneté
--------------------------------------------------------------------- */

SELECT
    TenureGroup,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY TenureGroup

ORDER BY
    MIN(YearsAtCompany);
GO


/* ---------------------------------------------------------------------
   02.8 Attrition par niveau de revenu
--------------------------------------------------------------------- */

SELECT
    IncomeBand,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY IncomeBand

ORDER BY
    MIN(MonthlyIncome);
GO


/* ---------------------------------------------------------------------
   02.9 Attrition par expérience professionnelle
--------------------------------------------------------------------- */

SELECT
    ExperienceGroup,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY ExperienceGroup

ORDER BY
    MIN(TotalWorkingYears);
GO



/* =====================================================================
   03. WORKING CONDITIONS

Objectif : 
            Etudier la relation entre les conditions de travail 
            et l'attrition des collaborateurs .
===================================================================== */


/* ---------------------------------------------------------------------
   3.1 Attrition selons les heures sup
--------------------------------------------------------------------- */

SELECT 
Overtime  ,
COUNT(*) AS TotalEmployees,
SUM(AttritionFlag) AS EmployeesLeft,
COUNT(*) - SUM(AttritionFlag) AS EmployeesStayed ,
CAST(100.0 * SUM(AttritionFlag) / COUNT(*) 
    AS DECIMAL (5,2)
    ) AS AttritionRatePct
FROM GOLD.employee_analytics
GROUP BY OverTime
ORDER BY AttritionRatePct DESC;
GO

SELECT 
CAST (100.0 * 127 / (127 +110) AS DECIMAL (5,2))

SELECT 
CAST (100.0 * 416 / 1470 AS DECIMAL (5,2))

-- L’Overtime apparaît fortement associé à l’attrition :
--  30,5 % des salariés effectuant des heures supplémentaires quittent l’entreprise, 
--  contre 10,4 % parmi ceux qui n’en effectuent pas, soit un risque d’attrition environ 2,9 fois supérieur (+20,1 points).
--  28.3 % des salariés concentrent 53.6 des départs





/* ---------------------------------------------------------------------
   03.2  ATTRITION SELON LA FREQ DES DEPLACEMENT PRO
--------------------------------------------------------------------- */
SELECT
    BusinessTravel,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    COUNT(*) - SUM(AttritionFlag) AS EmployeesStayed,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY BusinessTravel

ORDER BY AttritionRatePct DESC;
GO
-- SELECT 
-- 24.91 /8.00,
-- 24.91/14.96

-- Une tendance se dessine : on remarque que plus les collaborateurs sont soumis à des déplacements
--  professionnels fréquents, plus le taux d’attrition augmente. Celui-ci passe de 8 % pour ceux qui 
--  ne voyagent pas à 14,96 % pour ceux qui voyagent rarement, pour atteindre 24,91 % chez ceux qui voyagent
-- fréquemment, soit un taux d’attrition environ 3 fois plus élevé que chez les collaborateurs qui ne voyagent pas.


/* ---------------------------------------------------------------------
   03.2  ATTRITION SELON LA D--ISTANCE DOMICILE - TRAVAIL
--------------------------------------------------------------------- */

/* ---------------------------------------------------------------------
   03.4 Attrition selon la distance domicile-travail

   Segmentation analytique :
   1-5   : proximité
   6-10  : distance modérée
   11-20 : distance importante
   21+   : longue distance
--------------------------------------------------------------------- */

WITH DistanceAnalysis AS
(
    SELECT
        CASE
            WHEN DistanceFromHome <= 5
                THEN '1-5'

            WHEN DistanceFromHome <= 10
                THEN '6-10'

            WHEN DistanceFromHome <= 20
                THEN '11-20'

            ELSE '21+'
        END AS DistanceGroup,

        DistanceFromHome,
        AttritionFlag

    FROM GOLD.employee_analytics
)

SELECT
    DistanceGroup,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    CAST(
        AVG(CAST(DistanceFromHome AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS AverageDistance,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM DistanceAnalysis

GROUP BY DistanceGroup

ORDER BY AttritionRatePct DESC;
GO

-- Une tendance d’attrition est observée en fonction de la distance domicile-travail :
--  plus cette distance augmente, plus le taux d’attrition est élevé.
--   Celui-ci passe de **13,77 %** chez les collaborateurs résidant à moins de 6 km de leur lieu de travail à **22,06 %** 
--   chez ceux résidant à plus de 21 km.

/* ---------------------------------------------------------------------
   03.4 Distance moyenne selon le statut d'attrition
--------------------------------------------------------------------- */

SELECT
    Attrition,

    COUNT(*) AS EmployeeCount,

    CAST(
        AVG(CAST(DistanceFromHome AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS AverageDistanceFromHome,

    MIN(DistanceFromHome) AS MinDistance,

    MAX(DistanceFromHome) AS MaxDistance

FROM GOLD.employee_analytics

GROUP BY Attrition

ORDER BY Attrition DESC;
GO

--ELes collaborateurs ayant quitté l'entreprise résident en
    --  moyenne à une distance supérieure d'environ 1,71 unité
    --  à celle des collaborateurs restés dans l'entreprise.



/* =====================================================================
   04. SATISFACTION & ENGAGEMENT

   Objectif :
   Analyser l'association entre l'attrition et les différentes
   dimensions de satisfaction, d'engagement et d'équilibre de vie.

   Variables étudiées :
   - JobSatisfaction
   - EnvironmentSatisfaction
   - WorkLifeBalance
   - JobInvolvement
   - RelationshipSatisfaction

   Benchmark entreprise :
   Taux d'attrition global = 16,12 %
===================================================================== */


/* ---------------------------------------------------------------------
   04.1 Attrition selon la satisfaction au travail
--------------------------------------------------------------------- */

SELECT
    JobSatisfaction,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    COUNT(*) - SUM(AttritionFlag) AS EmployeesStayed,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY JobSatisfaction

ORDER BY JobSatisfaction;
GO


/* ---------------------------------------------------------------------
   04.2 Attrition selon la satisfaction liée à l'environnement
--------------------------------------------------------------------- */

SELECT
    EnvironmentSatisfaction,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    COUNT(*) - SUM(AttritionFlag) AS EmployeesStayed,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY EnvironmentSatisfaction

ORDER BY EnvironmentSatisfaction;
GO


/* ---------------------------------------------------------------------
   04.3 Attrition selon l'équilibre vie professionnelle / personnelle
--------------------------------------------------------------------- */

SELECT
    WorkLifeBalance,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    COUNT(*) - SUM(AttritionFlag) AS EmployeesStayed,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY WorkLifeBalance

ORDER BY WorkLifeBalance;
GO


/* ---------------------------------------------------------------------
   04.4 Attrition selon l'implication dans le travail
--------------------------------------------------------------------- */

SELECT
    JobInvolvement,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    COUNT(*) - SUM(AttritionFlag) AS EmployeesStayed,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY JobInvolvement

ORDER BY JobInvolvement;
GO


/* ---------------------------------------------------------------------
   04.5 Attrition selon la satisfaction relationnelle
--------------------------------------------------------------------- */

SELECT
    RelationshipSatisfaction,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    COUNT(*) - SUM(AttritionFlag) AS EmployeesStayed,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY RelationshipSatisfaction

ORDER BY RelationshipSatisfaction;
GO


/* ---------------------------------------------------------------------
   04.6 Comparaison des scores moyens :
        collaborateurs partis vs collaborateurs restés

   Objectif :
   Compléter l'analyse par catégorie en comparant les niveaux moyens
   de satisfaction et d'engagement selon le statut d'attrition.
--------------------------------------------------------------------- */

SELECT
    Attrition,

    COUNT(*) AS EmployeeCount,

    CAST(
        AVG(CAST(JobSatisfaction AS DECIMAL(10,2)))
        AS DECIMAL(5,2)
    ) AS AvgJobSatisfaction,

    CAST(
        AVG(CAST(EnvironmentSatisfaction AS DECIMAL(10,2)))
        AS DECIMAL(5,2)
    ) AS AvgEnvironmentSatisfaction,

    CAST(
        AVG(CAST(WorkLifeBalance AS DECIMAL(10,2)))
        AS DECIMAL(5,2)
    ) AS AvgWorkLifeBalance,

    CAST(
        AVG(CAST(JobInvolvement AS DECIMAL(10,2)))
        AS DECIMAL(5,2)
    ) AS AvgJobInvolvement,

    CAST(
        AVG(CAST(RelationshipSatisfaction AS DECIMAL(10,2)))
        AS DECIMAL(5,2)
    ) AS AvgRelationshipSatisfaction

FROM GOLD.employee_analytics

GROUP BY Attrition

ORDER BY Attrition DESC;
GO


/* ---------------------------------------------------------------------
   04.7 Cumul des signaux de faible satisfaction

   Définition :
   Une dimension est considérée comme faible lorsque son score
   est <= 2.

   LowSatisfactionCount indique le nombre de dimensions défavorables
   parmi :
       - Job Satisfaction
       - Environment Satisfaction
       - Work-Life Balance
       - Job Involvement
       - Relationship Satisfaction

   Objectif :
   Vérifier si l'accumulation de plusieurs signaux défavorables
   est associée à une augmentation du taux d'attrition.

   Remarque :
   Cet indicateur est exploratoire et ne constitue pas un score RH
   validé ou causal.
--------------------------------------------------------------------- */

WITH SatisfactionAnalysis AS
(
    SELECT
        EmployeeNumber,
        AttritionFlag,

        CASE WHEN JobSatisfaction <= 2
             THEN 1 ELSE 0 END
        +
        CASE WHEN EnvironmentSatisfaction <= 2
             THEN 1 ELSE 0 END
        +
        CASE WHEN WorkLifeBalance <= 2
             THEN 1 ELSE 0 END
        +
        CASE WHEN JobInvolvement <= 2
             THEN 1 ELSE 0 END
        +
        CASE WHEN RelationshipSatisfaction <= 2
             THEN 1 ELSE 0 END
        AS LowSatisfactionCount

    FROM GOLD.employee_analytics
)

SELECT
    LowSatisfactionCount,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    COUNT(*) - SUM(AttritionFlag) AS EmployeesStayed,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM SatisfactionAnalysis

GROUP BY LowSatisfactionCount

ORDER BY LowSatisfactionCount;
GO