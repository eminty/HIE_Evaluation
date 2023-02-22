pathToCsv <- system.file("settings", "CohortsToCreate.csv", package = "ApPhenotypeEvaluation")
cohortDefinitionSet <- readr::read_csv(pathToCsv, show_col_types = FALSE)

xSpecCohortId <- 9776
xSensCohortId <- 9569
prevCohortId <- 9570
evalCohortId <- 9571

testPhenotypeId1 <- 9574 # [pheWg] acute pancreatitis
testPhenotypeId2 <- 9575 # [pheWg] acute pancreatitis without chronic pancreatitis
testPhenotypeId3 <- 9578 # [pheWg] acute pancreatitis without chronic, alcoholic pancreatitis, biliary disease, ercp
testPhenotypeId4 <- 9777 # [pheWg] acute pancreatitis IP (Razavi)
testPhenotypeId5 <- 9779 # [pheWg] acute pancreatitis IP with no prior or concurrent chronic pancreatitis (Saligram)

evalCohortArgs <- PheValuator::createCreateEvaluationCohortArgs(
  xSpecCohortId = xSpecCohortId,
  xSensCohortId = xSensCohortId,
  prevalenceCohortId = prevCohortId,
  evaluationPopulationCohortId = evalCohortId,
  covariateSettings = PheValuator::createDefaultAcuteCovariateSettings(
    excludedCovariateConceptIds = c(4243504, 195596), # subacute and chronic pancreatitis
    addDescendantsToExclude = TRUE,
    startDayWindow1 = 0,
    endDayWindow1 = 10,
    startDayWindow2 = 11,
    endDayWindow2 = 20,
    startDayWindow3 = 21,
    endDayWindow3 = 30),
  lowerAgeLimit = 0,
  upperAgeLimit = 120,
  startDate = "20100101",
  endDate = "21000101"
)

analysis1 <- PheValuator::createPheValuatorAnalysis(
  analysisId = 1,
  description = cohortDefinitionSet$cohortName[cohortDefinitionSet$cohortId == xSpecCohortId],
  createEvaluationCohortArgs = evalCohortArgs,
  testPhenotypeAlgorithmArgs = PheValuator::createTestPhenotypeAlgorithmArgs(phenotypeCohortId = xSpecCohortId)
)

analysis2 <- PheValuator::createPheValuatorAnalysis(
  analysisId = 2,
  description = cohortDefinitionSet$cohortName[cohortDefinitionSet$cohortId == xSensCohortId],
  createEvaluationCohortArgs = evalCohortArgs,
  testPhenotypeAlgorithmArgs = PheValuator::createTestPhenotypeAlgorithmArgs(phenotypeCohortId = xSensCohortId)
)

analysis3 <- PheValuator::createPheValuatorAnalysis(
  analysisId = 3,
  description = cohortDefinitionSet$cohortName[cohortDefinitionSet$cohortId == prevCohortId],
  createEvaluationCohortArgs = evalCohortArgs,
  testPhenotypeAlgorithmArgs = PheValuator::createTestPhenotypeAlgorithmArgs(phenotypeCohortId = prevCohortId)
)

# to test
analysis4 <- PheValuator::createPheValuatorAnalysis(
  analysisId = 4,
  description = cohortDefinitionSet$cohortName[cohortDefinitionSet$cohortId == testPhenotypeId1],
  createEvaluationCohortArgs = evalCohortArgs,
  testPhenotypeAlgorithmArgs = PheValuator::createTestPhenotypeAlgorithmArgs(phenotypeCohortId = testPhenotypeId1)
)

analysis5 <- PheValuator::createPheValuatorAnalysis(
  analysisId = 5,
  description = cohortDefinitionSet$cohortName[cohortDefinitionSet$cohortId == testPhenotypeId2],
  createEvaluationCohortArgs = evalCohortArgs,
  testPhenotypeAlgorithmArgs = PheValuator::createTestPhenotypeAlgorithmArgs(phenotypeCohortId = testPhenotypeId2)
)

analysis6 <- PheValuator::createPheValuatorAnalysis(
  analysisId = 6,
  description = cohortDefinitionSet$cohortName[cohortDefinitionSet$cohortId == testPhenotypeId3],
  createEvaluationCohortArgs = evalCohortArgs,
  testPhenotypeAlgorithmArgs = PheValuator::createTestPhenotypeAlgorithmArgs(phenotypeCohortId = testPhenotypeId3)
)

analysis7 <- PheValuator::createPheValuatorAnalysis(
  analysisId = 7,
  description = cohortDefinitionSet$cohortName[cohortDefinitionSet$cohortId == testPhenotypeId4],
  createEvaluationCohortArgs = evalCohortArgs,
  testPhenotypeAlgorithmArgs = PheValuator::createTestPhenotypeAlgorithmArgs(phenotypeCohortId = testPhenotypeId4)
)

analysis8 <- PheValuator::createPheValuatorAnalysis(
  analysisId = 8,
  description = cohortDefinitionSet$cohortName[cohortDefinitionSet$cohortId == testPhenotypeId5],
  createEvaluationCohortArgs = evalCohortArgs,
  testPhenotypeAlgorithmArgs = PheValuator::createTestPhenotypeAlgorithmArgs(phenotypeCohortId = testPhenotypeId5)
)

analysisList <- list(analysis1,
                     analysis2,
                     analysis3,
                     analysis4,
                     analysis5,
                     analysis6,
                     analysis7,
                     analysis8)

PheValuator::savePheValuatorAnalysisList(analysisList, file.path("inst/settings", "PheValuatorAnalysisList.json"))
