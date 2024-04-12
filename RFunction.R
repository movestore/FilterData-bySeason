library('move2')
require('foreach')
library('lubridate')
library('dplyr')

## The parameter "data" is reserved for the data object passed on from the previous app

# to display messages to the user in the log file of the App in MoveApps
# one can use the function from the logger.R file:
# logger.fatal(), logger.error(), logger.warn(), logger.info(), logger.debug(), logger.trace()

rFunction <- function(startTimestamp=NULL, endTimestamp=NULL, years=NULL,filter=TRUE, season=NULL, splitt=FALSE, data)
{
  Sys.setenv(tz="UTC")

  if (is.null(years))
  {
    years.vec <- unique(as.POSIXlt(mt_time(data),tz="UTC")$year+1900)
    logger.info(paste0("You have selected all years of the data set: ",paste(years.vec,collapse=", ")))
  } else 
  {
    years.vec <- as.numeric(strsplit(years,",")[[1]])
    logger.info(paste("You have selected to filter for the following years:",paste(years.vec,collapse=", ")))
  }
  
  if (is.null(startTimestamp) | is.null(endTimestamp))
  {
    logger.info("You did not provide a start and/or end timestamp. So it is not possible to filter for a season. The whole data set of the selected years is returned.")
    if (is.null(years)) result <- data else result <- data[which((as.POSIXlt(mt_times(data))$year+1900) %in% years.vec),]
  } else
  {
    startLT <- as.POSIXlt(startTimestamp,format="%Y-%m-%dT%H:%M:%OSZ",tz="UTC")
    startday <- paste0(startLT$mon+1,"-",startLT$mday," ",startLT$hour,":",startLT$min,":",startLT$sec)
    endLT <- as.POSIXlt(endTimestamp,format="%Y-%m-%dT%H:%M:%OSZ",tz="UTC")
    endday <- paste0(endLT$mon+1,"-",endLT$mday," ",endLT$hour,":",endLT$min,":",endLT$sec)
    
    logger.info(paste0("You have selected time between ",startday," and ",endday," of the years: ", paste(years.vec,collapse=", ")))
    
    if (is.null(season))
    {
      logger.info(paste0("You have not provided a name for your season to appear in the annotaiton column. Based on your selected time range we set it to: ",startday," to ",endday,"."))
      season <- paste(startday,"to",endday)
    } else logger.info(paste0("You have provided that you season is called: ",season,". This name will appear in the annotation column."))
    
    starts <- strptime(paste0(years.vec,"-",startday),format=c("%Y-%m-%d %H:%M:%S"),tz="UTC")
    ends <- strptime(paste0(years.vec,"-",endday),format=c("%Y-%m-%d %H:%M:%S"),tz="UTC")
    len <- length(ends)
    
    # adapt for ranges that cross NY, changed in 2024 to only add one year
    if (starts[1]>ends[1])
    {
      #starts <- c(strptime(paste0(years.vec[1],"-",1,"-",1," ",0,":",0,":",0),format=c("%Y-%m-%d %H:%M:%S"),tz="UTC"),starts)
      #ends <- c(ends,strptime(paste0(years.vec[len],"-",12,"-",31," ",23,":",59,":",59),format=c("%Y-%m-%d %H:%M:%S"),tz="UTC"))
      ends <- ends + years(1)
    }
    
    timeitvs <- data.frame("start"=as.POSIXct(starts,tz="UTC"), "end"=as.POSIXct(ends,tz="UTC"))
    timeitvs.list <- split(timeitvs, seq(nrow(timeitvs)))
    
    if (!any(names(data)=="season")) data$season <- "none" #add column if it is not yet there
    
    data.split <- split(data, mt_track_id(data))
    filt <- foreach(datai = data.split) %:% 
      foreach(ti =timeitvs.list) %do% {
        logger.info(paste(unique(mt_track_id(datai)),":",ti$start,"-",ti$end))
        ix <- which(mt_time(datai)>=as.POSIXct(ti$start) & mt_time(datai)<=as.POSIXct(ti$end))
        if (any(ix)) datai$season[ix] <- season #added annotation
        if (filter==TRUE) datai[mt_time(datai)>=as.POSIXct(ti$start) & mt_time(datai)<=as.POSIXct(ti$end),] else datai
        }
    names(filt) <- names(data.split)
    
    if (filter==TRUE)
    {
      if (splitt==FALSE)
      {
        logger.info("Your data will be filtered to the selected season, but not split to separate tracks. Note that this might lead to unrealistic steps.")
        timeitvs.list %>% bind_rows() %>% mutate(int=interval(start,end)) %>% pull(int) ->ints #help from BartK :)
        filtf <- data[mt_time(data) %within% split(ints, 1:length(ints)),]
      }
      if (splitt==TRUE)
      {
        logger.info("Your data will be filtered to the selected season and split to separate tracks per year. This will exclude unrealistic steps.")
        filt <-  setNames(lapply(seq_along(filt), function(x) {
          yrs <- unlist(lapply(filt[[x]], function(y) min(year(mt_time(y)[1]))))
          setNames(filt[[x]],yrs)
        }), names(filt))
        
        filt_spl <- unlist(filt,recursive=FALSE)
        len_spl <- as.numeric(lapply(filt_spl,function(x) nrow(x)))
        filt_spl_nn <- filt_spl[len_spl>0]
        
        filtf <- mt_stack(filt_spl_nn,.track_combine="rename") #the names should include the year, but this takes too much time now to figure out. later
      }
      
      if (nrow(filtf)==0) #if there remain no data at all
      {
        logger.info("!None of your data lie in the requested season. Reselect data set or time frame. Return NULL.") #moveStack does not allow empty objects
        result <- NULL
      } else result <- filtf
    } else #if want to only annotate season (above datai returned after each time interval)
    {
      logger.info("You have selected to not filter your tracks for the season, but only annotate them with an extra column indicating the selected season. The input tracks are returned with extra column.")
      
      timeitvs.list %>% bind_rows() %>% mutate(int=interval(start,end)) %>% pull(int) ->ints #help from BartK :)
      data$season[mt_time(data) %within% split(ints, 1:length(ints))] <- season
      result <- data
      
      if (splitt==TRUE) logger.info("You have selected to split your tracks by filtered season, but requested to NOT filter the tracks. That is not possible. If you want to split your tracks by season, select filter=TRUE. Now, the input tracks are returned with extra column (same as for setting filter=FALSE and split=FALSE).")
    }
  }

  result
}



