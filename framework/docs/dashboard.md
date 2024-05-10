---
theme: dashboard
title: Call Dashboard
toc: false
sql:
  all_calls: ./data/inc_main_extended.parquet
---

# 🚨 Calls 🚨

Filters apply to all data/graphs below them. These date filters apply to all charts on the page.

```js
const start = view(Inputs.date({label: "Start", value: "2020-01-01"}))
```

```js
const end = view(Inputs.date({label: "End", value: "2023-12-31"}))
```

```js
const color = {
      legend: true,
      domain: [
        "EMS", 
        "False Alarm", 
        "Fire General", 
        "Good Intent", 
        "Hazardous Condition (no fire)", 
        "Motor Vehicle", 
        "Rescue", 
        "Service Call"          
      ],
      range: [
        "darkblue",
        "yellow",
        "red",
        "green", 
        "purple",
        "orange", 
        "pink",
        "brown",
        "grey",
        "green",
        "lavender"                
      ]
    }
```


<!-- Load and transform the data -->

```sql id=data
select 
  * 
from 
  all_calls 
where
  alm_date >= ${start}
  and alm_date <= ${end}
```

```js
const n_mutual_aid = [...data].filter((d) => !d.In_town).length.toLocaleString("en-US")
```

```js
const total_calls = [...data].length.toLocaleString("en-US")
```

<!-- Cards with big numbers -->

<div class="grid grid-cols-4">
  <div class="card">
    <h2>Total calls 🆘</h2>
    <span class="big">${total_calls.toLocaleString("en-US")}</span>
  </div>
  <div class="card">
    <h2>Mutual Aid calls 🏠</h2>
    <span class="big">${n_mutual_aid}</span>
  </div>
</div>

For the following charts, we can include or exclude the ${n_mutual_aid} mutual aid calls.

```js
const mutual_aid = view(Inputs.toggle({label: "Include Mutual Aid", value: false}));
```

Some responders come to the station, 
but are too late to make it onto an appartus that is responding.
If they stand by and wait to see if additional support is needed, 
these responses get recorded.
While these responses do get recorded,
we can exclude these from our count of responders for a given call.

```js
const scene_only = view(Inputs.toggle({label: "Exclude Station-Only Response", value: true}));
```

```js
const data_filtered = [...data].filter(d => mutual_aid ? true : d.In_town)
```

```js
const respondingColumn = scene_only ? "RespondingScene" : "RespondingAny"
```

<div class="grid grid-cols-4">
  <div class="card">
    <h2>Calls remaining</h2>
    <span class="big">${(total_calls - (mutual_aid ? 0 : n_mutual_aid)).toLocaleString("en-US")}</span>
  </div>
  <div class="card">
    <h2>Total number of responses</h2>
    <span class="big">${d3.sum(data_filtered.map(d => scene_only ? d.NumRespondingPersonnelScene : d.NumRespondingBase)).toLocaleString("en-US")}</span>
  </div>  
  <div class="card">
    <h2>Avg Response time ⏰</h2>
    <span class="big">${Math.round(d3.mean(data_filtered.map(d => d.Resp_time_minutes))*10)/10}</span>
    <span class="muted"> minutes</span>
  </div>
  <div class="card">
    <h2>Avg # Responders 🧑‍🚒</h2>
    <span class="big">${d3.mean(data_filtered.map(d => scene_only ? d.NumRespondingPersonnelScene : d.NumRespondingBase)).toLocaleString("en-US")}</span>
  </div>
</div>

```js
function callTimeline(d, {width} = {}) {
  return Plot.plot({
    title: "Calls over the years",
    width,
    height: 300,
    y: {grid: true, label: "Calls"},
    color: {...color},
    marks: [
      Plot.rectY(d, Plot.binX({y: "count"}, {x: "Alm_date", fill: "Inci_collapsed", interval: "year", tip: true})),
      Plot.ruleY([0])
    ]
  });
}
```

<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => callTimeline(data_filtered, {width}))}
  </div>
</div>

```sql id=grouped
SELECT  
    Inci_collapsed, 
    -- Descript, 
    avg(Resp_time_minutes) AS Resp_time, 
    avg(NumRespondingBase) AS RespondingAny, 
    avg(NumRespondingPersonnelScene) AS RespondingScene, 
    count(*) AS Num_calls 
FROM 
    all_calls 
WHERE 
    alm_date >= ${start}
    and alm_date <= ${end}
    AND In_town in (true, ${!mutual_aid})
GROUP BY 1 -- 2
ORDER BY 1
```

