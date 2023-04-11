require('move')
require('foreach')
library('lubridate')

rFunction <- function(startTimestamp=NULL, endTimestamp=NULL, years='ALL', data)
{
  Sys.setenv(tz="UTC")

  if (years=='ALL')
  {
    years.vec <- unique(as.POSIXlt(timestamps(data),tz="UTC")$year+1900)
    logger.info(paste0("You have selected all years of the data set: ",paste(years.vec,collapse=", ")))
  } else 
  {
    years.vec <- as.numeric(strsplit(years,",")[[1]])
    logger.info(paste("You have selected to filter for the following years:",paste(years.vec,collapse=", ")))
  }
  
  if (is.null(startTimestamp) | is.null(endTimestamp))
  {
    logger.info("You did not provide a start and/or end timestamp. So it is not possible to filter for a season. The whole data set of the selected years is returned.")
    if (years=='ALL') result <- data else result <- data[which((as.POSIXlt(timestamps(data))$year+1900) %in% years.vec),]
  } else
  {
    startLT <- as.POSIXlt(startTimestamp,format="%Y-%m-%dT%H:%M:%OSZ",tz="UTC")
    startday <- paste0(startLT$mon+1,"-",startLT$mday," ",startLT$hour,":",startLT$min,":",startLT$sec)
    endLT <- as.POSIXlt(endTimestamp,format="%Y-%m-%dT%H:%M:%OSZ",tz="UTC")
    endday <- paste0(endLT$mon+1,"-",endLT$mday," ",endLT$hour,":",endLT$min,":",endLT$sec)
    
    print(paste0("You have selected time between ",startday," and ",endday," of the years: ", years))
    
    starts <- strptime(paste0(years.vec,"-",startday),format=c("%Y-%m-%d %H:%M:%S"),tz="UTC")
    ends <- strptime(paste0(years.vec,"-",endday),format=c("%Y-%m-%d %H:%M:%S"),tz="UTC")
    len <- length(ends)
    
    # adapt for ranges that cross NY
    if (starts[1]>ends[1])
    {
      starts <- c(strptime(paste0(years.vec[1],"-",1,"-",1," ",0,":",0,":",0),format=c("%Y-%m-%d %H:%M:%S"),tz="UTC"),starts)
      ends <- c(ends,strptime(paste0(years.vec[len],"-",12,"-",31," ",23,":",59,":",59),format=c("%Y-%m-%d %H:%M:%S"),tz="UTC"))
    }
    
    timeitvs <- data.frame("start"=as.POSIXct(starts,tz="UTC"), "end"=as.POSIXct(ends,tz="UTC"))
    timeitvs.list <- split(timeitvs, seq(nrow(timeitvs)))
    
    data.split <- move::split(data)
    filt <- foreach(datai = data.split) %:% 
      foreach(ti =timeitvs.list) %do% {
        print(paste(namesIndiv(datai),":",ti$start,"-",ti$end))
        datai[timestamps(datai)>=as.POSIXct(ti$start) & timestamps(datai)<=as.POSIXct(ti$end),]
      }
    names(filt) <- names(data.split)
    
    filt <-  setNames(lapply(seq_along(filt), function(x) {
      yrs <- lapply(filt[[x]], function(y) year(timestamps(y)[1]))
      setNames(filt[[x]],yrs)
      }), names(filt))
    
    filt_nozero <- unlist(filt)[unlist(lapply(unlist(filt), length) > 0)] #allow move elements of length 1
    
    if (length(filt_nozero)==0) #if there remain no data at all
    {
      logger.info("!None of your data lie in the requested season. Reselect data set or time frame. Return NULL.") #moveStack does not allow empty objects
      result <- NULL
    } else result <- moveStack(filt_nozero)
  }

  result
}
