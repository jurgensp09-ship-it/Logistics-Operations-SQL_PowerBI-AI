WITH route_financials AS (
    SELECT
        r.route_id,
        r.origin_city + ', ' + r.origin_state + ' → ' +
        r.destination_city + ', ' + r.destination_state    AS route_name,
        r.typical_distance_miles,
        r.typical_transit_days,
        COUNT(l.load_id)                                   AS total_loads,
        ROUND(SUM(CAST(l.revenue AS DECIMAL(10,2))), 2)   AS total_revenue,
        ROUND(SUM(CAST(l.fuel_surcharge AS DECIMAL(10,2))), 2) AS total_fuel_surcharge,
        ROUND(SUM(CAST(l.accessorial_charges AS DECIMAL(10,2))), 2) AS total_accessorial,
        ROUND(SUM(CAST(l.revenue AS DECIMAL(10,2))) +
              SUM(CAST(l.fuel_surcharge AS DECIMAL(10,2))) +
              SUM(CAST(l.accessorial_charges AS DECIMAL(10,2))), 2) AS total_billed,
        ROUND(AVG(CAST(t.average_mpg AS DECIMAL(10,2))), 2) AS avg_mpg
    FROM routes r
    LEFT JOIN loads l ON r.route_id = l.route_id
    LEFT JOIN trips t ON l.load_id = t.load_id
    GROUP BY
        r.route_id,
        r.origin_city,
        r.origin_state,
        r.destination_city,
        r.destination_state,
        r.typical_distance_miles,
        r.typical_transit_days
)
SELECT
    route_id,
    route_name,
    typical_distance_miles,
    typical_transit_days,
    total_loads,
    total_revenue,
    total_fuel_surcharge,
    total_accessorial,
    total_billed,
    avg_mpg,
    ROUND(total_billed / NULLIF(typical_distance_miles, 0), 2) AS revenue_per_mile,
    RANK() OVER (ORDER BY
        total_billed / NULLIF(typical_distance_miles, 0) DESC) AS profitability_rank
FROM route_financials
ORDER BY profitability_rank;