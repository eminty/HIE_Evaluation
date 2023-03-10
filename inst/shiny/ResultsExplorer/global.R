library(magrittr)

source("R/StartUpScripts.R")
source("R/DisplayFunctions.R")
source("R/Tables.R")
source("R/Plots.R")
source("R/Results.R")

defaultLocalDataFolder <- shinyDataFolder
defaultLocalDataFile <- "PreMerged.RData"

# Settings when running on server:
connectionPool <- NULL
defaultServer <- Sys.getenv("shinydbServer")
defaultDatabase <- Sys.getenv("shinydbDatabase")
defaultPort <- 5432
defaultUser <- Sys.getenv("shinydbUser")
defaultPassword <- Sys.getenv("shinydbPw")
defaultResultsSchema <- 'thrombosisthrombocytopenia'
defaultVocabularySchema <- defaultResultsSchema
alternateVocabularySchema <- c('vocabulary')
defaultDatabaseMode <- FALSE # Use file system if FALSE

appVersionNum <- "Version: 2.2.4"
appInformationText <- paste("Powered by OHDSI Cohort Diagnostics application", paste0(appVersionNum, "."), "This app is working in")

if (defaultDatabaseMode) {
  appInformationText <- paste0(appInformationText, " database")
} else {
  appInformationText <- paste0(appInformationText, " local file")
}
appInformationText <- paste0(appInformationText,
                             " mode. Application was last initiated on ",
                             lubridate::now(tzone = "EST"),
                             " EST. Cohort Diagnostics website is at https://ohdsi.github.io/CohortDiagnostics/")

if (!exists("shinySettings")) {
  writeLines("Using default settings")
  databaseMode <- defaultDatabaseMode & defaultServer != ""

  if (databaseMode) {
    connectionPool <- pool::dbPool(drv = DatabaseConnector::DatabaseConnectorDriver(),
                                   dbms = "postgresql",
                                   server = paste(defaultServer, defaultDatabase, sep = "/"),
                                   port = defaultPort,
                                   user = defaultUser,
                                   password = defaultPassword)
    resultsDatabaseSchema <- defaultResultsSchema
  } else {
    dataFolder <- defaultLocalDataFolder
  }

  vocabularyDatabaseSchemas <- setdiff(x = c(defaultVocabularySchema, alternateVocabularySchema),
                                       y = defaultResultsSchema) %>%
    unique() %>%
    sort()
} else {
  writeLines("Using settings provided by user")
  databaseMode <- !is.null(shinySettings$connectionDetails)
  if (databaseMode) {
    connectionDetails <- shinySettings$connectionDetails
    if (is(connectionDetails$server, "function")) {
      connectionPool <- pool::dbPool(drv = DatabaseConnector::DatabaseConnectorDriver(),
                                     dbms = "postgresql",
                                     server = connectionDetails$server(),
                                     port = connectionDetails$port(),
                                     user = connectionDetails$user(),
                                     password = connectionDetails$password(),
                                     connectionString = connectionDetails$connectionString())
    } else {
      # For backwards compatibility with older versions of DatabaseConnector:
      connectionPool <- pool::dbPool(drv = DatabaseConnector::DatabaseConnectorDriver(),
                                     dbms = "postgresql",
                                     server = connectionDetails$server,
                                     port = connectionDetails$port,
                                     user = connectionDetails$user,
                                     password = connectionDetails$password,
                                     connectionString = connectionDetails$connectionString)
    }
    resultsDatabaseSchema <- shinySettings$resultsDatabaseSchema
    vocabularyDatabaseSchemas <- shinySettings$vocabularyDatabaseSchemas
  } else {
    dataFolder <- shinySettings$dataFolder
  }
}

dataModelSpecifications <- read.csv("resultsDataModelSpecification.csv")
suppressWarnings(rm(list = SqlRender::snakeCaseToCamelCase(dataModelSpecifications$tableName)))

