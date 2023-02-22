#' @export
runValidation <- function(connectionDetails,
                          cdmDatabaseSchema,
                          cohortDatabaseSchema,
                          workDatabaseSchema,
                          tempEmulationSchema,
                          cohortTable,
                          outputFolder) {

  databaseId <- basename(outputFolder)
  exportFolder <- file.path(outputFolder, "pheValuator")
  if (!file.exists(exportFolder)) {
    dir.create(exportFolder, recursive = TRUE)
  }

  path <- file.path(outputFolder, "cohort_counts.csv")
  cohortCounts <- readr::read_csv(path, show_col_types = FALSE)

  xSpecCount <- cohortCounts$cohortSubjects[cohortCounts$cohortId == 9776]
  dxModelFeasible <- ifelse(xSpecCount >= 500, TRUE, FALSE)

  if (dxModelFeasible) {

    emptyCohortIds <- cohortCounts$cohortId[cohortCounts$cohortSubjects == 0]
    path <- system.file("settings", "PheValuatorAnalysisList.json", package = "ApPhenotypeEvaluation")
    pheValuatorAnalysisList <- PheValuator::loadPheValuatorAnalysisList(path)

    newPheValuatorAnalysisList <- list()
    for (i in 1:length(pheValuatorAnalysisList)) {  # i=1
      pheValuatorAnalysis <- pheValuatorAnalysisList[[i]]
      if (!(pheValuatorAnalysis$testPhenotypeAlgorithmArgs$phenotypeCohortId %in% emptyCohortIds)) {
        newPheValuatorAnalysisList[[length(newPheValuatorAnalysisList) + 1]] <- pheValuatorAnalysis
      }
    }

    pheValReferenceTable <- PheValuator::runPheValuatorAnalyses(
      connectionDetails = connectionDetails,
      cdmDatabaseSchema = cdmDatabaseSchema,
      tempEmulationSchema = tempEmulationSchema,
      cohortDatabaseSchema = cohortDatabaseSchema,
      cohortTable = cohortTable,
      workDatabaseSchema = workDatabaseSchema,
      outputFolder = exportFolder,
      pheValuatorAnalysisList = newPheValuatorAnalysisList
    )

    validationResults <- PheValuator::summarizePheValuatorAnalyses(pheValReferenceTable, exportFolder)
    errMerticCols <- c("sensitivity",
                       "sensitivityCi95Lb",
                       "sensitivityCi95Ub",
                       "ppv",
                       "ppvCi95Lb",
                       "ppvCi95Ub",
                       "specificity",
                       "specificityCi95Lb",
                       "specificityCi95Ub",
                       "npv",
                       "npvCi95Lb",
                       "npvCi95Ub")
    validationResults[, errMerticCols] <- sapply(validationResults[, errMerticCols], as.numeric)
    readr::write_csv(validationResults, file.path(exportFolder, sprintf("validation_results_%s.csv", databaseId)))
    readr::write_rds(validationResults, file.path(exportFolder, sprintf("validation_results_%s.rds", databaseId)))

    path <- file.path(exportFolder, "EvaluationCohort_e1", "plpResults_main", "model", "covariateImportance.csv")
    diagnosticModel <- readr::read_csv(path, show_col_types = FALSE) %>%
      dplyr::select(covariateValue, conceptId, covariateName) %>%
      dplyr::filter(covariateValue != 0) %>%
      dplyr::rename(Beta = covariateValue,
                    ConceptId = conceptId,
                    Covariate = covariateName) %>%
      dplyr::mutate(databaseId = databaseId)
    readr::write_csv(diagnosticModel, file.path(exportFolder, sprintf("diagnostic_model_%s.csv", databaseId)))
    readr::write_rds(diagnosticModel, file.path(exportFolder, sprintf("diagnostic_model_%s.rds", databaseId)))

  } else {
    writeLines("PheValuator diagnostic predictive model infeasible (xSpec cohort count < 500 patients)")
  }
}


