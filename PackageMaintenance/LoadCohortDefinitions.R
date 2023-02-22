library(magrittr)
baseUrl <- Sys.getenv("BASE_URL")
ROhdsiWebApi::authorizeWebApi(baseUrl, "windows")

# acute pancreatitis cohorts ===================================================
cohortIds <- c(9776, # [pheWg] acute pancreatitis xSpec no subacute chronic
               9569, # [pheWg] acute pancreatitis xSens
               9570, # [pheWg] acute pancreatitis prev
               9571, # [pheWg] acute pancreatitis eval
               9574, # [pheWg] acute pancreatitis
               9575, # [pheWg] acute pancreatitis without chronic pancreatitis
               9578, # [pheWg] acute pancreatitis without chronic, alcoholic pancreatitis, biliary disease, ercp
               9777, # [pheWg] acute pancreatitis IP (Razavi)
               9779) # [pheWg] acute pancreatitis IP with no prior or concurrent chronic pancreatitis (Saligram)

cohortDefinitionSet <- ROhdsiWebApi::exportCohortDefinitionSet(
  baseUrl = baseUrl,
  cohortIds = cohortIds,
  generateStats = TRUE
)

CohortGenerator::saveCohortDefinitionSet(
  cohortDefinitionSet = cohortDefinitionSet,
  settingsFileName = "inst/settings/CohortsToCreate.csv",
  jsonFolder = "inst/cohorts",
  sqlFolder = "inst/sql/sql_server"
)

readr::write_csv(cohortDefinitionSet, "inst/settings/CohortsToCreate.csv") # sql and json dont save when using saveCohortDefinitionSet X_X

# rebuild package before running CreateValidationSEttings.R

