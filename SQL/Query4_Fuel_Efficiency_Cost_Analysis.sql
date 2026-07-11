WITH truck_metrics AS (
    SELECT
        tk.truck_id,
        tk.make,
        tk.model_year,
        tk.status,
        COUNT(DISTINCT t.trip_id)                                      AS total_trips,
        ROUND(AVG(CAST(t.average_mpg AS DECIMAL(10,2))), 2)           AS avg_mpg,
        ROUND(SUM(CAST(fp.total_cost AS DECIMAL(10,2))), 2)           AS total_fuel_cost,
        ROUND(SUM(CAST(t.actual_distance_miles AS DECIMAL(10,2))), 2) AS total_miles,
        ROUND(
            SUM(CAST(fp.total_cost AS DECIMAL(10,2))) /
            NULLIF(SUM(CAST(t.actual_distance_miles AS DECIMAL(10,2))), 0),
        2)                                                             AS cost_per_mile
    FROM trucks tk
    LEFT JOIN trips t ON tk.truck_id = t.truck_id
    LEFT JOIN fuel_purchases fp ON t.trip_id = fp.trip_id
    GROUP BY
        tk.truck_id,
        tk.make,
        tk.model_year,
        tk.status
)
SELECT
    truck_id,
    make,
    model_year,
    status,
    total_trips,
    avg_mpg,
    total_fuel_cost,
    total_miles,
    cost_per_mile,
    ROUND(AVG(avg_mpg) OVER (), 2)                AS fleet_avg_mpg,
    CASE
        WHEN avg_mpg > AVG(avg_mpg) OVER ()
        THEN 'Above Average'
        ELSE 'Below Average'
    END                                           AS mpg_vs_fleet
FROM truck_metrics
WHERE cost_per_mile IS NOT NULL
ORDER BY cost_per_mile DESC;