```js
function callTypeChart(d, {width}) {
  return Plot.plot({
    title: "Volume by call type",
    width,
    height: 300,
    marginTop: 0,
    marginLeft: 150,
    x: {grid: true, label: "Count of calls"},
    y: {label: null},
    color: {...color, legend: false},
    marks: [
      Plot.barX(d, 
        {
          x: "Num_calls", 
          y: "Inci_collapsed", 
          fill: "Inci_collapsed", 
          tip: true, 
          sort: {y: "-x"}
        }
      ),
      // Plot.ruleX([0])
    ]
  });
}
```

<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => callTypeChart(grouped, {width}))}
  </div>
</div>



```js
function callTypeChart2(d, {width}) {
  return Plot.plot({
    title: "Response times by call type",
    width,
    height: 300,
    marginTop: 0,
    marginLeft: 150,
    x: {grid: true, label: "Average response time"},
    y: {label: null},
    color: {...color, legend: false},
    marks: [
      Plot.barX(d, 
        {
          x: "Resp_time", 
          y: "Inci_collapsed", 
          fill: "Inci_collapsed", 
          tip: true, 
          sort: {y: "-x"}
        }
      ),
      // Plot.ruleX([0])
    ]
  });
}
```

```js
function callTypeChart3(d, {width}) {
  return Plot.plot({
    title: "Personnel responded by call type",
    width,
    height: 300,
    marginTop: 0,
    marginLeft: 150,
    x: {grid: true, label: "Average Number Responders"},
    y: {label: null},
    color: {...color, legend: false},
    marks: [
      Plot.barX(d, 
        {
          x: respondingColumn, 
          y: "Inci_collapsed", 
          fill: "Inci_collapsed", 
          tip: true, 
          sort: {y: "-x"}
        }
      ),
      // Plot.ruleX([0])
    ]
  });
}
```


<div class="grid grid-cols-2">
  <div class="card">
    ${resize((width) => callTypeChart2(grouped, {width}))}
  </div>
    <div class="card">
    ${resize((width) => callTypeChart3(grouped, {width}))}
  </div>
</div>



```sql id=responding_count
SELECT  
    NumRespondingPersonnelScene,
    count(*) AS Num_calls
FROM 
    all_calls
WHERE 
    alm_date >= ${start}
    and alm_date <= ${end}
GROUP BY 1
ORDER BY 1;
```

```js
function callTypeChart4(d, {width}) {
  return Plot.plot({
    title: "Number of calls by count of responders",
    width,
    height: 300,
    marginTop: 0,
    marginLeft: 20,
    x: {grid: true, label: "Number of Responders"},
    y: {label: null},
    color: {scheme: "reds", legend: false, reverse: true},
    marks: [
      Plot.barY(d, 
        {
          x: "NumRespondingPersonnelScene", 
          y: "Num_calls", 
          fill: "NumRespondingPersonnelScene", 
          tip: true, 
          sort: {x: "x"}
        }
      ),
      // Plot.ruleX([0])
    ]
  });
}
```


```sql id=byHour
SELECT  
    HOUR(alm_time) as t,
    count(*) AS Num_calls 
FROM 
    all_calls
WHERE 
    alm_date >= ${start}
    and alm_date <= ${end}
GROUP BY 1
ORDER BY 1;
```

```js
function callTypeChart5(d, {width}) {
  return Plot.plot({
    title: "Number of calls by Time of Day",
    width,
    height: 300,
    marginTop: 0,
    marginLeft: 20,
    x: {grid: true, label: "Time of day"},
    y: {label: null},
    color: {scheme: "reds", legend: false, reverse: false},
    marks: [
      Plot.barY(d, 
        {
          x: "t", 
          y: "Num_calls", 
          fill: "Num_calls", 
          tip: true, 
          // sort: {x: "x"}
        }
      ),
      // Plot.ruleX([0])
    ]
  });
}
```

<div class="grid grid-cols-2">
  <div class="card">
    ${resize((width) => callTypeChart4(responding_count, {width}))}
  </div>
    <div class="card">
    ${resize((width) => callTypeChart5(byHour, {width}))}
  </div>
</div>