SELECT	TOP 5 *
FROM hotel_bookings;

-- Check Data Type
SELECT	COLUMN_NAME,
		DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'hotel_bookings' and TABLE_SCHEMA = 'dbo';
-------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Question 1: Why do Last-Minute (0-7 days) or Medium-Window (8-30 days) has fewer cancellations than Early-window booking (>30 days)? */

WITH customer_group_cancellations AS (
SELECT	customer_bucket,
		booking_status, deposit_type,
		(CASE WHEN booking_status = 'Cancelled' THEN 1 ELSE 0 END) as cancellations
FROM hotel_bookings
)
SELECT	customer_bucket,
		deposit_type,
		COUNT(*) as total_booking,
		SUM(cancellations) as total_cancellations,
		ROUND(
			SUM(cancellations) * 100.0 / 
			NULLIF(COUNT(*),0),2) as cancellation_rate
FROM customer_group_cancellations
GROUP BY customer_bucket, deposit_type
ORDER BY customer_bucket, deposit_type;
-------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Question 2: Within the Early-window booking groups, which bucket has the highest cancellations rate (31-90, 91-180, +180) ? */
WITH customer_group_cancellations_bucket AS (
SELECT	customer_bucket, 
		(CASE WHEN booking_status = 'Cancelled' THEN 1 ELSE 0 END) as cancellations,
		bucket
FROM hotel_bookings
),
total_cancellations as (
SELECT	SUM(cancellations) as total_cancellations
FROM customer_group_cancellations_bucket
WHERE customer_bucket = 'Early-Bird'
)
SELECT	cgcb.bucket, 
		COUNT(*) as total_bucket,
		SUM(cancellations) as bucket_cancell,
		ROUND(
			SUM(cancellations) * 100.0 /
			NULLIF(COUNT(*),0),2) as bucket_pct_cancell,
		ROUND(
			SUM(cancellations) * 100.0 /
			NULLIF(tc.total_cancellations,0),2) as total_bucket_pct_cancell
FROM customer_group_cancellations_bucket cgcb
CROSS JOIN total_cancellations tc
WHERE customer_bucket = 'Early-Bird'
GROUP BY cgcb.bucket, tc.total_cancellations
ORDER BY ROUND(SUM(cancellations) * 100.0 / NULLIF(tc.total_cancellations,0),2) DESC;
-------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Question 3: If the cancellations from Early-Booking groups continue, how much potential revenue will the hotel loss based on ADR ? */
-- Potential Revenue Loss = (ADR * Stay Duration [weekend_nights + week_nights])
WITH revenue_table AS (
SELECT	bucket, hotel_type,
		booking_status, weekend_nights, week_nights, adr
FROM hotel_bookings
WHERE customer_bucket = 'Early-Bird'
)
SELECT	bucket,
	-- City Hotel
		ROUND(SUM(CASE WHEN hotel_type = 'City Hotel' THEN adr * (weekend_nights +  week_nights) ELSE 0 END), 2) AS total_revenue_city,
		ROUND(SUM(CASE WHEN hotel_type = 'City Hotel' AND booking_status = 'Confirmed' THEN adr * (weekend_nights +  week_nights) ELSE 0 END), 2) AS confirmed_revenue_city,
		ROUND(SUM(CASE WHEN hotel_type = 'City Hotel' AND booking_status = 'Cancelled' THEN adr * (weekend_nights +  week_nights) ELSE 0 END), 2) AS potential_loss_city,
		ROUND(
			SUM(CASE WHEN hotel_type = 'City Hotel' AND booking_status = 'Cancelled' THEN adr * (weekend_nights +  week_nights) ELSE 0 END) * 100/ 
			SUM(CASE WHEN hotel_type = 'City Hotel' THEN adr * (weekend_nights +  week_nights) ELSE 0 END), 2) as pct_city_loss,
	-- Resort Hotel
		ROUND(SUM(CASE WHEN hotel_type = 'Resort Hotel' THEN adr * (weekend_nights +  week_nights) ELSE 0 END), 2) AS total_revenue_resort,
		ROUND(SUM(CASE WHEN hotel_type = 'Resort Hotel' AND booking_status = 'Confirmed' THEN adr * (weekend_nights +  week_nights) ELSE 0 END), 2) AS confirmed_revenue_resort,
		ROUND(SUM(CASE WHEN hotel_type = 'Resort Hotel' AND booking_status = 'Cancelled' THEN adr * (weekend_nights +  week_nights) ELSE 0 END), 2) AS potential_loss_resort,
		ROUND(
			SUM(CASE WHEN hotel_type = 'Resort Hotel' AND booking_status = 'Cancelled' THEN adr * (weekend_nights +  week_nights) ELSE 0 END) * 100/ 
			SUM(CASE WHEN hotel_type = 'Resort Hotel' THEN adr * (weekend_nights +  week_nights) ELSE 0 END), 2) as pct_resort_loss
FROM revenue_table
GROUP BY bucket
ORDER BY potential_loss_city desc, potential_loss_resort desc;
-------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Question 4: Are the ADR of cancelled bookings higher or lower than the ADR of confirmed bookigns?*/
SELECT	bucket,
		SUM(CASE WHEN hotel_type = 'Resort Hotel' AND booking_status = 'Cancelled' THEN 1 ELSE 0 END) as resort_cancell,
		ROUND(AVG(CASE WHEN hotel_type = 'Resort Hotel' AND booking_status = 'Confirmed' THEN adr END),2) as avg_resort_conf,
		ROUND(AVG(CASE WHEN hotel_type = 'Resort Hotel' AND booking_status = 'Cancelled' THEN adr END),2) as avg_resort_cancell,
		SUM(CASE WHEN hotel_type = 'City Hotel' AND booking_status = 'Cancelled' THEN 1 ELSE 0 END) as city_cancell,
		ROUND(AVG(CASE WHEN hotel_type = 'City Hotel' AND booking_status = 'Confirmed' THEN adr END),2) as avg_city_conf,
		ROUND(AVG(CASE WHEN hotel_type = 'City Hotel' AND booking_status = 'Cancelled' THEN adr  END),2) as avg_city_cancell
FROM hotel_bookings
GROUP BY bucket
ORDER BY city_cancell desc, resort_cancell desc;
------------------------------------------------------------------------------------------------------------------------------------------------------------





