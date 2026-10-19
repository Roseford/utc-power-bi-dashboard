// ============================================================================
// UTC Normal vs Surge - Power Query (M) scripts
//
// SETUP (once):
//   Home > Transform data > Manage Parameters > New Parameter
//     Name: DataFolder    Type: Text    Current Value: the full path to the
//     /data folder WITH a trailing backslash, e.g.
//     C:\Users\you\utc-power-bi-dashboard\data\
//
// Then create two Blank Queries (Home > New Source > Blank Query), open
// Advanced Editor on each, and paste ONE query below (everything between the
// "=== QUERY" markers). Name them exactly: Patients and Timeseries.
// ============================================================================


// === QUERY 1 : name it  Patients =============================================
let
    Load = (fileName as text) as table =>
        Table.PromoteHeaders(
            Csv.Document(
                File.Contents(DataFolder & fileName),
                [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
            ),
            [PromoteAllScalars = true]
        ),

    Combined = Table.Combine({
        Load("UTC_patients_NORMAL_dissertation.csv"),
        Load("UTC_patients_SURGE_dissertation.csv")
    }),

    Typed = Table.TransformColumnTypes(
        Combined,
        {
            {"Run", Int64.Type}, {"Condition", type text}, {"Patient_ID", Int64.Type},
            {"Acuity", type text}, {"Arrival_Time", Int64.Type},
            {"Triage_Wait_Time", Int64.Type}, {"Treatment_Wait_Time", Int64.Type},
            {"Total_Wait_Time", Int64.Type}, {"Waiting_Time", Int64.Type},
            {"Total_Time_In_System", Int64.Type}, {"Triage_Duration", Int64.Type},
            {"Treatment_Duration", Int64.Type}, {"Left", type logical},
            {"Breach_4_Hour", type logical}, {"Leave_Type", type text}
        },
        "en-US"
    ),

    // "high"/"low" -> "High"/"Low" (matches the dissertation figures)
    Acuity = Table.TransformColumns(Typed, {{"Acuity", Text.Proper, type text}}),

    // empty Leave_Type -> "Did not leave"; "random"/"patience" -> "Random"/"Patience"
    LeaveClean = Table.TransformColumns(
        Acuity,
        {{"Leave_Type",
          each if _ = null or _ = "" then "Did not leave" else Text.Proper(_),
          type text}}
    ),

    // 20-minute bins used by the histogram visuals (Figure 4)
    WaitBin = Table.AddColumn(
        LeaveClean, "Wait_Bin",
        each Number.RoundDown([Waiting_Time] / 20) * 20, Int64.Type
    ),
    TimeBin = Table.AddColumn(
        WaitBin, "Time_Bin",
        each Number.RoundDown([Total_Time_In_System] / 20) * 20, Int64.Type
    )
in
    TimeBin


// === QUERY 2 : name it  Timeseries ===========================================
let
    Load = (fileName as text) as table =>
        Table.PromoteHeaders(
            Csv.Document(
                File.Contents(DataFolder & fileName),
                [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
            ),
            [PromoteAllScalars = true]
        ),

    Combined = Table.Combine({
        Load("UTC_timeseries_NORMAL_dissertation.csv"),
        Load("UTC_timeseries_SURGE_dissertation.csv")
    }),

    Typed = Table.TransformColumnTypes(
        Combined,
        {
            {"Condition", type text}, {"Run", Int64.Type}, {"Time_Interval", Int64.Type},
            {"Queue_Triage", type number}, {"Queue_Treatment", type number},
            {"Total_In_System", type number}, {"Patients_Completed", Int64.Type},
            {"Patients_Left", Int64.Type}, {"Avg_Waiting_Time", type number},
            {"Avg_Triage_Wait_Time", type number}, {"Avg_Treatment_Wait_Time", type number},
            {"Avg_Total_Wait_Time", type number}, {"Breach_Count", Int64.Type},
            {"Breach_Percentage", type number}
        },
        "en-US"
    )
in
    Typed

// NOTE: UTC_summary_dissertation.csv is intentionally NOT loaded. Its means are
// patient-level and it has no standard deviations, so it cannot reproduce the
// dissertation figures (see BUILD_GUIDE.md, section 0).
