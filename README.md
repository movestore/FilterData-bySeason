# Filter/Annotate by Season
MoveApps

Github repository: *github.com/movestore/FilterData-bySeason*

## Description
Selects or annotate positions that fall within a selected time range of several (also user-provided) years, i.e. spring migration of 2013 and 2014.

## Documentation
This App annotates or filters the data with/to defined seasonal time intervals of a selection of years. Of the user-defined start timestamp and end timestamp only month, year, hour, minute and second are extracted. Year(s) must independently specified or are all in the data set available years by default.

Note that the names of your new tracks (split by year) are composed of the animal ID (individual local identifier) and the year of the first location of the track.

### Input data
move2 location object

### Output data
move2 location object

### Artefacts
none

### Settings
**Start of your season (`startTimestamp`):** a timestamp with year, month, day, hour, minute and second has to be selected interactively. Year of this timestamp is not used for the analysis. Example: “2020-11-09 12:00:00”.

**End of your season (UTC) (`endTimestamp`):** a timestamp with year, month, day, hour, minute and second has to be selected interactively. Year of this timestamp is not used for the analysis. Note that the starting year of the selected season is required if your specified season crosses December/January. Example: `2020-11-09 12:00:00`.

**Years you want to select seasons from (`years`):** a string of comma-separated calender years. The default value is `ALL` which leads to the selection of all in the data available years. Example: 2013, 2014, 2015. 

**Name of your season for annotation (`season`):** a conclusive name for the selected season. This will be attributed to all locations during that season in the new column 'season'. If you select not to filter the data, locations that are not in the selected season obtain the column entry `none`. If left empty this defaults to the specified time interval, e.g. `11-24 12:00:00 to 1-31 20:00:00`.

**Filter data for season locations? (`filter`):** selection, if the user wants the input data to be filtered to only contain locations in the specified seasons (and years). If unselected, the input data set will be returned with an extra column 'season' appended. Default TRUE.

**Split tracks by season? (`splitt`):** selection if the user wants to split the (animal/deployment) tracks by season. That way unrealistic steps connecting the end and start locations of different years within the same animal/deployment will be avoided, which can lead to wrong conclusions in subsequent analyses. Note that this setting is only possible if the above Filter setting is TRUE. Default FALSE.


### Most common errors
none so far for this move2 App, please add as issues here.

### Null or error handling:
**Setting `startTimestamp`:** If the start timestamp or the end timestamp are not selected (i.e. NULL) the data is not filtered by season. If a `years` variable other than `ALL`was defined, then all data of the defined years are returned.

**Setting `endTimestamp`:** If the start timestamp or the end timestamp are not selected (i.e. NULL) the data is not filtered by season. If a `years` variable other than `ALL`was defined, then all data of the defined years are returned.

:warning: If the endTimestamp is before the startTimestamp in the year, then the data is filtered each year for 1 January - endTimestamp and startTimestamp - 31 December. Thus, seasons crossing the New Year can also be defined.

**Setting `years`:** Year is by default `ALL`, so if no years are defined by the user then all in the data set available years are used for filtering. If both startTimestamp and/or endTimestamp and years are not set by the user, the input data set is returned. A warning is given.

**Data:** If there are no locations of the data set in the defined time intervals (seasons), NULL is returned. This will lead to an error.

