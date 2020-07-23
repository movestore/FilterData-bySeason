require('move')
require('foreach')

rFunction <- function(startTimestamp, endTimestamp, years='ALL', data)
{
  Sys.setenv(tz="GMT")

  startday <- as.POSIXlt(startTimestamp,tz="GMT")$mday
  startmonth <- as.POSIXlt(startTimestamp,tz="GMT")$mon+1
  endday <- as.POSIXlt(endTimestamp,tz="GMT")$mday
  endmonth <- as.POSIXlt(endTimestamp,tz="GMT")$mon+1
  
  print(paste0("You have selected time between ",startday,"/",startmonth," and ",endday,"/",endmonth," of the years: ", years))
  
  if (years=='ALL')
  {
    years.vec <- unique(as.POSIXlt(timestamps(data),tz="GMT")$year+1900)
    logger.info(paste0("You have selected all years of the data set: ",paste(years.vec,collapse=", ")))
  } else years.vec <- as.numeric(strsplit(years,",")[[1]])
  
  starts <- strptime(paste0(years.vec,"-",startmonth,"-",startday),format=c("%Y-%m-%d"),tz="GMT")
  ends <- strptime(paste0(years.vec,"-",endmonth,"-",endday),format=c("%Y-%m-%d"),tz="GMT")
  len <- length(ends)
  
  # adapt for ranges that cross NY
  if (starts[1]>ends[1])
  {
    starts <- c(strptime(paste0(years.vec[1],"-",1,"-",1),format=c("%Y-%m-%d"),tz="GMT"),starts)
    ends <- c(ends,strptime(paste0(years.vec[len],"-",12,"-",31),format=c("%Y-%m-%d"),tz="GMT"))
  }
  
  timeitvs <- data.frame("start"=as.POSIXct(starts,tz="GMT"), "end"=as.POSIXct(ends,tz="GMT"))
  timeitvs.list <- split(timeitvs, seq(nrow(timeitvs)))
    
  data.split <- move::split(data)
  filt <- foreach(datai = data.split) %:% 
    foreach(ti =timeitvs.list) %do% {
      print(paste(namesIndiv(datai),":",ti$start,"-",ti$end))
      datai[timestamps(datai)>=as.POSIXct(ti$start) & timestamps(datai)<=as.POSIXct(ti$end),]
    }
  names(filt) <- names(data.split)

  if (all(unlist(lapply(unlist(filt), length))==0)) #if there remain no data at all
  {
    logger.info("!None of your data lie in the requested season. Reselect data set or time frame. Here return input data set") #moveStack does not allow empty objects
    result <- data
  } else
  {
    if (any(unlist(lapply(unlist(filt), length))==0))
    {
      filt_nozero <- unlist(filt)[unlist(lapply(unlist(filt), length) > 0)] #allow move elements of length 1
      result <- moveStack(filt_nozero)
    } else result <- filt
  }
  result
}
