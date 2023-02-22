image_tag <- ""
local_folder <-  ""
gcloud_local_folder <- ""
user <- ""
password <- ""
forwarded_port <- 9001

bash_string <- sprintf("sudo docker run -d -v %s:/workdir/workdir -v %s:/workdir/gcloud --name=proneNlp -p %s:8787 -e ROOT=TRUE -e USER=%s -e PASSWORD=%s %s",
local_folder,
gcloud_local_folder,
forwarded_port,
user,
password,
image_tag)

print(bash_string)
system(bash_string)