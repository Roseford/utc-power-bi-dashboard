# Build guide: recreate the dissertation figures in Power BI Desktop

Estimated time: 2 to 3 hours. Power BI Desktop (Windows) is required.
Do the steps in order. Set the canvas first: click an empty area, Format page > Canvas settings > Type: Custom, 1280 x 720, then View > Page view > Fit to page. (The default may be 1920 x 1080.)

---

## 0. Start from a clean report

Your first attempt used `UTC_summary_dissertation.csv`. Do not use it for these
figures: its means are patient-level and it has no standard deviations, so it
cannot reproduce them. Start a new `.pbix` (or delete the summary table from the
model) and use the steps below. Expected values are in `docs/expected_values.md`.

## 1. Load the data

1. Home > **Transform data** to open Power Query.
2. Home > **Manage Parameters** > **New Parameter**.
   - Name: `DataFolder`, Type: `Text`, Current value: full path to the `data` folder
     **ending in a backslash**, for example `C:\Users\you\utc-power-bi-dashboard\data\`
3. Home > **New Source** > **Blank Query**. Open **Advanced Editor**, paste QUERY 1 from
   `powerbi/power_query.m` (from `let` to `TimeBin`), click Done. Rename the query to `Patients`.
4. Repeat with QUERY 2 and rename it `Timeseries`.
5. Home > **Close & Apply**.

Check: `Patients` has **972** rows (323 Normal + 649 Surge) and `Timeseries` has **160** (80 + 80).

## 2. Model: dimension tables and relationships

1. Modeling > **New table**, paste `Dim_Condition` from `powerbi/measures.dax`.
2. Modeling > **New table**, paste `Dim_Run`.
3. Open **Model view**. Drag to create four relationships (all **One to many**,
   cross-filter direction **Single**, from the Dim table to the fact table):
   - `Dim_Condition[Condition]` to `Patients[Condition]`
   - `Dim_Condition[Condition]` to `Timeseries[Condition]`
   - `Dim_Run[Run]` to `Patients[Run]`
   - `Dim_Run[Run]` to `Timeseries[Run]`
4. Right-click `Patients[Condition]`, `Patients[Run]`, `Timeseries[Condition]`, `Timeseries[Run]`
   > **Hide in report view**. From now on always use the `Dim_` fields on axes.

## 3. Measures

1. Home > **Enter data**, leave it blank, name the table `_Measures`, Load.
2. Select `_Measures`, then Modeling > **New measure** and paste each measure from Part B of
   `powerbi/measures.dax`, one at a time. (Faster: in the formula bar, paste one measure,
   press Enter, repeat.)
3. Select all `Mean`, `SD`, `Upper`, `Lower`, `%` measures and format them: Measure tools >
   **Format** > Decimal places **1**. Format `Completed %`, `Left %`, `Still In %` as Percentage.

Quick test: create a table visual with `Dim_Condition[Condition]`, `Arrivals Mean`, `Arrivals SD`.
You must see **64.6 / 10.8** (Normal) and **129.8 / 9.1** (Surge). If not, stop and check step 2.

## 4. Theme

View > **Themes** > **Browse for themes** > select `powerbi/theme_UTC.json`.
The theme gives Normal = green and Surge = red automatically when the axis is `Dim_Condition[Condition]`.

Colours to apply manually where the theme cannot (Format > Visual > the series colour):

| Item | Hex |
|---|---|
| Normal | `#2E9E6B` |
| Surge | `#E0314B` |
| Triage | `#1F77B4` |
| Treatment | `#FF7F0E` |
| Total in system | `#2CA02C` |
| High acuity | `#E0314B` |
| Low acuity | `#4169E1` |
| Completed / Left / Still in system | `#2E9E6B` / `#F5A623` / `#E0314B` |
| Surge total-time bars | `#F5A623` |

Set position and size of any visual in Format > General > **Properties** > Size and Position (X, Y, Width, Height).

---

## Page 1: Overview (Figure 1 + Summary table)

Rename the page `Overview`.

**Header.** Insert > Text box. X 0, Y 0, W 1280, H 64. Fill `#1B2A3B`. Text: `UTC Performance: Normal vs Surge`
(white, Segoe UI Semibold 22) and a second line `Mean ± SD across 5 simulation runs` (white, 11).

**Four comparison charts** (one **Clustered column chart** each; W 300, H 270, Y 80; X = 22, 334, 646, 958):

| Title | Y-axis | Error bar upper | Error bar lower |
|---|---|---|---|
| Breach Rate (%) | `Breach % Mean` | `Breach % Upper` | `Breach % Lower` |
| LWBS Rate (%) | `Leave % Mean` | `Leave % Upper` | `Leave % Lower` |
| Wait Time (min) | `Wait Mean` | `Wait Upper` | `Wait Lower` |
| Peak Queue | `Peak Queue Mean` | `Peak Queue Upper` | `Peak Queue Lower` |

For each: X-axis = `Dim_Condition[Condition]`. Format > Visual > **Columns** > **Colors** > fx > Format style **Field value** on the `Condition Color` measure
(Normal green, Surge red), because the theme does not recolour bars on its own. Format > Visual > **Error bars** > On, then set the **Upper bound** and
**Lower bound** fields from the table. If you do not see an Error bars card, update Power BI Desktop
(Help > About shows the version; Microsoft ships a monthly update). Turn data labels on, 1 decimal.

