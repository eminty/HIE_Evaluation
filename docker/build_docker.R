# NOTE: before running this script be sure to set the 
# working directory to the location of the Dockerfile

bashstring <- "sudo docker build -t eminty/ap_phenotype_evaluation:0.1 ."
system(bashstring)

