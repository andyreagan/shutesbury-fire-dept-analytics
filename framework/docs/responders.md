---
theme: default
title: Responders
toc: false
sql:
  Inc_main_extended: ./data/inc_main_extended.parquet
  Act_det_extended: ./data/Act_det_extended.parquet
---

# Responders

First note that this data is
incomplete prior to 2020,
and only goes back to 2013 at all (refer to <a href="/index">overview page</a> for the counts).
That said, we can look at count of responses by personnel for the whole database:

```sql id=all_time
SELECT  
    Act_det.LastName,
    COUNT(*) AS Num_calls
FROM 
    Inc_main_extended Inc_main
LEFT JOIN
    Act_det_extended Act_det 
    ON Inc_main.Activ_id = Act_det.Activ_id
WHERE LastName is not null    
GROUP BY 1
ORDER BY 2 DESC 
```

${Inputs.table(all_time, {
  columns: ["LastName", "Num_calls"],
  align: {LastName: "left", Num_calls: "left"},
  header: {LastName: "Last Name", Num_calls: "Number of Calls"},
  format: {Num_calls: sparkbar(d3.max(all_time, d => d.Num_calls))},
  rows: 30,
  // width: width,
  // maxWidth: width,
  sort: "total_pts_sum", 
  reverse: true,
  selection: false
})
}

```js
function sparkbar(max) {
  return (x) => htl.html`<div style="
    background: var(--theme-green);
    color: black;
    font: 10px/1.6 var(--sans-serif);
    width: ${100 * x / max}%;
    float: left;
    padding-right: 3px;
    box-sizing: border-box;
    overflow: visible;
    display: flex;
    justify-content: end;">${x.toLocaleString("en-US")}`
}
```

## Filter by time range

```js
const start = view(Inputs.date({label: "Start", value: "2023-01-01"}))
```

```js
const end = view(Inputs.date({label: "End", value: "2023-12-31"}))
```

```sql id=filtered
SELECT  
    Act_det.LastName,
    COUNT(*) AS Num_calls,
    COUNT(*)/x.total_count as Perc_calls
FROM 
    Inc_main_extended Inc_main
LEFT JOIN
    Act_det_extended Act_det 
    ON Inc_main.Activ_id = Act_det.Activ_id
LEFT JOIN
    (
        SELECT  
            COUNT(*) AS total_count 
        FROM 
            Inc_main_extended
        WHERE    
            alm_date >= ${start}
            and alm_date <= ${end}              
    ) x
    ON 1
WHERE    
  alm_date >= ${start}
  and alm_date <= ${end}    
GROUP BY 1, total_count
ORDER BY 2 DESC
```

```js
const res = view(Inputs.table(filtered, {
  columns: ["LastName", "Num_calls", "Perc_calls"],
  align: {LastName: "left", Num_calls: "left"},
  header: {LastName: "Last Name", Num_calls: "Number of Calls", Perc_calls: "Percentage of Calls"},
  format: {Num_calls: sparkbar(d3.max(filtered, d => d.Num_calls)), Perc_calls: d3.format(".0%")},
  rows: 30,
  maxWidth: 650,
  // maxWidth: width,
  sort: "total_pts_sum", 
  reverse: true,
  // required: false,
  multiple: false,
}))
```

```js
const name = res ? res.LastName : [...filtered][0].LastName
```


Select a responder(s) above to see their distribution of call types (filtered by the date range).

```sql id=filtered_one
SELECT  
    Inc_main.Inci_collapsed,
    count(*) as Num_calls
FROM 
    Inc_main_extended Inc_main
LEFT JOIN
    Act_det_extended Act_det 
    ON Inc_main.Activ_id = Act_det.Activ_id
WHERE    
  alm_date >= ${start}
  and alm_date <= ${end} 
  and Act_det.LastName = ${name}
GROUP BY 1
ORDER BY 1 DESC
```

```js
function callTypeChart(d, {width}) {
  return Plot.plot({
    title: `Num calls responded by call type for ${name}`,
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

${resize((width) => callTypeChart(filtered_one, {width}))}


## First call

In the database (for some, certainly not their first call!).

```sql id=first_call
SELECT  
    LastName,
    MIN(Inc_main.Alm_date) AS First_Call
FROM
    Inc_main_extended Inc_main
LEFT JOIN
    Act_det_extended Act_det 
    ON Inc_main.Activ_id = Act_det.Activ_id
    -- AND (Act_det.Unit != 'STAT' or Act_det.Unit is null)
WHERE LastName is not null
GROUP BY 1
ORDER BY 2 DESC;
```

${Inputs.table(first_call, {
  columns: ["LastName", "First_Call"],
  align: {LastName: "left", First_Call: "left"},
  header: {LastName: "Last Name", First_Call: "First Call Responded"},
  // format: {Num_calls: sparkbar(d3.max(all_time, d => d.Num_calls))},
  rows: 30,
  // width: width,
  // maxWidth: width,
  sort: "First_Call", 
  reverse: true
})
}

## Call Types By Responder

```sql id=all_responses
SELECT
    Act_det.LastName,
    Inc_main.Inci_collapsed,
    count(*) as ct
FROM 
    Inc_main_extended Inc_main
LEFT JOIN
    Act_det_extended Act_det 
    ON Inc_main.Activ_id = Act_det.Activ_id
WHERE LastName is not null
GROUP BY 1, 2
ORDER BY 1, 2
```



```js
function callTypes(d, {width} = {}) {
    return Plot.plot({
        width,
        // height: 832,
        marginLeft: 100,
        x: {axis: "top", tickFormat: "%"},
        y: {label: null},
        // color: {scheme: "Spectral", legend: "ramp", width: 340, label: "Age (years)"},
        color: {...color},
        marks: [
        Plot.barX(d, {
            x: "ct",
            y: "LastName",
            fill: "Inci_collapsed",
            offset: "normalize",
            tip: true,
            sort: {color: "fill", reduce: "first"}
        }),
        Plot.ruleX([0])
        ]
    });
}
```

${resize((width) => callTypes(all_responses, {width}))}

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