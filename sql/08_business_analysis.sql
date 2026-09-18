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

/* =====================================================================
   04. SATISFACTION & ENGAGEMENT — KEY FINDINGS
   =====================================================================

   SATISFACTION AU TRAVAIL — JobSatisfaction
   ---------------------------------------------------------------------
   - Les collaborateurs ayant le niveau de satisfaction au travail
     le plus faible présentent un taux d'attrition de 22,84 %,
     contre 11,33 % pour ceux ayant le niveau de satisfaction maximal.

   => Une faible satisfaction au travail apparaît associée à une
      attrition plus importante.


   ENVIRONNEMENT DE TRAVAIL — EnvironmentSatisfaction
   ---------------------------------------------------------------------
   - Le niveau de satisfaction environnementale le plus faible
     présente un taux d'attrition de 25,35 %.

   - Pour les niveaux 2 à 4, le taux se stabilise autour de 13 à 15 %.

   => Le principal signal semble donc provenir d'un environnement
      perçu très négativement plutôt que d'une relation parfaitement
      linéaire entre satisfaction et attrition.


   ÉQUILIBRE VIE PROFESSIONNELLE / PERSONNELLE — WorkLifeBalance
   ---------------------------------------------------------------------
   - Les collaborateurs déclarant le niveau d'équilibre le plus faible
     présentent un taux d'attrition de 31,25 %, soit presque deux fois
     le taux global de l'entreprise (16,12 %).

   - Cependant, la relation n'est pas strictement décroissante :
     le niveau 4 présente un taux de 17,65 %, supérieur au niveau 3
     (14,22 %).

   => Un très faible Work-Life Balance constitue un signal important,
      mais les résultats ne permettent pas de conclure à une relation
      linéaire sur l'ensemble de l'échelle.


   IMPLICATION AU TRAVAIL — JobInvolvement
   ---------------------------------------------------------------------
   - JobInvolvement présente une relation particulièrement nette
     avec l'attrition :

       Niveau 1 : 33,73 %
       Niveau 2 : 18,93 %
       Niveau 3 : 14,40 %
       Niveau 4 :  9,03 %

   - Le taux d'attrition diminue progressivement lorsque le niveau
     d'implication augmente.

   => JobInvolvement constitue l'un des signaux de satisfaction /
      engagement les plus fortement associés à l'attrition.


   SATISFACTION RELATIONNELLE — RelationshipSatisfaction
   ---------------------------------------------------------------------
   - Le niveau le plus faible présente un taux d'attrition de 20,65 %,
     contre environ 15 % pour les niveaux 2 à 4.

   => Une faible satisfaction relationnelle semble associée à une
      attrition plus élevée, mais l'association observée est moins
      marquée que pour JobInvolvement ou WorkLifeBalance.


   COMPARAISON DES MOYENNES
   ---------------------------------------------------------------------
   - Les collaborateurs ayant quitté l'entreprise présentent des
     scores moyens inférieurs sur les cinq dimensions étudiées.

                             Départs     Restés
       JobSatisfaction        2,47        2,78
       Environment            2,46        2,77
       WorkLifeBalance        2,66        2,78
       JobInvolvement         2,52        2,77
       Relationship           2,60        2,73

   => Les écarts les plus importants concernent notamment la
      satisfaction au travail, l'environnement et l'implication.


   ACCUMULATION DES SIGNAUX DÉFAVORABLES
   ---------------------------------------------------------------------
   - L'indicateur exploratoire LowSatisfactionCount révèle une
     augmentation importante de l'attrition lorsque plusieurs
     dimensions défavorables sont simultanément présentes :

       0 signal défavorable :  8,13 %
       1 signal défavorable : 12,58 %
       2 signaux défavorables : 14,49 %
       3 signaux défavorables : 25,55 %
       4 signaux défavorables : 31,82 %
       5 signaux défavorables : 25,00 %

   - À partir de trois dimensions défavorables, le taux d'attrition
     augmente fortement et dépasse largement le benchmark de 16,12 %.

   - Le groupe présentant cinq signaux ne contient toutefois que
     12 collaborateurs. Son taux de 25 % doit donc être interprété
     avec prudence en raison du faible effectif.


   SYNTHÈSE
   ---------------------------------------------------------------------
   Les résultats suggèrent que l'attrition n'est pas uniquement
   associée à une dimension isolée de satisfaction.

   L'accumulation de plusieurs signaux défavorables apparaît
   particulièrement importante : les collaborateurs présentant
   3 ou 4 dimensions faibles enregistrent des taux d'attrition
   nettement supérieurs à la moyenne de l'entreprise.

   JobInvolvement ressort comme l'un des indicateurs individuels
   les plus discriminants, tandis qu'un très faible WorkLifeBalance
   et un très faible EnvironmentSatisfaction sont également associés
   à des niveaux d'attrition élevés.

   Ces résultats restent descriptifs et ne permettent pas d'établir
   une relation causale. Ils devront être croisés avec les conditions
   de travail, l'ancienneté, le métier et la rémunération.
===================================================================== */


/* =====================================================================
   05. COMPENSATION

   Objectif :
   Analyser l'association entre la rémunération et l'attrition.

   Variables étudiées :
   - MonthlyIncome
   - IncomeBand
   - PercentSalaryHike
   - StockOptionLevel

===================================================================== */


