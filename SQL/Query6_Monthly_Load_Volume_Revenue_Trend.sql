WITH monthly_summary AS (
    SELECT
        YEAR(CAST(load_date AS DATE))                              AS load_year,
        MONTH(CAST(load_date AS DATE))                             AS load_month,
        FORMAT(CAST(load_date AS DATE), 'yyyy-MM')                 AS year_month,
        COUNT(load_id)                                             AS total_loads,
        ROUND(SUM(CAST(revenue AS DECIMAL(10,2))), 2)             AS total_revenue,
        ROUND(SUM(CAST(fuel_surcharge AS DECIMAL(10,2))), 2)      AS total_fuel_surcharge,
        ROUND(SUM(CAST(accessorial_charges AS DECIMAL(10,2))), 2) AS total_accessorial,
        ROUND(SUM(CAST(revenue AS DECIMAL(10,2))) +
              SUM(CAST(fuel_surcharge AS DECIMAL(10,2))) +
              SUM(CAST(accessorial_charges AS DECIMAL(10,2))), 2)  AS total_billed
    FROM loads
    GROUP BY
        YEAR(CAST(load_date AS DATE)),
        MONTH(CAST(load_date AS DATE)),
        FORMAT(CAST(load_date AS DATE), 'yyyy-MM')
)
SELECT
    year_month,
    load_year,
    load_month,
    total_loads,
    total_revenue,
    total_fuel_surcharge,
    total_accessorial,
    total_billed,
    LAG(total_loads) OVER (ORDER BY load_year, load_month)        AS prev_month_loads,
    total_loads - LAG(total_loads)
        OVER (ORDER BY load_year, load_month)                     AS load_volume_change,
    LAG(total_revenue) OVER (ORDER BY load_year, load_month)      AS prev_month_revenue,
    ROUND(total_revenue - LAG(total_revenue)
        OVER (ORDER BY load_year, load_month), 2)                 AS revenue_change,
    ROUND(
        (total_revenue - LAG(total_revenue)
            OVER (ORDER BY load_year, load_month)) * 100.0
        / NULLIF(LAG(total_revenue)
            OVER (ORDER BY load_year, load_month), 0),
    2)                                                            AS revenue_mom_pct
FROM monthly_summary
ORDER BY load_year, load_month;