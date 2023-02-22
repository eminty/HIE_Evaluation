localFolder <- "G:/ApPhenotypeEvaluation/DataPartners"
if (!file.exists(localFolder)) {
  dir.create(localFolder, recursive = TRUE)
}

sftpConnection <- OhdsiSharing::sftpConnect(privateKeyFileName = file.path(localFolder, "key.dat"),
                                            userName = "blah")

OhdsiSharing::sftpMkdir(sftpConnection = sftpConnection,
                        remoteFolder = "ApPhenotypeEvaluation")

remoteFiles <- OhdsiSharing::sftpLs(sftpConnection = sftpConnection,
                                    remoteFolder = "ApPhenotypeEvaluation")

remoteFileNames <- remoteFiles$name # or whatever the column name is

OhdsiSharing::sftpGetFiles(sftpConnection = sftpConnection,
                           remoteFileNames = remoteFileNames,
                           localFolder = localFolder,
                           localFileNames = file.path(localFolder, remoteFileNames))

OhdsiSharing::sftpDisconnect(sftpConnection = sftpConnection)
