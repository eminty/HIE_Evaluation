#' @export
createCohorts <- function(connectionDetails,
                          cdmDatabaseSchema,
                          cohortDatabaseSchema,
                          cohortTable,
                          outputFolder) {

  if (!file.exists(outputFolder)) {
    dir.create(outputFolder, recursive = TRUE)
  }

  cohortTableNames <- CohortGenerator::getCohortTableNames(cohortTable = cohortTable)
  pathToCsv <- system.file("settings", "CohortsToCreate.csv", package = "ApPhenotypeEvaluation")
  cohortDefinitionSet <- readr::read_csv(pathToCsv, show_col_types = FALSE)
  cohortsGenerated <- CohortGenerator::generateCohortSet(connectionDetails = connectionDetails,
                                                         cdmDatabaseSchema = cdmDatabaseSchema,
                                                         cohortDatabaseSchema = cohortDatabaseSchema,
                                                         cohortTableNames = cohortTableNames,
                                                         cohortDefinitionSet = cohortDefinitionSet)

  cohortCounts <- CohortGenerator::getCohortCounts(connectionDetails = connectionDetails,
                                                   cohortDatabaseSchema = cohortDatabaseSchema,
                                                   cohortTable = cohortTableNames$cohortTable)

  cohortCounts <- dplyr::left_join(cohortDefinitionSet[, c("cohortId", "cohortName")], cohortCounts) %>%
    dplyr::mutate(dplyr::across(where(is.numeric), ~ tidyr::replace_na(.x, 0)))
  readr::write_csv(cohortCounts, file.path(outputFolder, "cohort_counts.csv"))
}
