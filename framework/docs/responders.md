---
theme: dashboard
title: Responders
toc: false
sql:
  all_calls: ./data/inc_main_extended.parquet
---

# Calls 

```js
const start = view(Inputs.date({label: "Start", value: "2023-01-01"}))
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

<!-- Cards with big numbers -->

<div class="grid grid-cols-4">
  <div class="card">
    <h2>Total calls 🆘</h2>
    <span class="big">${[...data].length.toLocaleString("en-US")}</span>
  </div>
  <div class="card">
    <h2>Response time ⏰</h2>
    <span class="big">${d3.mean([...data].map(d => d.Resp_time_minutes)).toLocaleString("en-US")}</span>
  </div>
  <div class="card">
    <h2>Responders 🧑‍🚒</h2>
    <span class="big">${d3.mean([...data].map(d => d.NumRespondingPersonnelScene)).toLocaleString("en-US")}</span>
  </div>
  <div class="card">
    <h2>Mutual Aid calls</h2>
    <span class="big">${[...data].filter((d) => !d.In_town).length.toLocaleString("en-US")}</span>
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
    ${resize((width) => callTimeline(data, {width}))}
  </div>
</div>

```js
const mutual_aid = view(Inputs.toggle({label: "Include Mutual Aid", value: false}));
```

```js
const scene_only = view(Inputs.toggle({label: "Exclude Station-Only Response", value: true}));
```

```js
const respondingColumn = scene_only ? "RespondingScene" : "RespondingAny"
```

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
    YEAR(Alm_date) IN (2020, 2021, 2022, 2023) 
    AND In_town in (false, ${mutual_aid})
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



