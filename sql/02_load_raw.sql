/* =====================================================================
   PROJET       : HR Analytics - Workforce & Employee Insights
   SCRIPT       : 002_load_raw.sql
   BASE         : HR_Analytics
   COUCHE       : RAW
   TABLE CIBLE  : RAW.employees

   OBJECTIF
   ---------------------------------------------------------------------
   Automatiser le chargement des données RH sources dans la couche RAW
   de l'architecture analytique.

   La couche RAW constitue le point d'entrée des données dans le
   pipeline. Les données y sont conservées au plus proche de leur
   structure d'origine, sans transformation métier.

   SOURCE
   ---------------------------------------------------------------------
   Fichier : HR-Employee-Attrition.csv
   Format  : CSV
   Origine : Dataset HR Employee Attrition

   STRATÉGIE DE CHARGEMENT
   ---------------------------------------------------------------------
   Le chargement suit une stratégie de remplacement complet :

       1. Vidage de la table RAW.employees
       2. Rechargement intégral du fichier CSV
       3. Conservation des données sans transformation

   L'utilisation de TRUNCATE TABLE garantit qu'un nouveau chargement
   ne crée pas de doublons avec les données précédemment importées.

   IMPORTANT
   ---------------------------------------------------------------------
   Aucune règle de nettoyage ou transformation n'est appliquée ici.
   Les contrôles de qualité sont réalisés dans 003_data_quality.sql.
===================================================================== */

USE HR_Analytics;
GO


/* =====================================================================
   CRÉATION DE LA PROCÉDURE DE CHARGEMENT
   =====================================================================
   La procédure RAW.load_employees centralise la logique d'ingestion
   afin de rendre le chargement reproductible et facilement exécutable.

   CREATE OR ALTER permet :
   - de créer la procédure lors de la première exécution ;
   - de la modifier automatiquement si elle existe déjà.
===================================================================== */

CREATE OR ALTER PROCEDURE RAW.load_employees
AS
BEGIN

    SET NOCOUNT ON;

    BEGIN TRY

        PRINT '=======================================================';
        PRINT ' DÉBUT DU CHARGEMENT - COUCHE RAW';
        PRINT ' Table cible : RAW.employees';
        PRINT '=======================================================';


        /* -------------------------------------------------------------
           ÉTAPE 1 - Réinitialisation de la table cible
        ------------------------------------------------------------- */

        PRINT '>> Réinitialisation de RAW.employees...';

        TRUNCATE TABLE RAW.employees;

        PRINT '>> Table réinitialisée avec succès.';


        /* -------------------------------------------------------------
           ÉTAPE 2 - Chargement du fichier CSV
        ------------------------------------------------------------- */

        PRINT '>> Chargement du fichier source en cours...';

        BULK INSERT RAW.employees
        FROM 'C:\Full_stack\Portfolio\Hr_attrition\data\raw\HR-Employee-Attrition.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );

        PRINT '>> Fichier chargé avec succès.';


        /* -------------------------------------------------------------
           ÉTAPE 3 - Contrôle du volume chargé

           Le nombre de lignes chargé est affiché afin de permettre
           un premier contrôle opérationnel de l'ingestion.
        ------------------------------------------------------------- */

        DECLARE @RowCount INT;

        SELECT @RowCount = COUNT(*)
        FROM RAW.employees;

        PRINT CONCAT('>> Nombre de lignes chargées : ', @RowCount);


        PRINT '=======================================================';
        PRINT ' CHARGEMENT RAW TERMINÉ AVEC SUCCÈS';
        PRINT '=======================================================';

    END TRY


    /* -----------------------------------------------------------------
       GESTION DES ERREURS

       Toute erreur rencontrée pendant le chargement est interceptée
       afin de retourner un message exploitable pour le diagnostic.
    ----------------------------------------------------------------- */

    BEGIN CATCH

        PRINT '=======================================================';
        PRINT ' ÉCHEC DU CHARGEMENT - COUCHE RAW';
        PRINT '=======================================================';

        PRINT CONCAT('Erreur SQL : ', ERROR_NUMBER());
        PRINT CONCAT('Message     : ', ERROR_MESSAGE());
        PRINT CONCAT('Ligne       : ', ERROR_LINE());

        THROW;

    END CATCH;

END;
GO