/* Create "group_type" column based on Window Booking:
	- early_window_booking : window_booking > 30 days
	- short_window_booking : window_booking <= 30 days */
ALTER TABLE hotel_bookings
ADD group_type varchar(50);

UPDATE hotel_bookings
SET group_type = 
	(CASE 
		WHEN window_booking <= 30 THEN 'short_window_booking'
		WHEN window_booking > 30 THEN 'early_window_booking' END);

/* Create customer_bucket based on Window Booking:
	- bucket: 0-7 days -> Last-Minute
	- bucket: 8-30 days -> Medium Window
	- bucket: >30 days -> Early-Bird */

ALTER TABLE hotel_bookings
ADD customer_bucket varchar(50);

UPDATE hotel_bookings
SET customer_bucket = 
	(CASE
		WHEN bucket = '0-7 days' THEN 'Last-Minute'
		WHEN bucket = '8-30 days' THEN 'Medium-Window'
		WHEN bucket = '31-90 days' THEN 'Early-Bird'
		WHEN bucket = '91-180 days' THEN 'Early-Bird'
		WHEN bucket = '180+ days' THEN 'Early-Bird' END);