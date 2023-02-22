#' @export
compileShinyData <- function(outputFolder) {

  shinyDataFolder <- file.path(outputFolder, "shinyData")
  if (!file.exists(shinyDataFolder)) {
    dir.create(shinyDataFolder)
  }

  databaseId <- basename(outputFolder)

  cdFile <- file.path(outputFolder, "cohortDiagnostics", "PreMerged.RData")
  validationFile <- file.path(outputFolder, "pheValuator", sprintf("validation_results_%s.rds", databaseId))
  dxModelFile <- file.path(outputFolder, "pheValuator", sprintf("diagnostic_model_%s.rds", databaseId))

  if (file.exists(validationFile)) {
    shinyFiles <- c(cdFile,
                    validationFile,
                    dxModelFile)
  } else {
    shinyFiles <- cdFile
  }

  file.copy(from = shinyFiles,
            to = shinyDataFolder,
            overwrite = TRUE)

  shinyDataZipFile <- file.path(shinyDataFolder, sprintf("shiny_data_%s.zip", databaseId))
  DatabaseConnector::createZipFile(zipFile = shinyDataZipFile, files = shinyFiles)
}


#' @export
launchResultsExplorer <- function(outputFolder) {
  .GlobalEnv$shinyDataFolder <- file.path(outputFolder, "shinyData")
  appDir <- system.file("shiny", "ResultsExplorer", package = "ApPhenotypeEvaluation")
  shiny::runApp(appDir = appDir)
}

