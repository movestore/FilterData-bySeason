# Filter data by Season
MoveApps

Github repository: *github.com/movestore/FilterData-bySeason*

## Description
Selects positions that fall within a selected time range of several (also user-provided) years, i.e. spring migration of 2013 and 2014.

## Documentation
This App filters the data to defined seasonal time intervals of a selection of years. Of the user-defined start timestamp and end timestamp only month, year, hour, minute and second are extracted. Year(s) must independently specified or are all in the data set available years by default.

### Input data
moveStack in Movebank format

### Output data
moveStack in Movebank format

### Artefacts
none

### Parameters 
`startTimestamp`: a timestamp with year, month, day, hour, minute and second has to be selected interactively. Year of this timestamp is not used for the analysis. Example: “2020-11-09 12:00:00”.

`endTimestamp`: a timestamp with year, month, day, hour, minute and second has to be selected interactively. Year of this timestamp is not used for the analysis. Example: “2020-11-09 12:00:00”.

`years`: a string of comma-separated calender years. The default value is `ALL` which leads to the selection of all in the data available years. Example: 2013, 2014, 2015.

### Null or error handling:
**Parameter `startTimestamp`:** If the start timestamp or the end timestamp are not selected (i.e. NULL) the data is not filtered by season. If a `years` variable other than `ALL`was defined, then all data of the defined years are returned.

**Parameter `endTimestamp`:** If the start timestamp or the end timestamp are not selected (i.e. NULL) the data is not filtered by season. If a `years` variable other than `ALL`was defined, then all data of the defined years are returned.

:warning: If the endTimestamp is before the startTimestamp in the year, then the data is filtered each year for 1 January - endTimestamp and startTimestamp - 31 December. Thus, seasons crossing the New Year can also be defined.

**Parameter `years`:** Year is by default `ALL`, so if no years are defined by the user then all in the data set available years are used for filtering. If both startTimestamp and/or endTimestamp and years are not set by the user, the input data set is returned. A warning is given.

**Data:** If there are no locations of the data set in the defined time intervals (seasons), NULL is returned. This will lead to an error.

