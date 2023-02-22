# database settings ============================================================
databaseId <- "" # short name with no special characters please :)
cdmDatabaseSchema <- ""
cohortDatabaseSchema <- ""
cohortTable <- "ap_phe_eval"

# local settings ===============================================================
studyFolder <- ""
tempFolder <- ""
options(andromedaTempFolder = tempFolder,
        spipen = 999)
outputFolder <- file.path(studyFolder, databaseId)

# specify connection details ===================================================
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "",
  server = "",
  port = "",
  user = "",
  password = ""
)

# execute study ================================================================
library(magrittr)
ApPhenotypeEvaluation::execute(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTable = cohortTable,
  outputFolder = outputFolder,
  databaseId = databaseId,
  createCohortTable = TRUE, # TRUE will delete the cohort table and all existing cohorts if already built X_X
  createCohorts = TRUE,
  runCohortDiagnostics = TRUE,
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
