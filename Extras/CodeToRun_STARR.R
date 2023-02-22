# This runs from eminty/ap_phenotype_evaluation:0.2 docker container.
# eminty/ApPhentotypeEvaluation renv.lock is initialized in the container build.
library()

# database settings ============================================================

databaseId <- "STARR"
cdmDatabaseSchema <- "som-rit-phi-starr-prod.starr_omop_cdm5_deid_latest"
cohortDatabaseSchema <- "som-nero-nigam-starr.acute_panc_phe_eval"
cohortTable <- "ap_phe_eval"
tempEmulationSchema <- "som-nero-nigam-starr.acute_panc_phe_eval"
workDatabaseSchema <- "som-nero-nigam-starr.acute_panc_phe_eval"
# local settings ===============================================================
studyFolder <- "/workdir/workdir/"
tempFolder <- "/workdir/workdir/andromedaTempFolder"
options(andromedaTempFolder = tempFolder,
        spipen = 999)
outputFolder <- file.path(studyFolder, databaseId)

# specify connection details ===================================================

jsonPath <- "/workdir/gcloud/application_default_credentials.json"
bqDriverPath <- "/workdir/workdir/BQDriver/"
project_id <- "som-nero-nigam-starr"
dataset_id <- "acute_panc_phe_eval"

connectionString <-  BQJdbcConnectionStringR::createBQConnectionString(projectId = project_id,
                                                                       defaultDataset = dataset_id,
                                                                       authType = 2,
                                                                       jsonCredentialsPath = jsonPath)

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms="bigquery",
                                                                connectionString=connectionString,
                                                                user="",
                                                                password='',
                                                                pathToDriver = bqDriverPath)
# # Create a test connection
# connection <- DatabaseConnector::connect(connectionDetails)
#
# sql <- "
# SELECT
#  COUNT(1) as counts
# FROM
#  `bigquery-public-data.cms_synthetic_patient_data_omop.care_site`
# "
#
# counts <- DatabaseConnector::querySql(connection, sql)
#
# print(counts)
# DatabaseConnector::disconnect(connection)



##########debugging.
#
# # uninstall current version of ApPhenotypeEvaluation
#  system("sudo chmod 777 -R /usr/local/lib/R/")
#  remove.packages("ApPhenotypeEvaluation")
#  remove.packages("PheValuator")
#
#  # develop branch of PheValuator
#  devtools::install_github("https://github.com/OHDSI/PheValuator", ref = "develop", dependencies = FALSE)
#
#  # local branch of ApPhenotypeEvaluation via R project install.
#
#  library()
#
# # local version of ApPhenotypeEvaluation
# # added tempEmulationSchema arg to local Phevaluator/CreatePhenoModel.R
# #install.packages("/workdir/workdir/PheValuator",repos=NULL,type="source")
#
#
# library(PheValuator)


# open ApPhenotypeEvaluation Project
# tempEmulationSchema argument added to RunCohortDiagnostics.R



# execute study ================================================================
library(magrittr)
##staged execution
# cohort generation
# ApPhenotypeEvaluation::execute(
#   connectionDetails = connectionDetails,
#   cdmDatabaseSchema = cdmDatabaseSchema,
#   cohortDatabaseSchema = cohortDatabaseSchema,
#   cohortTable = cohortTable,
#   outputFolder = outputFolder,
#   databaseId = databaseId,
#   createCohortTable = TRUE, # TRUE will delete the cohort table and all existing cohorts if already built X_X
#   createCohorts = TRUE,
#   runCohortDiagnostics = FALSE,
#   runValidation = FALSE
# )


#cohort diagnostics

# ApPhenotypeEvaluation::execute(
#   connectionDetails = connectionDetails,
#   cdmDatabaseSchema = cdmDatabaseSchema,
#   cohortDatabaseSchema = cohortDatabaseSchema,
#   added, not run yet:
#   tempEmulationSchema = tempEmulationSchema,
#   cohortTable = cohortTable,
#   outputFolder = outputFolder,
#   databaseId = databaseId,
#   createCohortTable = FALSE, # TRUE will delete the cohort table and all existing cohorts if already built X_X
#   createCohorts = FALSE,
#   runCohortDiagnostics = TRUE,
#   runValidation = FALSE
# )

# NB: <stanford2> branch doesn't output concept.csv.  This was manually added
# to workdir/workdir/STARR/cohortDiagnostics.


ApPhenotypeEvaluation::execute(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  tempEmulationSchema = tempEmulationSchema,
  cohortDatabaseSchema = cohortDatabaseSchema,
  workDatabaseSchema = cohortDatabaseSchema,
  cohortTable = cohortTable,
  outputFolder = outputFolder,
  databaseId = databaseId,
  createCohortTable = FALSE, # TRUE will delete the cohort table and all existing cohorts if already built X_X
  createCohorts = FALSE,
  runCohortDiagnostics = FALSE,
  runValidation = TRUE
)



# review results ===============================================================
ApPhenotypeEvaluation::compileShinyData(outputFolder)
ApPhenotypeEvaluation::launchResultsExplorer(outputFolder)

## share results ===============================================================
ApPhenotypeEvaluation::shareResults(
  outputFolder = outputFolder,
  keyFileName = "", # data sites will receive via email
  userName = "" # data sites will receive via email
)
