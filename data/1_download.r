# ----------------------------------------------
# BASE
# ----------------------------------------------
rm(list=ls())
source("./base/init.r", chdir=TRUE)
# ----------------------------------------------

# ----------------------------------------------
# CONFIG
# ----------------------------------------------
#REMOVE RAW FILE AFTER DOWNLOAD?
year = 2021
# ----------------------------------------------

# ----------------------------------------------
# PREPARATION / LOAD FILE LISTS
# ----------------------------------------------
rawPath = file.path(folders$data, "raw")
dir.create(rawPath, showWarnings = FALSE, recursive=TRUE)
#hdf5Files = read.table(file.path(folders$tmp, "subset_OMNO2d_003_20210113_112452.txt"), stringsAsFactors = FALSE)
hdf5Files = getURL(paste0(omiURL, year, "/"), ftp.use.epsv = FALSE, dirlistonly = TRUE)
hdf5Files = htmlParse(hdf5Files)
hdf5Files = xpathSApply(hdf5Files, "//a/@href")
hdf5Files = unique(hdf5Files[endsWith(hdf5Files, "he5")])

hdf5Saved = list.files(rawPath, pattern = "\\.he5$", recursive=TRUE)
# ----------------------------------------------


for(i in 1:length(hdf5Files)){
    #i=5500
    #hdf5File = hdf5Files[i,]
    hdf5File = hdf5Files[i]
    hdf5FileName = sub('.*\\/', '', hdf5File)
    
    if(!(substr(hdf5FileName, 20, 23) %in% year) | !endsWith(hdf5FileName, "he5")){
        next
    }
        
    
    if(file.exists(file.path(rawPath, hdf5FileName))){
        next
    }
    
    print(hdf5File)

    url = paste0(paste0(omiURL, year, "/", hdf5File))
    download.file(url,
                  destfile = file.path(rawPath, hdf5FileName),
                  quiet = TRUE,
                  method="wget",
                  extra=paste0("--user=", authUser, " --password=", authPassword))
    
    print("Downloading completed. Next.")
    gc()
}

