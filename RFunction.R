require('move')
require('foreach')

rFunction <- function(startTimestamp, endTimestamp, years='ALL', data)
{
  Sys.setenv(tz="GMT") #try

  startday <- as.POSIXlt(startTimestamp)$mday
  startmonth <- as.POSIXlt(startTimestamp)$mon+1
  endday <- as.POSIXlt(endTimestamp)$mday
  endmonth <- as.POSIXlt(endTimestamp)$mon+1
  
  print(paste0("You have selected time between ",startday,"/",startmonth," and ",endday,"/",endmonth," of the years: ", years))
  
  if (years=='ALL')
  {
    years <- unique(as.POSIXlt(timestamps(data))$year+1900)
    logger.info(paste0("You have selected all years of the data set: ",years))
  }
  
  years.vec <- as.numeric(strsplit(years,",")[[1]])
  starts <- strptime(paste0(years.vec,"-",startmonth,"-",startday),format=c("%Y-%m-%d"))
  ends <- strptime(paste0(years.vec,"-",endmonth,"-",endday),format=c("%Y-%m-%d"))
  
  timeitvs <- data.frame("start"=as.POSIXct(starts), "end"=as.POSIXct(ends))
  timeitvs.list <- split(timeitvs, seq(nrow(timeitvs)))
    
  data.split <- move::split(data)
  filt <- foreach(datai = data.split) %:% 
    foreach(ti =timeitvs.list) %do% {
      print(paste(namesIndiv(datai),":",ti$start,"-",ti$end))
      datai[timestamps(datai)>=as.POSIXct(ti$start) & timestamps(datai)<=as.POSIXct(ti$end),]
    }
  names(filt) <- names(data.split)
  
  filt_nozero <- unlist(filt)[unlist(lapply(unlist(filt), length) > 1)] 
  result <- moveStack(filt_nozero)
}
