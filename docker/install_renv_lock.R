# enviroment paths
working_directory <- "/workdir"
study_package_directory <- "/workdir/ApPhenotypeEvaluation"
renv_package_version <- '0.13.2'

# Install Renv
install.packages('remotes')
remotes::install_github(paste0('rstudio/renv@',renv_package_version))

# Build the local library
renv::restore(rebuild=T,
              prompt=FALSE
              )
                         