**Summary table.** Visualizations > **Matrix**. X 22, Y 362, W 1236, H 170.
Rows = `Dim_Condition[Condition]`. Values = `Arrivals (±SD)`, `Leave% (±SD)`, `Breach% (±SD)`, `Still_In (±SD)`.
Format > Cell elements, header background `#1B2A3B`, header font white. Matrix > Row headers: turn
Stepped layout off. Title: `Results Summary (n=5 runs each)`.

**Key findings box.** Insert > Text box. X 22, Y 544, W 1236, H 150. Three lines, for example:
- Surge doubles arrivals (129.8 vs 64.6 per run) and 4-hour breaches rise from 0% to 22.1%.
- The treatment queue peaks at 50.9 patients under Surge versus 11.0 under Normal.
- On average 76.4 patients are still in the system at the end of a Surge run versus 14.0 under Normal.

## Page 2: Queues and breaches over time (Figures 2 and 3)

Rename the page `Over time`. Copy the header text box from page 1 (change the subtitle if you like).

**Queue evolution** (two **Line charts**; X 22; W 770; H 300; Y 80 and Y 392):

- X-axis = `Timeseries[Time_Interval]` (set **Type: Continuous**).
- Y-axis = `Triage Queue Mean`, `Treatment Queue Mean`, `Total In System Mean`.
- Colors: Triage `#1F77B4`, Treatment `#FF7F0E`, Total `#2CA02C`. Markers On.
- Error bars On, per series: Triage (`Triage Queue Upper` / `Lower`), Treatment (`Treatment Queue Upper` / `Lower`),
  Total (`Total In System Upper` / `Lower`). Select the series in the Error bars card dropdown, then set its bounds.
- Filters pane > **Filters on this visual**: drag `Dim_Condition[Condition]` in, tick **Normal** on the top chart and **Surge** on the bottom chart.
- Titles: `Normal: Queue Evolution`, `Surge: Queue Evolution`. Y-axis title `Patients`, X-axis title `Time (min)`.
- Leave each chart's Y axis independent (Normal peaks near 13, Surge near 75), as in your figure.

**Breach rate over time** (two **Line charts**; X 804; W 454; H 300; Y 80 and Y 392):

- X-axis = `Timeseries[Time_Interval]` (Continuous). Y-axis = `Breach % Over Time Mean`.
- Error bars: Upper `Breach % Over Time Upper`, Lower `Breach % Over Time Lower`.
- Colors: Normal `#2E9E6B`, Surge `#E0314B`. Visual filter Condition = Normal (top), Surge (bottom).
- Titles: `Normal: Breach Rate`, `Surge: Breach Rate`. Y-axis title `Breach %`.

## Page 3: Patient flow and distributions (Figures 4 and 5)

Rename the page `Patients`.

**Waiting-time histograms** (two **Clustered column charts**; W 400; H 300; Y 80; X 22 = Normal, X 434 = Surge):

- X-axis = `Patients[Wait_Bin]` (Type: **Continuous**). Legend = `Patients[Acuity]`.
- Y-axis = **Count of** `Patients[Patient_ID]`.
- Colors: High `#E0314B`, Low `#4169E1`. Visual filter Condition = Normal / Surge.
- Titles: `Normal: Wait by Acuity`, `Surge: Wait by Acuity`. X title `Wait time (min, 20-min bins)`.

**Total-time histograms** (two **Column charts**; W 400; H 300; Y 392; X 22 = Normal, X 434 = Surge):

- X-axis = `Patients[Time_Bin]` (Continuous). Y-axis = Count of `Patients[Patient_ID]`.
- Colors > fx on the series colour > **Format style: Rules**, based on `Time_Bin` (Maximum):
  if value >= 240 then `#E0314B` (red = 4-hour breach). Default colour: Normal `#2E9E6B`, Surge `#F5A623`.
- Visual filter Condition = Normal / Surge. Titles: `Normal: Total Time`, `Surge: Total Time`. X title `Time in system (min, 20-min bins)`.
- Add a note in the subtitle: `Red bars = more than 4 hours`.

**Patient outcomes** (**Stacked column chart**; X 846; Y 80; W 412; H 612):

- X-axis = `Dim_Condition[Condition]`. Y-axis = `Completed`, `Patients Left`, `Still In System`.
- Colors `#2E9E6B`, `#F5A623`, `#E0314B`. Data labels On.
- Tooltips well: add `Completed %`, `Left %`, `Still In %`.
- Title: `Patient Outcomes by Condition`.

---

## Finish

1. View > **Page view** > Fit to page; check each page at full screen.
2. Optional: File > **Options** > Current file > Report settings, tick "Hide visual header" for a cleaner look, or set it per visual.
3. Save as `UTC_Normal_vs_Surge.pbix` in the `powerbi` folder.
4. Export screenshots for the README: File > **Export** > **Export to PDF**, or press **Win+Shift+S** on each page and save as `docs/dashboard_overview.png`, `docs/dashboard_over_time.png`, `docs/dashboard_patients.png`.

## Troubleshooting

| Symptom | Fix |
|---|---|
| Arrivals Mean looks wrong or blank | Relationships missing: check step 2, all four, direction Dim to fact |
| Numbers are 5x too large | A hidden fact-table `Run` or `Condition` is on the visual; use the `Dim_` fields |
| `Left` filter returns nothing | In Power Query set `Left` and `Breach_4_Hour` to **True/False** type |
| Histogram bars too thin | X-axis Continuous makes them thin; widen the chart or switch to Categorical |
| No Error bars card | Update Power BI Desktop to the latest release |
