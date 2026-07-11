WITH maintenance_summary AS (
    SELECT
        tk.truck_id,
        tk.make,
        tk.model_year,
        tk.status,
        COUNT(mr.maintenance_id)                                    AS total_services,
        ROUND(SUM(CAST(mr.total_cost AS DECIMAL(10,2))), 2)        AS total_maintenance_cost,
        ROUND(AVG(CAST(mr.total_cost AS DECIMAL(10,2))), 2)        AS avg_cost_per_service,
        ROUND(SUM(CAST(mr.labor_cost AS DECIMAL(10,2))), 2)        AS total_labor_cost,
        ROUND(SUM(CAST(mr.parts_cost AS DECIMAL(10,2))), 2)        AS total_parts_cost,
        ROUND(SUM(CAST(mr.downtime_hours AS DECIMAL(10,2))), 2)    AS total_downtime_hours,
        ROUND(AVG(CAST(mr.downtime_hours AS DECIMAL(10,2))), 2)    AS avg_downtime_per_service
    FROM trucks tk
    LEFT JOIN maintenance_records mr ON tk.truck_id = mr.truck_id
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
    total_services,
    total_maintenance_cost,
    avg_cost_per_service,
    total_labor_cost,
    total_parts_cost,
    total_downtime_hours,
    avg_downtime_per_service,
    RANK() OVER (ORDER BY avg_cost_per_service DESC)            AS cost_rank,
    ROUND(AVG(total_maintenance_cost) OVER (), 2)              AS fleet_avg_maintenance_cost,
    CASE
        WHEN total_maintenance_cost > AVG(total_maintenance_cost) OVER ()
        THEN 'Above Average'
        ELSE 'Below Average'
    END                                                        AS cost_vs_fleet
FROM maintenance_summary
ORDER BY cost_rank;