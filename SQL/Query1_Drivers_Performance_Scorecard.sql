SELECT
    d.driver_id,
    d.first_name + ' ' + d.last_name                         AS driver_name,
    d.home_terminal,
    d.years_experience,
    COUNT(t.trip_id)                                          AS total_trips,
    ROUND(AVG(CAST(t.average_mpg AS DECIMAL(10,2))), 2)      AS avg_mpg,
    ROUND(AVG(CAST(t.idle_time_hours AS DECIMAL(10,2))), 2)  AS avg_idle_hours,
    ROUND(AVG(CAST(t.actual_distance_miles AS DECIMAL(10,2))), 2) AS avg_trip_distance_miles,
    ROUND(
        SUM(CASE WHEN de.on_time_flag = 'TRUE' THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(de.event_id), 0),
    2)                                                        AS on_time_rate_pct,
    RANK() OVER (ORDER BY
        SUM(CASE WHEN de.on_time_flag = 'TRUE' THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(de.event_id), 0) DESC)                AS performance_rank
FROM drivers d
LEFT JOIN trips t ON d.driver_id = t.driver_id
LEFT JOIN delivery_events de ON t.trip_id = de.trip_id
GROUP BY
    d.driver_id,
    d.first_name,
    d.last_name,
    d.home_terminal,
    d.years_experience
ORDER BY performance_rank;