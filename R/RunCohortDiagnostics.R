#' @export
runCohortDiagnostics <- function(connectionDetails,
                                 cdmDatabaseSchema,
                                 cohortDatabaseSchema,
                                 cohortTable,
                                 outputFolder,
                                 tempEmulationSchema,
                                 databaseId) {

  exportFolder <- file.path(outputFolder, "cohortDiagnostics")
  if (!file.exists(exportFolder)) {
    dir.create(exportFolder, recursive = TRUE)
  }

  pathToCsv <- system.file("settings", "CohortsToCreate.csv", package = "ApPhenotypeEvaluation")
  cohortDefinitionSet <- readr::read_csv(pathToCsv, show_col_types = FALSE) %>%
    dplyr::filter(cohortId %in% c(9574, 9575, 9578, 9777, 9779))

  CohortDiagnostics::runCohortDiagnostics(
    packageName = "ApPhenotypeEvaluation",
    cohortDefinitionSet = cohortDefinitionSet,
    connectionDetails = connectionDetails,
    cdmDatabaseSchema = cdmDatabaseSchema,
    cohortDatabaseSchema = cohortDatabaseSchema,
    tempEmulationSchema = tempEmulationSchema,
    cohortTable = cohortTable,
    cohortTableNames = CohortGenerator::getCohortTableNames(cohortTable = cohortTable),
    exportFolder = exportFolder,
    databaseId = databaseId,
    databaseName = databaseId,
    databaseDescription = databaseId,
    runInclusionStatistics = FALSE,
    runIncludedSourceConcepts = FALSE,
    runOrphanConcepts = FALSE,
    runTimeDistributions = FALSE,
    runVisitContext = TRUE,
    runBreakdownIndexEvents = FALSE,
    runIncidenceRate = TRUE,
    runTimeSeries = FALSE,
    runCohortOverlap = TRUE,
    runCohortCharacterization = TRUE,
    covariateSettings = FeatureExtraction::createDefaultCovariateSettings(),
    runTemporalCohortCharacterization = TRUE,
    temporalCovariateSettings = FeatureExtraction::createTemporalCovariateSettings(
      useConditionOccurrence = TRUE,
      useDrugEraStart = TRUE,
      useProcedureOccurrence = TRUE,
      useMeasurement = TRUE,
      temporalStartDays = c(-365, -30, 0, 1, 31),
      temporalEndDays = c(-31, -1, 0, 30, 365)
    ),
    minCellCount = 10,
    incremental = TRUE,
    incrementalFolder = file.path(exportFolder, "incremental")
  )
  CohortDiagnostics::preMergeDiagnosticsFiles(exportFolder)
}