if (databaseMode) {
  onStop(function() {
    if (DBI::dbIsValid(connectionPool)) {
      writeLines("Closing database pool")
      pool::poolClose(connectionPool)
    }
  })
  resultsTablesOnServer <- tolower(DatabaseConnector::dbListTables(connectionPool, schema = resultsDatabaseSchema))
  # vocabularyTablesOnServer <- list()
  # vocabularyTablesInOmopCdm <- c('concept', 'concept_relationship', 'concept_ancestor',
  #                                'concept_class', 'concept_synonym',
  #                                'vocabulary', 'domain', 'relationship')

  # for (i in length(vocabularyDatabaseSchemas)) {
  #   tolower(DatabaseConnector::dbListTables(connectionPool, schema = vocabularyDatabaseSchemas[[i]]))
  # vocabularyTablesOnServer[[i]] <- intersect(x = )
  # }
  loadResultsTable("database", required = TRUE)
  loadResultsTable("cohort", required = TRUE)
  loadResultsTable("temporal_time_ref")
  loadResultsTable("concept_sets")
  loadResultsTable("cohort_count", required = TRUE)

  for (table in c(dataModelSpecifications$tableName)) {
    #, "recommender_set"
    if (table %in% resultsTablesOnServer && !exists(SqlRender::snakeCaseToCamelCase(table)) && !isEmpty(table)) {
      # if table is empty, nothing is returned because type instability concerns.
      assign(SqlRender::snakeCaseToCamelCase(table), dplyr::tibble())
    }
  }
  dataSource <- createDatabaseDataSource(connection = connectionPool,
                                         resultsDatabaseSchema = resultsDatabaseSchema,
                                         vocabularyDatabaseSchema = resultsDatabaseSchema)
} else {
  localDataPath <- file.path(dataFolder, defaultLocalDataFile)
  if (!file.exists(localDataPath)) {
    stop(sprintf("Local data file %s does not exist.", localDataPath))
  }
  dataSource <- createFileDataSource(localDataPath, envir = .GlobalEnv)
}

if (exists("database")) {
  if (nrow(database) > 0 && "vocabularyVersion" %in% colnames(database)) {
    database <- database %>%
      dplyr::mutate(databaseIdWithVocabularyVersion = paste0(databaseId, " (", .data$vocabularyVersion, ")"))
  }
}

if (exists("cohort")) {
  cohort <- get("cohort")
  cohort <- cohort %>%
    dplyr::arrange(.data$cohortId) %>%
    dplyr::mutate(shortName = paste0("C", dplyr::row_number())) %>%
    dplyr::mutate(compoundName = paste0(.data$shortName, ": ", .data$cohortName,"(", .data$cohortId, ")"))
}

if (exists("temporalTimeRef")) {
  temporalCovariateChoices <- get("temporalTimeRef") %>%
    dplyr::mutate(choices = paste0("Start ", .data$startDay, " to end ", .data$endDay)) %>%
    dplyr::select(.data$timeId, .data$choices) %>%
    dplyr::arrange(.data$timeId)
}

if (exists("covariateRef")) {
  specifications <- readr::read_csv(
    file = "Table1Specs.csv",
    col_types = readr::cols(),
    guess_max = min(1e7)
  )
  prettyAnalysisIds <- specifications$analysisId
} else {
  prettyAnalysisIds <- c(0)
}

# loadResultFiles <- function(file) {
#   result <- readr::read_rds(file)
#   return(result)
# }
#
# validationFiles <- list.files(shinyDataFolder, full.names = TRUE, pattern = "validation_results")
# validationMetrics <- lapply(validationFiles, loadResultFiles)
# validationMetrics <- dplyr::bind_rows(validationMetrics)
# validationMetrics$databaseId <- sub("cdm_", "", validationMetrics$cdm)
# validationMetrics$databaseId <- sub("_v", "", validationMetrics$databaseId)
# validationMetrics$databaseId <- gsub("[[:digit:]]+", "", validationMetrics$databaseId)
#
# validationMetrics <- validationMetrics %>%
#   dplyr::mutate(databaseId = sub("cdm_", "", cdm),
#                  databaseId = sub("_v", "", databaseId),
#                  databaseId = gsub("[[:digit:]]+", "", databaseId)) %>%
#   dplyr::select(estimatedPrevalence,
#                 description,
#                 databaseId,
#                 cohortId,
#                 truePositives,
#                 trueNegatives,
#                 falsePositives,
#                 falseNegatives,
#                 specificity,
#                 sensitivity,
#                 ppv,
#                 npv) %>%
#   dplyr::rename(Cohort = description,
#                 TP = truePositives,
#                 TN = trueNegatives,
#                 FP = falsePositives,
#                 FN = falseNegatives,
#                 Prev = estimatedPrevalence,
#                 Sens = sensitivity,
#                 Spec = specificity,
#                 PPV = ppv,
#                 NPV = npv) %>%
#   dplyr::relocate(databaseId, Cohort)
#
# diagnosticModelFiles <- list.files(shinyDataFolder, full.names = TRUE, pattern = "diagnostic_model")
# diagnosticModel <- lapply(diagnosticModelFiles, loadResultFiles)
# diagnosticModel <- dplyr::bind_rows(diagnosticModel)
concept <- read.csv("/workdir/workdir/STARR/cohortDiagnostics/concept.csv")
names(concept) <- SqlRender::snakeCaseToCamelCase(names(concept))
