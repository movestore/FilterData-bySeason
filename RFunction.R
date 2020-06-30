library('move')
library('foreach')

rFunction <- function(startTimestamps=NULL, endTimestamps=NULL, data)
{
  Sys.setenv(tz="GMT") #can this be used??

  logger.info(paste0("You have selected ",length(startTimestamps), " start time intervals and ",length(endTimestamps)," end time intervals."))
  
  if (is.null(startTimestamps))
  {
    logger.info(paste0("No starting time(s) provided, first timestamp of data used."))
    startTimestamps <- min(timestamps(data))
  }
  
  if (is.null(endTimestamps))
  {
    logger.info(paste0("No end time(s) provided, last timestamp of data used."))
    endTimestamps <- max(timestamps(data))
  }
  
  if (length(startTimestamps)!=length(endTimestamps)) 
  {
    logger.info("starting timestamps and end timestamps have different length, please correct. Return full data set.")
    result <- data
  } else
  {
    timeitvs <- data.frame("start"=as.POSIXct(startTimestamps), "end"=as.POSIXct(endTimestamps))
    timeitvs.list <- split(timeitvs, seq(nrow(timeitvs)))
    
    data.split <- split(data)
    filt <- foreach(datai = data.split) %:% 
      foreach(ti =timeitvs.list) %do% {
        print(paste(namesIndiv(datai),":",ti$start,"-",ti$end))
        datai[timestamps(datai)>=as.POSIXct(ti$start) & timestamps(datai)<=as.POSIXct(ti$end),]
      }
    names(filt) <- names(data.split)
    
    filt_nozero <- unlist(filt)[unlist(lapply(unlist(filt), length) > 1)] 
    result <- moveStack(filt_nozero)
  }
  
  result  
}
