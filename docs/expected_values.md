# Expected values (use these to check your dashboard)

All values were recomputed from the CSVs in `/data` and match the dissertation
figures. Mean ± sample SD across the 5 runs.

## Figure 1 and Summary table

| Measure | Normal | Surge |
|---|---|---|
| Arrivals | 64.6 ± 10.8 | 129.8 ± 9.1 |
| Leave % (LWBS) | 2.3 ± 2.0 | 5.0 ± 2.4 |
| Breach % (at end, 450 min) | 0.0 ± 0.0 | 22.1 ± 7.2 |
| Still in system | 14.0 ± 8.3 | 76.4 ± 8.1 |
| Wait time (min), `Avg_Waiting_Time` at 450 min | 41.2 ± 19.6 | 94.0 ± 29.2 |
| Peak queue (max `Queue_Treatment` per run) | 11.0 ± 2.9 | 50.9 ± 5.3 |

## Figure 5 (totals over the 5 runs)

| | Normal | Surge |
|---|---|---|
| Arrivals | 323 | 649 |
| Completed | 245 (76%) | 235 (36%) |
| Left | 8 (2%) | 32 (5%) |
| Still in system | 70 (22%) | 382 (59%) |

## Figure 4

- Surge 4-hour breaches (`Time_Bin` >= 240): **144** patients; Normal: **0**.
- Acuity mix: Normal 277 Low / 46 High; Surge 558 Low / 91 High.

## Why the `summary` CSV is not used

`UTC_summary_dissertation.csv` reports patient-level means (for example mean
waiting time 42.8 and 143.9 min) and has no standard deviations. The dissertation
figures use per-run values at the end of the simulation (94.0 min for Surge), so
the two do not agree.
