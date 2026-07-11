SELECT
    c.customer_id,
    c.customer_name,
    c.customer_type,
    c.primary_freight_type,
    COUNT(DISTINCT l.load_id)                                  AS total_loads,
    ROUND(
        SUM(CASE WHEN de.on_time_flag = 'TRUE' THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(de.event_id), 0),
    2)                                                         AS on_time_rate_pct,
    ROUND(AVG(CAST(de.detention_minutes AS DECIMAL(10,2))), 2) AS avg_detention_minutes,
    SUM(CASE WHEN de.on_time_flag = 'FALSE' THEN 1 ELSE 0 END) AS total_late_deliveries,
    CASE
        WHEN SUM(CASE WHEN de.on_time_flag = 'TRUE' THEN 1 ELSE 0 END) * 100.0
             / NULLIF(COUNT(de.event_id), 0) < 55
        THEN 'Below Threshold'
        ELSE 'Acceptable'
    END                                                        AS service_flag
FROM customers c
LEFT JOIN loads l ON c.customer_id = l.customer_id
LEFT JOIN delivery_events de ON l.load_id = de.load_id
GROUP BY
    c.customer_id,
    c.customer_name,
    c.customer_type,
    c.primary_freight_type
ORDER BY on_time_rate_pct ASC;