/* ---------------------------------------------------------------------
   05.1 Revenu moyen selon le statut d'attrition
--------------------------------------------------------------------- */

SELECT
    Attrition,

    COUNT(*) AS EmployeeCount,

    CAST(
        AVG(CAST(MonthlyIncome AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS AverageMonthlyIncome,

    MIN(MonthlyIncome) AS MinMonthlyIncome,

    MAX(MonthlyIncome) AS MaxMonthlyIncome

FROM GOLD.employee_analytics

GROUP BY Attrition

ORDER BY Attrition DESC;
GO


/* ---------------------------------------------------------------------
   05.2 Revenu médian selon le statut d'attrition
--------------------------------------------------------------------- */

WITH IncomeMedian AS
(
    SELECT
        Attrition,

        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY MonthlyIncome
        )
        OVER (
            PARTITION BY Attrition
        ) AS MedianMonthlyIncome

    FROM GOLD.employee_analytics
)

SELECT DISTINCT
    Attrition,

    CAST(
        MedianMonthlyIncome
        AS DECIMAL(10,2)
    ) AS MedianMonthlyIncome

FROM IncomeMedian

ORDER BY Attrition DESC;
GO


/* ---------------------------------------------------------------------
   05.3 Attrition selon le niveau de revenu
--------------------------------------------------------------------- */

SELECT
    IncomeBand,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    COUNT(*) - SUM(AttritionFlag) AS EmployeesStayed,

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
   05.4 Augmentation salariale moyenne :
        départs vs collaborateurs restés
--------------------------------------------------------------------- */

SELECT
    Attrition,

    COUNT(*) AS EmployeeCount,

    CAST(
        AVG(CAST(PercentSalaryHike AS DECIMAL(10,2)))
        AS DECIMAL(5,2)
    ) AS AveragePercentSalaryHike,

    MIN(PercentSalaryHike) AS MinPercentSalaryHike,

    MAX(PercentSalaryHike) AS MaxPercentSalaryHike

FROM GOLD.employee_analytics

GROUP BY Attrition

ORDER BY Attrition DESC;
GO


/* ---------------------------------------------------------------------
   05.5 Attrition selon l'augmentation salariale

   Segmentation analytique :
   11-15 %
   16-20 %
   21-25 %

   Objectif :
   Vérifier si le taux d'attrition varie selon le niveau
   d'augmentation salariale.
--------------------------------------------------------------------- */

WITH SalaryHikeAnalysis AS
(
    SELECT
        CASE
            WHEN PercentSalaryHike <= 15
                THEN '11-15 %'

            WHEN PercentSalaryHike <= 20
                THEN '16-20 %'

            ELSE '21-25 %'
        END AS SalaryHikeGroup,

        PercentSalaryHike,

        AttritionFlag

    FROM GOLD.employee_analytics
)

SELECT
    SalaryHikeGroup,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    COUNT(*) - SUM(AttritionFlag) AS EmployeesStayed,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM SalaryHikeAnalysis

GROUP BY SalaryHikeGroup

ORDER BY
    MIN(PercentSalaryHike);
GO


/* ---------------------------------------------------------------------
   05.6 Attrition selon le niveau de stock-options
--------------------------------------------------------------------- */

SELECT
    StockOptionLevel,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    COUNT(*) - SUM(AttritionFlag) AS EmployeesStayed,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY StockOptionLevel

ORDER BY StockOptionLevel;
GO


/* ---------------------------------------------------------------------
   05.7 Revenu moyen selon JobLevel et statut d'attrition

   Objectif :
   Comparer les rémunérations à niveau de poste comparable.

   Cette analyse est plus pertinente que la simple comparaison
   du revenu moyen global car JobLevel est fortement lié
   à MonthlyIncome.
--------------------------------------------------------------------- */

SELECT
    JobLevel,

    Attrition,

    COUNT(*) AS EmployeeCount,

    CAST(
        AVG(CAST(MonthlyIncome AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS AverageMonthlyIncome

FROM GOLD.employee_analytics

GROUP BY
    JobLevel,
    Attrition

ORDER BY
    JobLevel,
    Attrition DESC;
GO


/* ---------------------------------------------------------------------
   05.8 Taux d'attrition par IncomeBand et JobLevel

   Objectif :
   Vérifier si l'association entre faible revenu et attrition
   persiste lorsque l'on compare des collaborateurs appartenant
   au même niveau de poste.
--------------------------------------------------------------------- */

SELECT
    JobLevel,

    IncomeBand,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY
    JobLevel,
    IncomeBand

HAVING COUNT(*) >= 10

ORDER BY
    JobLevel,
    AttritionRatePct DESC;
GO


/* ---------------------------------------------------------------------
   05.9 Taux d'attrition par métier et niveau de revenu

   Objectif :
   Identifier les combinaisons métier / rémunération associées
   aux taux d'attrition les plus élevés.

   Le filtre minimum de 20 collaborateurs permet d'éviter
   de surinterpréter des groupes trop petits.
--------------------------------------------------------------------- */

SELECT
    JobRole,

    IncomeBand,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY
    JobRole,
    IncomeBand

HAVING COUNT(*) >= 20

ORDER BY
    AttritionRatePct DESC;
GO


/* =====================================================================
   05. COMPENSATION — KEY FINDINGS
   =====================================================================

   REVENU MENSUEL — MonthlyIncome
   ---------------------------------------------------------------------
   - Les collaborateurs ayant quitté l'entreprise présentent un revenu
     mensuel moyen de 4 787,09, contre 6 832,74 pour ceux qui sont restés.

   - L'écart apparaît également au niveau de la médiane :
       Départs : 3 202
       Restés  : 5 204

   - La médiane confirme que l'écart observé ne provient pas uniquement
     de quelques rémunérations très élevées.

   => Les départs sont davantage concentrés parmi les collaborateurs
      disposant des revenus les plus faibles. Cependant, le revenu est
      fortement associé au niveau de poste, au métier et à l'expérience.


   NIVEAU DE REVENU — IncomeBand
   ---------------------------------------------------------------------
   - Le quartile de revenu le plus faible présente un taux d'attrition
     de 29,35 %, largement supérieur au benchmark de 16,12 %.

       Faible         : 29,35 %
       Intermédiaire  : 14,13 %
       Élevé          : 10,63 %
       Très élevé     : 10,35 %

   - 108 des 237 départs appartiennent au quartile de revenu faible,
     soit environ 45,6 % de l'ensemble des départs, alors que ce groupe
     représente environ 25 % de l'effectif.

   => L'attrition est fortement concentrée dans la partie basse de
      la distribution des revenus.


   AUGMENTATION SALARIALE — PercentSalaryHike
   ---------------------------------------------------------------------
   - L'augmentation salariale moyenne est presque identique entre
     les collaborateurs partis et ceux restés :

       Départs : 15,10 %
       Restés  : 15,23 %

   - Les taux d'attrition par tranche sont également proches :

       11-15 % : 16,32 %
       16-20 % : 15,00 %
       21-25 % : 17,54 %

   => Aucun gradient clair n'apparaît entre PercentSalaryHike
      et l'attrition.

   => Dans ce dataset, PercentSalaryHike ne ressort donc pas comme
      un signal descriptif majeur de l'attrition.


   STOCK-OPTIONS — StockOptionLevel
   ---------------------------------------------------------------------
   - Les collaborateurs sans stock-options présentent un taux
     d'attrition de 24,41 %.

   - Les niveaux 1 et 2 présentent des taux nettement plus faibles :

       Niveau 0 : 24,41 %
       Niveau 1 :  9,40 %
       Niveau 2 :  7,59 %
       Niveau 3 : 17,65 %

   - La remontée observée au niveau 3 montre que la relation n'est
     toutefois pas strictement décroissante.

   - Le niveau 3 ne contient que 85 collaborateurs, ce qui impose
     également davantage de prudence dans son interprétation.

   => L'absence de stock-options est associée à une attrition élevée,
      mais cette relation devra être contrôlée selon le niveau de poste,
      la situation familiale et d'autres caractéristiques des salariés.


   REVENU À NIVEAU DE POSTE COMPARABLE
   ---------------------------------------------------------------------
   - La comparaison par JobLevel nuance fortement la différence globale
     de revenu entre les salariés partis et ceux restés.

   - Au JobLevel 1 :
       Départs : 2 598
       Restés  : 2 854

     Les salariés partis ont un revenu moyen inférieur.

   - Au JobLevel 2 :
       Départs : 5 760
       Restés  : 5 475

     Le revenu moyen des salariés partis est légèrement supérieur.

   - Au JobLevel 3 :
       Départs : 9 388
       Restés  : 9 891

     L'écart redevient défavorable aux salariés partis.

   - Les JobLevels 4 et 5 enregistrent très peu de départs
     (5 chacun), ce qui limite la portée des comparaisons de moyennes.

   => L'écart global de revenu entre départs et salariés restés ne peut
      donc pas être interprété comme un effet salarial indépendant.
      Une partie de cet écart provient de la structure des populations,
      notamment de la forte attrition observée au JobLevel 1.


   REVENU × JOB LEVEL
   ---------------------------------------------------------------------
   - Le signal le plus marqué apparaît au JobLevel 1 :

       Revenu faible        : 30,14 %
       Revenu intermédiaire : 18,92 %

   - Cela suggère que même parmi les postes de niveau 1, les salariés
     situés dans la partie basse des revenus présentent une attrition
     sensiblement supérieure.

   - Pour les autres JobLevels, la relation devient moins régulière.

   => Le faible revenu semble particulièrement pertinent lorsqu'il
      est combiné à un faible niveau de poste.


   MÉTIER × NIVEAU DE REVENU
   ---------------------------------------------------------------------
   Plusieurs combinaisons ressortent fortement :

       Sales Representative + revenu faible
           -> 43,75 % d'attrition

       Human Resources + revenu faible
           -> 39,13 %

       Laboratory Technician + revenu faible
           -> 29,23 %

       Research Scientist + revenu faible
           -> 21,85 %

   - Les Sales Representatives à faible revenu constituent un segment
     particulièrement exposé : 28 départs sur 64 collaborateurs.

   - Toutefois, le revenu faible n'explique pas à lui seul l'ensemble
     des différences observées.

   - Par exemple, les Sales Executives appartenant au quartile de
     revenu très élevé présentent également 22,73 % d'attrition.

   => L'association entre rémunération et attrition dépend donc
      fortement du métier et du niveau de poste.


   SYNTHÈSE
   ---------------------------------------------------------------------
   La rémunération apporte trois enseignements principaux :

   1. Les collaborateurs appartenant au quartile de revenu le plus
      faible présentent une attrition particulièrement élevée
      (29,35 %).

   2. PercentSalaryHike ne montre pratiquement aucune association
      descriptive claire avec l'attrition.

   3. L'analyse conditionnelle montre que la relation entre revenu
      et attrition est fortement liée au JobLevel et au JobRole.

   Le segment combinant faible revenu et faible niveau de poste
   apparaît particulièrement exposé.

   Les Sales Representatives à faible revenu constituent notamment
   l'une des populations les plus sensibles identifiées jusqu'ici,
   avec un taux d'attrition de 43,75 %.
===================================================================== */


/* =====================================================================
   06. CAREER & TENURE
   =====================================================================

   Objectif :
   Analyser l'association entre l'attrition et le parcours professionnel
   du collaborateur dans l'entreprise.

   Variables étudiées :
   - YearsAtCompany / TenureGroup
   - YearsInCurrentRole
   - YearsSinceLastPromotion
   - YearsWithCurrManager
   - TrainingTimesLastYear
   - TotalWorkingYears / ExperienceGroup

   Benchmark entreprise :
   Taux d'attrition global = 16,12 %
===================================================================== */


/* ---------------------------------------------------------------------
   06.1 Attrition selon l'ancienneté dans l'entreprise
--------------------------------------------------------------------- */

SELECT
    TenureGroup,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    COUNT(*) - SUM(AttritionFlag) AS EmployeesStayed,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY TenureGroup

ORDER BY MIN(YearsAtCompany);
GO


/* ---------------------------------------------------------------------
   06.2 Ancienneté moyenne :
        départs vs collaborateurs restés
--------------------------------------------------------------------- */

SELECT
    Attrition,

    COUNT(*) AS EmployeeCount,

    CAST(
        AVG(CAST(YearsAtCompany AS DECIMAL(10,2)))
        AS DECIMAL(5,2)
    ) AS AvgYearsAtCompany,

    CAST(
        AVG(CAST(YearsInCurrentRole AS DECIMAL(10,2)))
        AS DECIMAL(5,2)
    ) AS AvgYearsInCurrentRole,

    CAST(
        AVG(CAST(YearsSinceLastPromotion AS DECIMAL(10,2)))
        AS DECIMAL(5,2)
    ) AS AvgYearsSinceLastPromotion,

    CAST(
        AVG(CAST(YearsWithCurrManager AS DECIMAL(10,2)))
        AS DECIMAL(5,2)
    ) AS AvgYearsWithCurrentManager

FROM GOLD.employee_analytics

GROUP BY Attrition

ORDER BY Attrition DESC;
GO


/* ---------------------------------------------------------------------
   06.3 Attrition selon l'expérience professionnelle totale
--------------------------------------------------------------------- */

SELECT
    ExperienceGroup,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    COUNT(*) - SUM(AttritionFlag) AS EmployeesStayed,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY ExperienceGroup

ORDER BY MIN(TotalWorkingYears);
GO


/* ---------------------------------------------------------------------
   06.4 Attrition selon le temps passé dans le rôle actuel

   Segmentation :
   0-2 ans
   3-5 ans
   6-10 ans
   11+ ans
--------------------------------------------------------------------- */

WITH CurrentRoleAnalysis AS
(
    SELECT
        CASE
            WHEN YearsInCurrentRole <= 2
                THEN '0-2 ans'

            WHEN YearsInCurrentRole <= 5
                THEN '3-5 ans'

            WHEN YearsInCurrentRole <= 10
                THEN '6-10 ans'

            ELSE '11+ ans'
        END AS CurrentRoleGroup,

        YearsInCurrentRole,
        AttritionFlag

    FROM GOLD.employee_analytics
)

SELECT
    CurrentRoleGroup,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    COUNT(*) - SUM(AttritionFlag) AS EmployeesStayed,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM CurrentRoleAnalysis

GROUP BY CurrentRoleGroup

ORDER BY MIN(YearsInCurrentRole);
GO


/* ---------------------------------------------------------------------
   06.5 Attrition selon le temps depuis la dernière promotion

   Attention :
   YearsSinceLastPromotion = 0 peut également concerner des
   collaborateurs récemment arrivés ou récemment promus.

   Il ne faut donc pas interpréter cette valeur comme une absence
   de progression professionnelle.
--------------------------------------------------------------------- */

WITH PromotionAnalysis AS
(
    SELECT
        CASE
            WHEN YearsSinceLastPromotion = 0
                THEN '0 an'

            WHEN YearsSinceLastPromotion <= 2
                THEN '1-2 ans'

            WHEN YearsSinceLastPromotion <= 5
                THEN '3-5 ans'

            ELSE '6+ ans'
        END AS PromotionGroup,

        YearsSinceLastPromotion,
        AttritionFlag

    FROM GOLD.employee_analytics
)

SELECT
    PromotionGroup,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    COUNT(*) - SUM(AttritionFlag) AS EmployeesStayed,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM PromotionAnalysis

GROUP BY PromotionGroup

ORDER BY MIN(YearsSinceLastPromotion);
GO


/* ---------------------------------------------------------------------
   06.6 Attrition selon le temps passé avec le manager actuel
--------------------------------------------------------------------- */

WITH ManagerTenureAnalysis AS
(
    SELECT
        CASE
            WHEN YearsWithCurrManager <= 2
                THEN '0-2 ans'

            WHEN YearsWithCurrManager <= 5
                THEN '3-5 ans'

            WHEN YearsWithCurrManager <= 10
                THEN '6-10 ans'

            ELSE '11+ ans'
        END AS ManagerTenureGroup,

        YearsWithCurrManager,
        AttritionFlag

    FROM GOLD.employee_analytics
)

SELECT
    ManagerTenureGroup,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    COUNT(*) - SUM(AttritionFlag) AS EmployeesStayed,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM ManagerTenureAnalysis

GROUP BY ManagerTenureGroup

ORDER BY MIN(YearsWithCurrManager);
GO


/* ---------------------------------------------------------------------
   06.7 Attrition selon le nombre de formations suivies
        durant l'année précédente
--------------------------------------------------------------------- */

SELECT
    TrainingTimesLastYear,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    COUNT(*) - SUM(AttritionFlag) AS EmployeesStayed,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY TrainingTimesLastYear

ORDER BY TrainingTimesLastYear;
GO


/* =====================================================================
   07. MULTI-FACTOR ANALYSIS
   =====================================================================

   Objectif :
   Dépasser l'analyse univariée et étudier la combinaison des
   principaux facteurs associés à l'attrition identifiés dans les
   sections précédentes.

   Principaux signaux déjà identifiés :
   - OverTime
   - faible ancienneté
   - faible expérience
   - faible revenu
   - JobLevel 1
   - certains JobRoles
   - déplacements fréquents
   - faible JobInvolvement
   - faible WorkLifeBalance
   - accumulation de faibles niveaux de satisfaction

   Attention :
   Ces analyses restent descriptives. Elles permettent d'identifier
   des segments fortement exposés mais ne démontrent pas de causalité.
===================================================================== */


/* ---------------------------------------------------------------------
   07.1 OverTime × JobRole

   Objectif :
   Identifier les métiers pour lesquels les heures supplémentaires
   sont associées aux niveaux d'attrition les plus élevés.
--------------------------------------------------------------------- */

SELECT
    JobRole,
    OverTime,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY
    JobRole,
    OverTime

HAVING COUNT(*) >= 20

ORDER BY AttritionRatePct DESC;
GO


/* ---------------------------------------------------------------------
   07.2 OverTime × TenureGroup

   Objectif :
   Vérifier si les heures supplémentaires sont particulièrement
   associées aux départs des collaborateurs récemment arrivés.
--------------------------------------------------------------------- */

SELECT
    TenureGroup,
    OverTime,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY
    TenureGroup,
    OverTime

HAVING COUNT(*) >= 20

ORDER BY
    MIN(YearsAtCompany),
    AttritionRatePct DESC;
GO


/* ---------------------------------------------------------------------
   07.3 OverTime × JobSatisfaction

   Objectif :
   Vérifier si l'association entre heures supplémentaires et attrition
   devient particulièrement forte lorsque la satisfaction au travail
   est faible.
--------------------------------------------------------------------- */

SELECT
    OverTime,
    JobSatisfaction,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY
    OverTime,
    JobSatisfaction

HAVING COUNT(*) >= 20

ORDER BY AttritionRatePct DESC;
GO


/* ---------------------------------------------------------------------
   07.4 OverTime × JobInvolvement
--------------------------------------------------------------------- */

SELECT
    OverTime,
    JobInvolvement,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY
    OverTime,
    JobInvolvement

HAVING COUNT(*) >= 20

ORDER BY AttritionRatePct DESC;
GO


/* ---------------------------------------------------------------------
   07.5 OverTime × WorkLifeBalance
--------------------------------------------------------------------- */

SELECT
    OverTime,
    WorkLifeBalance,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY
    OverTime,
    WorkLifeBalance

HAVING COUNT(*) >= 20

ORDER BY AttritionRatePct DESC;
GO


/* ---------------------------------------------------------------------
   07.6 IncomeBand × TenureGroup

   Objectif :
   Vérifier si la combinaison faible revenu + faible ancienneté
   correspond à une population particulièrement exposée.
--------------------------------------------------------------------- */

SELECT
    TenureGroup,
    IncomeBand,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY
    TenureGroup,
    IncomeBand

HAVING COUNT(*) >= 20

ORDER BY AttritionRatePct DESC;
GO


/* ---------------------------------------------------------------------
   07.7 JobRole × IncomeBand

   Objectif :
   Confirmer les populations métier / rémunération les plus exposées.
--------------------------------------------------------------------- */

SELECT
    JobRole,
    IncomeBand,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY
    JobRole,
    IncomeBand

HAVING COUNT(*) >= 20

ORDER BY AttritionRatePct DESC;
GO


/* ---------------------------------------------------------------------
   07.8 BusinessTravel × OverTime

   Objectif :
   Vérifier si la combinaison déplacements professionnels fréquents
   + heures supplémentaires est associée à une attrition élevée.
--------------------------------------------------------------------- */

SELECT
    BusinessTravel,
    OverTime,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM GOLD.employee_analytics

GROUP BY
    BusinessTravel,
    OverTime

HAVING COUNT(*) >= 20

ORDER BY AttritionRatePct DESC;
GO


/* ---------------------------------------------------------------------
   07.9 Profil combiné :
        OverTime × Tenure × Income

   Objectif :
   Tester la combinaison de trois signaux majeurs identifiés :
       - heures supplémentaires
       - faible ancienneté
       - faible revenu

   LowTenure :
       1 = 0 à 2 ans dans l'entreprise

   LowIncome :
       1 = quartile de revenu faible
--------------------------------------------------------------------- */

WITH EmployeeRiskProfile AS
(
    SELECT
        EmployeeNumber,
        OverTime,

        CASE
            WHEN YearsAtCompany <= 2
                THEN 'Faible ancienneté'
            ELSE 'Ancienneté > 2 ans'
        END AS TenureProfile,

        CASE
            WHEN IncomeBand = 'Faible'
                THEN 'Faible revenu'
            ELSE 'Revenu supérieur'
        END AS IncomeProfile,

        AttritionFlag

    FROM GOLD.employee_analytics
)

SELECT
    OverTime,
    TenureProfile,
    IncomeProfile,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM EmployeeRiskProfile

GROUP BY
    OverTime,
    TenureProfile,
    IncomeProfile

HAVING COUNT(*) >= 20

ORDER BY AttritionRatePct DESC;
GO


/* ---------------------------------------------------------------------
   07.10 Accumulation de facteurs associés à l'attrition

   Construction d'un indicateur EXPLORATOIRE.

   1 point pour chaque condition :
       - OverTime = Yes
       - ancienneté <= 2 ans
       - IncomeBand = Faible
       - JobLevel = 1
       - JobInvolvement <= 2
       - WorkLifeBalance <= 2
       - BusinessTravel = Travel_Frequently

   IMPORTANT :
   Il ne s'agit PAS d'un modèle prédictif ni d'un score RH validé.
   Chaque facteur reçoit arbitrairement le même poids.

   L'objectif est uniquement de vérifier si l'accumulation de
   caractéristiques défavorables est associée à une augmentation
   du taux d'attrition.
--------------------------------------------------------------------- */

WITH RiskFactorAnalysis AS
(
    SELECT
        EmployeeNumber,
        AttritionFlag,

        CASE WHEN OverTime = 'Yes'
             THEN 1 ELSE 0 END

        +

        CASE WHEN YearsAtCompany <= 2
             THEN 1 ELSE 0 END

        +

        CASE WHEN IncomeBand = 'Faible'
             THEN 1 ELSE 0 END

        +

        CASE WHEN JobLevel = 1
             THEN 1 ELSE 0 END

        +

        CASE WHEN JobInvolvement <= 2
             THEN 1 ELSE 0 END

        +

        CASE WHEN WorkLifeBalance <= 2
             THEN 1 ELSE 0 END

        +

        CASE WHEN BusinessTravel = 'Travel_Frequently'
             THEN 1 ELSE 0 END

        AS RiskFactorCount

    FROM GOLD.employee_analytics
)

SELECT
    RiskFactorCount,

    COUNT(*) AS EmployeeCount,

    SUM(AttritionFlag) AS EmployeesLeft,

    COUNT(*) - SUM(AttritionFlag) AS EmployeesStayed,

    CAST(
        100.0 * SUM(AttritionFlag) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AttritionRatePct

FROM RiskFactorAnalysis

GROUP BY RiskFactorCount

ORDER BY RiskFactorCount;
GO


/* =====================================================================
   06 & 07 — KEY FINDINGS
   CAREER, TENURE & MULTI-FACTOR ANALYSIS
===================================================================== */


/* ---------------------------------------------------------------------
   06. CAREER & TENURE
   ---------------------------------------------------------------------

   ANCIENNETÉ DANS L'ENTREPRISE
   ---------------------------------------------------------------------
   - Les collaborateurs récemment arrivés sont particulièrement
     exposés à l'attrition.

       0-2 ans   : 29,82 %
       3-5 ans   : 13,82 %
       6-10 ans  : 12,28 %
       11-20 ans :  6,67 %
       20+ ans   : 12,12 %

   - Les collaborateurs ayant quitté l'entreprise présentent une
     ancienneté moyenne de 5,13 ans, contre 7,37 ans pour ceux
     qui sont restés.

   => Les premières années dans l'entreprise apparaissent comme
      une période particulièrement sensible pour la rétention.


   EXPÉRIENCE PROFESSIONNELLE
   ---------------------------------------------------------------------
   - Le signal est encore plus marqué pour l'expérience totale :

       0-2 ans  : 43,90 %
       3-5 ans  : 19,17 %
       6-10 ans : 14,99 %
       11-20 ans: 11,47 %
       20+ ans  :  7,73 %

   => L'attrition diminue fortement lorsque l'expérience
      professionnelle augmente.

   => Les collaborateurs en début de carrière constituent donc
      une population particulièrement exposée.


   TEMPS DANS LE RÔLE ACTUEL
   ---------------------------------------------------------------------
   - Les collaborateurs ayant passé 0 à 2 ans dans leur rôle actuel
     présentent 22,59 % d'attrition.

   - Le taux diminue ensuite progressivement :

       3-5 ans  : 11,64 %
       6-10 ans : 10,81 %
       11+ ans  :  6,41 %

   => Les premières années dans un nouveau rôle apparaissent
      associées à une attrition plus élevée.


   TEMPS AVEC LE MANAGER ACTUEL
   ---------------------------------------------------------------------
   - Les collaborateurs travaillant avec leur manager actuel depuis
     0 à 2 ans présentent 21,38 % d'attrition.

   - Ce taux diminue avec la durée de la relation :

       3-5 ans  : 12,55 %
       6-10 ans : 12,19 %
       11+ ans  :  4,11 %

   => Une faible ancienneté avec le manager est associée à davantage
      de départs.

   Attention :
   ce résultat peut également refléter la faible ancienneté générale
   des collaborateurs plutôt qu'un effet propre du management.


   PROMOTION
   ---------------------------------------------------------------------
   - Aucune relation linéaire simple n'apparaît entre le temps depuis
     la dernière promotion et l'attrition.

       0 an    : 18,93 %
       1-2 ans : 14,73 %
       3-5 ans : 10,13 %
       6+ ans  : 16,28 %

   - La valeur 0 peut notamment inclure des collaborateurs récemment
     arrivés et ne doit pas être interprétée comme une absence de
     progression professionnelle.

   => YearsSinceLastPromotion doit être interprété avec prudence.


   FORMATION
   ---------------------------------------------------------------------
   - Les collaborateurs n'ayant suivi aucune formation durant
     l'année précédente présentent 27,78 % d'attrition.

   - Cependant, aucune relation monotone n'apparaît sur l'ensemble
     des niveaux de formation.

   => TrainingTimesLastYear montre certaines différences descriptives,
      mais ne ressort pas comme un facteur isolé suffisamment régulier
      pour constituer une conclusion majeure.


/* =====================================================================
   07. MULTI-FACTOR ANALYSIS
===================================================================== */


   OVERTIME × JOB ROLE
   ---------------------------------------------------------------------
   L'association entre heures supplémentaires et attrition varie
   fortement selon le métier.

   Plusieurs segments ressortent :

       Sales Representative + OverTime
           -> 66,67 %

       Laboratory Technician + OverTime
           -> 50,00 %

       Research Scientist + OverTime
           -> 34,02 %

       Sales Executive + OverTime
           -> 32,98 %

   => Les Sales Representatives effectuant des heures supplémentaires
      constituent l'un des segments professionnels les plus exposés
      identifiés dans l'analyse.


   OVERTIME × ANCIENNETÉ
   ---------------------------------------------------------------------
   La combinaison heures supplémentaires + faible ancienneté
   présente un signal particulièrement fort :

       0-2 ans + OverTime    : 50,96 %
       0-2 ans + No OverTime : 20,59 %

       3-5 ans + OverTime    : 28,35 %
       3-5 ans + No OverTime :  7,82 %

       6-10 ans + OverTime   : 25,83 %
       6-10 ans + No OverTime:  7,32 %

   => Les heures supplémentaires semblent particulièrement associées
      à l'attrition pendant les premières années dans l'entreprise.


   OVERTIME × JOB INVOLVEMENT
   ---------------------------------------------------------------------
   La combinaison la plus défavorable est :

       OverTime = Yes
       JobInvolvement = 1
       Attrition = 52,00 %

   Le taux diminue progressivement lorsque JobInvolvement augmente,
   même parmi les collaborateurs effectuant des heures supplémentaires.

   => L'association entre heures supplémentaires et faible implication
      constitue un signal majeur.


   OVERTIME × WORK-LIFE BALANCE
   ---------------------------------------------------------------------
   - Les collaborateurs cumulant OverTime et le niveau minimal de
     WorkLifeBalance présentent 45,45 % d'attrition.

   - À titre de comparaison, les collaborateurs sans OverTime avec
     WorkLifeBalance = 3 présentent seulement 8,45 % d'attrition.

   => La combinaison de contraintes de temps et d'un faible équilibre
      vie professionnelle / personnelle constitue une population
      particulièrement exposée.


   BUSINESS TRAVEL × OVERTIME
   ---------------------------------------------------------------------
   Une accumulation apparaît également entre déplacements fréquents
   et heures supplémentaires :

       Travel_Frequently + OverTime : 41,86 %
       Travel_Rarely     + OverTime : 28,47 %
       Non-Travel        + OverTime : 20,00 %

   contre :

       Travel_Frequently + No OverTime : 17,28 %
       Travel_Rarely     + No OverTime :  9,63 %
       Non-Travel        + No OverTime :  4,35 %

   => Les collaborateurs cumulant déplacements fréquents et heures
      supplémentaires constituent une autre population à surveiller.


   REVENU × ANCIENNETÉ
   ---------------------------------------------------------------------
   - Les collaborateurs cumulant faible revenu et 0 à 2 ans
     d'ancienneté présentent 38,82 % d'attrition.

   - Pour les collaborateurs ayant 0 à 2 ans d'ancienneté mais
     appartenant au quartile de revenu le plus élevé, le taux tombe
     à 15,22 %.

   => Le début de carrière dans l'entreprise semble particulièrement
      sensible lorsque faible ancienneté et faible rémunération
      sont combinées.


   OVERTIME × FAIBLE ANCIENNETÉ × FAIBLE REVENU
   ---------------------------------------------------------------------
   Le segment combinant trois des principaux signaux identifiés
   présente le résultat le plus remarquable :

       OverTime           = Yes
       YearsAtCompany     = 0-2 ans
       IncomeBand         = Faible

       Effectif           = 45 collaborateurs
       Départs            = 32
       Attrition          = 71,11 %

   À titre de comparaison :

       No OverTime
       Ancienneté > 2 ans
       Revenu supérieur

       Effectif           = 679
       Départs            = 49
       Attrition          = 7,22 %

   => Le premier segment présente un taux d'attrition près de
      10 fois supérieur au second.

   Attention :
   cette comparaison décrit deux profils très différents et ne
   constitue pas une estimation causale de l'effet de ces variables.


   ACCUMULATION DES FACTEURS ASSOCIÉS
   ---------------------------------------------------------------------
   L'indicateur exploratoire RiskFactorCount fait apparaître une
   progression particulièrement nette :

       0 facteur :  4,41 %   (n = 227)
       1 facteur :  6,83 %   (n = 410)
       2 facteurs: 14,62 %   (n = 390)
       3 facteurs: 19,31 %   (n = 233)
       4 facteurs: 34,15 %   (n = 123)
       5 facteurs: 59,74 %   (n = 77)
       6 facteurs: 87,50 %   (n = 8)
       7 facteurs:100,00 %   (n = 2)

   => L'attrition augmente très fortement avec l'accumulation
      des facteurs étudiés.

   - Les groupes de 6 et 7 facteurs ne comptent toutefois que
     8 et 2 collaborateurs.

   => Leurs taux de 87,5 % et 100 % ne doivent donc pas être
      présentés comme des résultats généralisables.

   => Les groupes comportant 0 à 5 facteurs sont beaucoup plus
      robustes descriptivement et montrent déjà une progression
      très importante, de 4,41 % à 59,74 %.


/* =====================================================================
   SYNTHÈSE GÉNÉRALE
=====================================================================

   L'analyse ne met pas en évidence un facteur unique expliquant
   l'attrition. Elle révèle plutôt une accumulation de caractéristiques
   professionnelles et organisationnelles associées aux départs.

   Les principaux signaux identifiés sont :

   1. Faible ancienneté et faible expérience professionnelle
   2. Heures supplémentaires
   3. Faible niveau de revenu, particulièrement au JobLevel 1
   4. Certains métiers, notamment Sales Representative et
      Laboratory Technician
   5. Faible implication et plusieurs dimensions de satisfaction faibles
   6. Déplacements professionnels fréquents
   7. Accumulation simultanée de plusieurs de ces facteurs

   Le profil particulièrement exposé qui émerge de l'analyse est celui
   d'un collaborateur relativement junior, récemment arrivé, occupant
   un poste de niveau faible, disposant d'une rémunération relativement
   basse et soumis à des contraintes professionnelles importantes
   telles que les heures supplémentaires.

   Le segment :
       OverTime + ancienneté 0-2 ans + faible revenu
   atteint notamment 71,11 % d'attrition (32 départs sur 45).

   Ces résultats sont observationnels et descriptifs.
   Ils permettent d'identifier des populations prioritaires pour
   approfondir l'analyse et orienter les actions RH, mais ils ne
   démontrent pas que ces caractéristiques causent les départs.
===================================================================== */

SELECT
    @@SERVERNAME AS ServerName,
    SERVERPROPERTY('MachineName') AS MachineName,
    SERVERPROPERTY('InstanceName') AS InstanceName;
CREATE OR ALTER VIEW GOLD.vw_employee_ml AS

SELECT
    EmployeeNumber,
    Attrition,
    Age,
    BusinessTravel,
    DailyRate,
    Department,
    DistanceFromHome,
    Education,
    EducationField,
    EnvironmentSatisfaction,
    Gender,
    HourlyRate,
    JobInvolvement,
    JobLevel,
    JobRole,
    JobSatisfaction,
    MaritalStatus,
    MonthlyIncome,
    MonthlyRate,
    NumCompaniesWorked,
    OverTime,
    PercentSalaryHike,
    PerformanceRating,
    RelationshipSatisfaction,
    StockOptionLevel,
    TotalWorkingYears,
    TrainingTimesLastYear,
    WorkLifeBalance,
    YearsAtCompany,
    YearsInCurrentRole,
    YearsSinceLastPromotion,
    YearsWithCurrManager
FROM PROCESSED.employees;