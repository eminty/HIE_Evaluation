Acute pancreatitis phenotype evaluation
=============

<img src="https://img.shields.io/badge/Study%20Status-Repo%20Created-lightgray.svg" alt="Study Status: Repo Created"/>

-   Analytics use case(s): **Characterization**
-   Study type: **Clinical Application**
-   Tags: **OHDSI2022**
-   Study lead: **James Weaver**
-   Study lead forums tag: [**jweave17**](https://forums.ohdsi.org/u/jweave17/)
-   Study start date: **29 Sept 2022**
-   Study end date: **-**
-   Protocol: **-**
-   Publications: **-**
-   Results explorer: [**Shiny app**](https://data.ohdsi.org/)

**Title:** Validating acute pancreatitis using a probabilistic reference standard supported by comprehensive clinical characterization

**Description:** Medical condition misclassification is acknowledged but rarely estimated in observational health sciences research. In this study, we use a probabilistic reference standard validation method to rapidly estimate the measurement errors of 5 phenotype definitions for acute pancreatitis without manual chart review. Further, this study comprehensively characterizes the cohorts returned by these phenotype definitions.

This study is part of the Phenotype Development and Evaluation Workgroup activity at the [2022 OHDSI Symposium](https://www.ohdsi.org/ohdsi2022symposium/).

Study execution
==========

1. Use one `R` session only. Close other open `R` sessions before beginning. Open a new `R` script from which you will run the code that installs the `ApPhenotypeEvaluation` package to a new local directory. There is no need to clone the `ApPhenotypeEvaluation` package and open it as an `R` project. Copy the following code into the blank script and replace `C:/ApPhenotypeEvaluation` with a local directory location of your choice. The `ApPhenotypeEvaluation` package and all of its dependencies will be downloaded to this location. This local directory should not be where your `R` libraries are stored. This is an independent package environment for this study.

  ```r
  install.packages("renv")
  packageLocation <- "C:/ApPhenotypeEvaluation" # will need >=510MB of disk space for all packages and dependencies
  if (!file.exists(packageLocation)) {
    dir.create(packageLocation, recursive = TRUE)
  }
  setwd(packageLocation)
  download.file("https://raw.githubusercontent.com/ohdsi-studies/ApPhenotypeEvaluation/main/renv.lock", "renv.lock")
  renv::init()
  ```
2. If/when asked if the project already has a lockfile, select "1: Restore the project from the lockfile.".

3. Modify the code below to add your specifications and execute the study. Replace `C:/StudyResults/ApPhenotypeEvaluation` and `C:/AndromedaTemp` with local directories of your choice. Your final and intermediary files will be saved in these locations. If you are asked to install additional packages during study execution, reply "y" to install, make note of which packages were installed, and please inform the study coordinator.

  ```r
  # database settings ==========================================================
  databaseId <- "my_cdm" # a short name of your database with no special characters please :)
  cdmDatabaseSchema <- "my_cdm_v12345"
  cohortDatabaseSchema <- "my_database" # must have write access
  cohortTable <- "my_cohort_table"
  
  # local settings =============================================================
  studyFolder <- "C:/ApPheEvalResults/" # will need >=250MB of disk space for all intermediary and final results files
  tempFolder <- "C:/AndromedaTemp"
  options(andromedaTempFolder = tempFolder,
          spipen = 999)
  outputFolder <- file.path(studyFolder, databaseId)
  
  # specify connection details =================================================
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = "",
    server = "",
    port = "",
    user = "",
    password = ""
  )
  
  # execute study ==============================================================
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
  ```
  
  4. Compile and review results.
  
  ```r
  # review results =============================================================
  ApPhenotypeEvaluation::compileShinyData(outputFolder)
  ApPhenotypeEvaluation::launchResultsExplorer(outputFolder)
  ```
  
  5. Share the results with the study coordinator. You will receive your study site username and private key file for uploading results to the OHSI SFTP server. Please inform the study coordinator when your results have been uploaded.
  
  ```r
  # share results =============================================================
  ApPhenotypeEvaluation::shareResults(
    outputFolder = outputFolder,
    keyFileName = "", # data sites will receive via email
    userName = "" # data sites will receive via email
  )
  ```
