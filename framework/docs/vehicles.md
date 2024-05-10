---
theme: default
title: Apparatus
toc: false
sql:
  Inc_main_extended: ./data/inc_main_extended.parquet
  Inc_unit: ./data/Inc_unit.parquet
---

# Apparatus

```js
const mutual_aid = view(Inputs.toggle({label: "Include Mutual Aid", value: false}));
```

```sql id=count_by_year
select 
  year(Inc_unit.alm_date) as yr,
  Unit,
  count(*) as ct
from 
  Inc_unit
inner join
  Inc_main_extended Inc_main
  on
    Inc_main.Inci_no = Inc_unit.Inci_no
WHERE    
  Inc_unit.alm_date >= '2020-01-01'
  AND In_town in (true, ${!mutual_aid})
group by 1, 2
order by 1, 2
```

${
    resize((width) => Plot.plot({
      title: "Calls by year for each apparatus",
      subtitle: "2020-2023",
      width,
      color: {
        scheme: "observable10", 
        legend: true,
      },      
      y: {grid: true, label: "Calls"},
      marks: [
        Plot.barY(count_by_year, {x: "yr", y: "ct", fill: "Unit", tip: true})
      ]
    }))
  }

```sql id=average_count_by_year
select 
  Unit,
  floor(count(*)/4) as Num_calls
from 
  Inc_unit
inner join
  Inc_main_extended Inc_main
  on
    Inc_main.Inci_no = Inc_unit.Inci_no
WHERE    
  year(Inc_unit.alm_date) >= 2020
  AND year(Inc_unit.alm_date) <= 2023
  AND In_town in (true, ${!mutual_aid})
group by 1
order by 1
```

Average calls per year 2020-2023:

${Inputs.table(average_count_by_year, {
  columns: ["Unit", "Num_calls"],
  align: {Unit: "left", Num_calls: "left"},
  header: {Unit: "Unit", Num_calls: "Number Calls Responded Per Year (floor)"},
  format: {Num_calls: sparkbar(d3.max(num_calls_by_unit, d => d.Num_calls))},
  rows: 30,
  // width: width,
  // maxWidth: width,
  sort: "Num_calls", 
  reverse: true
})
}

Filter by time range:

```js
const start = view(Inputs.date({label: "Start", value: "2023-01-01"}))
```

```js
const end = view(Inputs.date({label: "End", value: "2023-12-31"}))
```

For this time range, 
we have ${d3.sum([...num_calls_by_unit], d=>d.Num_calls)} calls
responded to by
${[...num_calls_by_unit].length} different units,
with an average of 
${d3.format(".1f")(d3.sum([...num_calls_by_unit], d=>d.Num_calls)/d3.sum([...calls_by_unit_grouped], d=>d.Num_calls))}
units responding to any given call.

The following charts all use this time range (and the mutual aid filter at the top).

```sql id=num_calls_by_unit
select 
  Unit,
  count(*) as Num_calls
from 
  Inc_unit
inner join
  Inc_main_extended Inc_main
  on
    Inc_main.Inci_no = Inc_unit.Inci_no  
WHERE    
  Inc_unit.alm_date >= ${start}
  and Inc_unit.alm_date <= ${end}    
  AND In_town in (true, ${!mutual_aid})
group by 1
order by 1, 2 desc
```

${Inputs.table(num_calls_by_unit, {
  columns: ["Unit", "Num_calls"],
  align: {Unit: "left", Num_calls: "left"},
  header: {Unit: "Unit", Num_calls: "Number Calls Responded"},
  format: {Num_calls: sparkbar(d3.max(num_calls_by_unit, d => d.Num_calls))},
  rows: 30,
  // width: width,
  // maxWidth: width,
  sort: "Num_calls", 
  reverse: true
})
}

We can break this down by the type of call that each responded to:

```js
function callTypeChart(d, {width}) {
  return Plot.plot({
    title: `Which type of calls each apparatus responds to`,
    width,
    height: 300,
    marginTop: 0,
    marginLeft: 150,
    x: {grid: true, label: "Count of calls"},
    y: {label: null},
    color: {...color},
    marks: [
      Plot.barX(d, 
        {
          x: "Num_calls", 
          y: "Unit", 
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

${resize((width) => callTypeChart(calls_by_unit, {width}))}

```sql id=n_units_per_call
select 
  Inc_main.Inci_collapsed,
  mean(ct) as Num_units
from 
  (
    select Inci_no, count(*) as ct from Inc_unit group by 1
  ) Inc_unit
inner join
  Inc_main_extended Inc_main
  on
    Inc_main.Inci_no = Inc_unit.Inci_no
WHERE    
  Inc_main.alm_date >= ${start}
  and Inc_main.alm_date <= ${end}          
  AND In_town in (true, ${!mutual_aid})
group by 1
order by 1 desc
```

${Inputs.table(n_units_per_call, {
  columns: ["Inci_collapsed", "Num_units"],
  align: {Inci_collapsed: "left", Num_units: "left"},
  header: {Inci_collapsed: "Incident Type", Num_units: "Number Units Responded"},
  format: {Num_units: sparkbar(d3.max(n_units_per_call, d => d.Num_units))},
  rows: 30,
  // width: width,
  // maxWidth: width,
  sort: "Num_units", 
  reverse: true
})
}

```sql id=n_units_per_call_grouped
select 
  Inc_main.Inci_collapsed,
  ct as Num_units,
  count(*) as Frequency
