#' @export
execute <- function(connectionDetails,
                    cdmDatabaseSchema,
                    cohortDatabaseSchema,
                    tempEmulationSchema,
                    workDatabaseSchema,
                    cohortTable,
                    outputFolder,
                    databaseId,
                    createCohortTable = FALSE,
                    createCohorts = FALSE,
                    runCohortDiagnostics = FALSE,
                    runValidation = FALSE) {

  if (createCohortTable) {
    cohortTableNames <- CohortGenerator::getCohortTableNames(cohortTable = cohortTable)
    CohortGenerator::createCohortTables(connectionDetails = connectionDetails,
                                        cohortTableNames = cohortTableNames,
                                        cohortDatabaseSchema = cohortDatabaseSchema)
  }

  if (createCohorts) {
    ApPhenotypeEvaluation::createCohorts(connectionDetails = connectionDetails,
                                         cdmDatabaseSchema = cdmDatabaseSchema,
                                         cohortDatabaseSchema = cohortDatabaseSchema,
                                         cohortTable = cohortTable,
                                         outputFolder = outputFolder)
  }

  if (runCohortDiagnostics) {
    ApPhenotypeEvaluation::runCohortDiagnostics(connectionDetails = connectionDetails,
                                                cdmDatabaseSchema = cdmDatabaseSchema,
                                                cohortDatabaseSchema = cohortDatabaseSchema,
                                                tempEmulationSchema = tempEmulationSchema,
                                                cohortTable = cohortTable,
                                                outputFolder = outputFolder,
                                                databaseId = databaseId)
  }

  if (runValidation) {
    ApPhenotypeEvaluation::runValidation(connectionDetails = connectionDetails,
                                         cdmDatabaseSchema = cdmDatabaseSchema,
                                         cohortDatabaseSchema = cohortDatabaseSchema,
                                         workDatabaseSchema = workDatabaseSchema,
                                         tempEmulationSchema = tempEmulationSchema,
                                         cohortTable = cohortTable,
                                         outputFolder = outputFolder)
  }
}
