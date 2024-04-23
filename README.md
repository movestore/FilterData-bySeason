# Filter/Annotate by Season
MoveApps

Github repository: *github.com/movestore/FilterData-bySeason*

## Description
Select or annotate records that fall within a selected time range and years. For example, this could be used to reduce the data to the spring migration seasons of 2013 and 2014, or to retain all records but label those occurring during this season.

## Documentation
This App annotates or filters the data based on a user-defined seasonal time interval for a selection of years. The start and end of the season can be defined with up to seconds precision. The user can specify one or more years to include, or (by default) include all years in the data set. 

If the data are filtered, tracks can be split by year. In this case, the output data set will contain new track names composed of the existing track IDs and the year of the first location of the track.

Records within the defined season are identified in the output data set using a new data attribute `season`.

### Input data
move2 location object

### Output data
move2 location object

### Artefacts
none

### Settings
**Start of your season (`startTimestamp`):** interactively select a timestamp with year, month, day, hour, minute and second. The year in this timestamp is not used for the analysis. Using an unrealistic year can help to indicate that this is ignored. Example: “1800-11-09 12:00:00”. Records are assessed based on values in the attribute `timestamp`.

**End of your season (UTC) (`endTimestamp`):** interactively select a timestamp with year, month, day, hour, minute and second. The year in this timestamp is not used for the analysis. Using an unrealistic year can help to indicate that this is ignored. Example: `1800-11-09 12:00:00`. Records are assessed based on values in the attribute `timestamp`.

**Years to select seasons from (`years`):** a string of comma-separated calender years. The (empty) default setting leads to the selection of records across all years in the data set. Example: 2013, 2014, 2015. If the specified season crosses December-January, the starting year of the selected season must be included. Records are assessed based on values in the attribute `timestamp`.

**Name of the season (`season`):** a conclusive name for the selected season. This will be attributed to all locations during that season in the new column 'season'. Records that are not in the selected season obtain the column entry `none`. If left empty this defaults to the specified time interval, e.g. `11-24 12:00:00 to 1-31 20:00:00`.

**Filter data for the season? (`filter`):** select whether to filter the input data to retain only records with a timestamp falling within the specified seasons and years. If unselected, the input data set will be returned with an extra column 'season' appended. Default TRUE.

**Split tracks by season? (`splitt`):** select whether to split the tracks by season. That way unrealistic steps connecting the end and start locations of different years within the same animal/deployment will be avoided, which can lead to unexpected results in subsequent analyses. Note that this setting is only possible if "Filter data for the season?" is TRUE. Default FALSE.


### Most common errors
none so far for this move2 App, please add as issues here.

### Null or error handling:
**Setting `startTimestamp`:** If a start timestamp is not provided (i.e. NULL) the data is not filtered by season. If a `years` variable other than `ALL` was defined, then all data of the defined years are returned.

**Setting `endTimestamp`:** If an end timestamp is not provided (i.e. NULL) the data is not filtered by season. If a `years` variable other than `ALL` was defined, then all data of the defined years are returned.

:warning: If the endTimestamp is before the startTimestamp in the year, then the data is filtered each year for 1 January - endTimestamp and startTimestamp - 31 December. Thus, seasons crossing the New Year can also be defined.

**Setting `years`:** Year is by default `ALL`, so if no years are defined by the user then all in the data set available years are used for filtering. If both startTimestamp and/or endTimestamp and years are not set by the user, the input data set is returned. A warning is given.

**Data:** If there are no locations of the data set in the defined time intervals (seasons), NULL is returned. This will lead to an error.