from 
  (
    select Inci_no, count(*) as ct from Inc_unit group by 1
  ) Inc_unit
inner join
  Inc_main_extended Inc_main
  on
    Inc_main.Inci_no = Inc_unit.Inci_no
WHERE    
  Inc_main.alm_date >= ${start}
  and Inc_main.alm_date <= ${end}  
  AND In_town in (true, ${!mutual_aid})        
group by 1, 2
order by 1, 2 desc
```

```js
function callTypeChart2(d, {width}) {
  return Plot.plot({
    title: `Number of Units Responding by Type of Call`,
    width,
    height: 300,
    marginTop: 0,
    marginLeft: 150,
    x: {grid: true, label: "Count of calls"},
    y: {label: null},
    color: {scheme: "Observable10"},
    marks: [
      Plot.barX(d, 
        {
          x: "Frequency", 
          y: "Inci_collapsed", 
          fill: "Num_units", 
          tip: true, 
          sort: {y: "-x"}
        }
      ),
      // Plot.ruleX([0])
    ]
  });
}
```

${resize((width) => callTypeChart2(n_units_per_call_grouped, {width}))}

```sql id=calls_by_unit
select 
  Unit,
  Inc_main.Inci_collapsed,
  count(*) as Num_calls
from 
  Inc_unit
left join
  Inc_main_extended Inc_main
  on
    Inc_main.Inci_no = Inc_unit.Inci_no
WHERE    
  Inc_unit.alm_date >= ${start}
  and Inc_unit.alm_date <= ${end}          
  AND In_town in (true, ${!mutual_aid})
group by 1, 2
order by 1, 2 desc
```

```js
function unitTypeChart(d, {width}) {
  return Plot.plot({
    title: `Which apparatus respond to a given call`,
    width,
    height: 300,
    marginTop: 0,
    marginLeft: 150,
    x: {grid: true, label: "Count of calls"},
    y: {label: null},
    color: {legend: true},
    marks: [
      Plot.barX(d, 
        {
          x: "Num_calls", 
          fill: "Unit", 
          y: "Inci_collapsed", 
          tip: true, 
          sort: {y: "-x"}
        }
      ),
      // Plot.ruleX([0])
    ]
  });
}
```

${resize((width) => unitTypeChart(calls_by_unit, {width}))}

The above may not make complete sense,
because multiple apparatus often respond to the same call.
Combining them:


```sql id=calls_by_unit_grouped
select 
  Inc_main.Inci_collapsed,
  Units,
  count(*) as Num_calls
from 
  (
    select
      Inci_no, 
      string_agg(Unit, ', ') as Units 
    from 
      (select Unit, Inci_no from Inc_unit order by 1 desc) x
    group by 1
  ) Inc_unit
left join
  Inc_main_extended Inc_main
  on
    Inc_main.Inci_no = Inc_unit.Inci_no
WHERE    
  Inc_main.alm_date >= ${start}
  and Inc_main.alm_date <= ${end}          
  AND In_town in (true, ${!mutual_aid})
group by 1, 2
order by 1, 2 desc
```

```js
function unitTypeChart2(d, {width}) {
  return Plot.plot({
    title: `Which apparatus(es) respond to a given call together`,
    width,
    height: 300,
    marginTop: 0,
    marginLeft: 150,
    x: {grid: true, label: "Count of calls"},
    y: {label: null},
    color: {legend: true, scheme: "Observable10"},
    marks: [
      Plot.barX(d, 
        {
          x: "Num_calls", 
          fill: "Units", 
          y: "Inci_collapsed", 
          tip: true, 
          sort: {y: "-x"}
        }
      ),
      // Plot.ruleX([0])
    ]
  });
}
```

${resize((width) => unitTypeChart2(calls_by_unit_grouped, {width}))}

<!-- `Resp_code` isn't consistently populated: -->

```sql id=resp_code_not_consistent
select
  year(arv_date),  
  resp_code,
  count(*)
from 
  Inc_unit    
group by 1, 2
```

<!-- `Unit_id` is unique, not a ref to a given apparatus: -->

```sql id=unit_id_not_unique
select 
  Unit_id,
  max(Inc_main.alm_date) as most_recent_call,
  count(*)
from 
  Inc_unit
left join
  Inc_main_extended Inc_main
  on
    Inc_main.Inci_no = Inc_unit.Inci_no
WHERE    
  Inc_unit.alm_date >= ${start}
  and Inc_unit.alm_date <= ${end}          
group by 1
order by 2 desc
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

```js
function sparkbar(max) {
  return (x) => htl.html`<div style="
    background: var(--theme-green);
    color: black;
    font: 10px/1.6 var(--sans-serif);
    width: ${100 * x / max}%;
    float: left;
    padding-right: 2px;
    box-sizing: border-box;
    overflow: visible;
    display: flex;
    justify-content: end;">${x.toLocaleString("en-US")}`
}
```