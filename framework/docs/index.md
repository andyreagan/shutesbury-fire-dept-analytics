---
toc: false
sql:
  all_calls: ./data/inc_main_extended.parquet
---

```sql id=count_by_year
select 
  year(alm_date) as yr, 
  Inci_collapsed,
  count(*) as ct 
from 
  all_calls 
group by 
  1, 2
order by
  1, 2
```

<style>

.hero {
  display: flex;
  flex-direction: column;
  align-items: center;
  font-family: var(--sans-serif);
  margin: 4rem 0 8rem;
  text-wrap: balance;
  text-align: center;
}

.hero h1 {
  margin: 2rem 0;
  max-width: none;
  font-size: 14vw;
  font-weight: 900;
  line-height: 1;
  background: linear-gradient(30deg, var(--theme-foreground-focus), currentColor);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.hero h2 {
  margin: 0;
  max-width: 34em;
  font-size: 20px;
  font-style: initial;
  font-weight: 500;
  line-height: 1.5;
  color: var(--theme-foreground-muted);
}

@media (min-width: 640px) {
  .hero h1 {
    font-size: 90px;
  }
}

</style>

<div class="hero">
  <h1>🚒 Shutesbury Fire Department Statistics 🚒</h1>
  <h2>Basic 📈 analysis 📈 of public call data to include types of calls, average response times, apparatus used, etc.</h2>
  <a href="https://www.shutesbury.org/Fire_Department">SFD Website<span style="display: inline-block; margin-left: 0.25rem;">↗︎</span></a>
</div>

<div class="grid grid-cols-1" style="grid-auto-rows: 504px;">
  <div class="card">${
    resize((width) => Plot.plot({
      title: "Calls by year 🔥",
      subtitle: "Data is complete from 2020 forward",
      width,
      color: {
        // scheme: "reds", 
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
      },      
      y: {grid: true, label: "Calls"},
      marks: [
        Plot.barY(count_by_year, {x: "yr", y: "ct", fill: "Inci_collapsed", tip: true})
      ]
    }))
  }</div>
</div>

<!-- "EMS", 
"False Alarm", 
"Fire General", 
"Good Intent", 
"Hazardous Condition (no fire", 
"Motor Vehicle", 
"Rescue", 
"Service Call",  -->