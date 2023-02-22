#' @export
shareResults <- function(outputFolder,
                         keyFileName,
                         userName) {

  databaseId <- basename(outputFolder)

  cdZipFile <- file.path(outputFolder, "cohortDiagnostics", sprintf("Results_%s.zip", databaseId))
  OhdsiSharing::sftpUploadFile(privateKeyFileName = keyFileName,
                               userName = userName,
                               remoteFolder = "appheeval",
                               fileName = cdZipFile)

  shinyZipFile <- file.path(outputFolder, "shinyData", sprintf("shiny_data_%s.zip", databaseId))

  OhdsiSharing::sftpUploadFile(privateKeyFileName = keyFileName,
                               userName = userName,
                               remoteFolder = "appheeval",
                               fileName = shinyZipFile)
}
