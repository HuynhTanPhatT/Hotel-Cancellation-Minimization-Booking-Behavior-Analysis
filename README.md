# 🏩Hotel Booking Demand & Cancellation Analysis - Understanding Long Booking Window with No Deposit Policy (07/2015 - 10/2017)
- Author: Huỳnh Tấn Phát
- Date: 10/2025
- Tool Used: `Python`, `SQL`, `PowerBi`
    - Python: Pandas, Matplotlib, Numpy, Datetime
    - SQL: CTEs, Joins, Case, aggregate functions
    - PowerBi: Dax, calculated columns, data visualizaition, data modeling
# ReadMe - Table Of Contents (TOCs)
1. [Background & Objective]()
2. [Dataset Description]()
3. [Design Thinking Process]()
4. [Data Processing & Metrics Defination (Dax)]()
5. [Hotel Room Reservation Timeline]()
6. [Key Insights & Visualizations]()
7. [Cancellation Policy Hypothesis & Recommendations]()
# 📌Background & Objective
## Background: 
- During **2015-2017**, the hotel chain in Portugal — one property in **Lisbon City**, and another in **Algarve Resort** recorded more than **100.000** bookings from over **100** countries, made through channels (`TA/TO`, `Corporate`, `Direct` , `GDS` ).
- However, the **Revenue Manager** is facing some business challenges,  notably **30% cancellation rate**. If this continues, the hotel will lose a significant amount of `potential revenue` and affect room allocation.

## Objective:
📖What is this probject about?
This project aims to provide the **Revenue Manager** with **data-driven insights** to:
- Understand the current business performance
- Identify the root cause of cancellations.
- Uncover guest behavior pattern for cancellations.
- Support better decision-making to decrease cancellations.

🥷 Who is this project for ?
- Revenue Manager
- Operation Team

❓ Business Question:
- What is the current performance of the hotels?
- Which segments contribute the most to the cancellation rate?
- How much revenue did the hotel lose due to cancelled bookings?
- Which segments and guest groups should be prioritized for improvement?

# Dataset Description
## 📌Data Source:
- Source:
    - [Kaggle](https://www.kaggle.com/datasets/jessemostipak/hotel-booking-demand/data)
    - [Science Direct with Metadata](https://www.sciencedirect.com/science/article/pii/S2352340918315191)
- Size: The `hotel_booking_table` contains more than **+100.000** records.
- Format: CSV

# Data Processing by Python & SQL & DAX
1. Using [Python](https://github.com/HuynhTanPhatT/Hotel-Booking-Demand-Cancellation-Analysis-/tree/main/Python%3A%20Data%20Cleaning%20%26%20EDA) to: 
    - `Data Cleaning`: check data quality, handle null values, convert data types, detect data anamalies, and remove duplicate records.
    - `Exploratory Data Analysis (EDA)`: identify the **pain points** of stakeholder (**Revenue Manager**).

2. Using [SQL](https://github.com/HuynhTanPhatT/Hotel-Booking-Demand-Cancellation-Analysis-/tree/main/SQL%3A%20Answering%20Questions%20from%20the%20Define%20Stage%20of%20Design%20Thinking) to:
    - Answer detailed questions based on the **pain points** to define `a clearly analytical direction` for the Power Bi dashboard.
3. DAX Calculations & Formulas
- `Employ some several DAX formulas to calculate Key Performance Indicators (KPIs)`:
<details>
    <summary>Click to view examples of DAX formulas</summary>
    <br>

- **Cancelled Booking**:
```dax
Cancelled Booking= CALCULATE(
        COUNTROWS(FactTable),
        FILTER(DimBookingStatus,
        DimBookingStatus[booking_status] = "Cancelled"))

cancelled_bookings_pct = 
VAR cancellations = CALCULATE(
        COUNTROWS(FactTable),
        FILTER(DimBookingStatus,
        DimBookingStatus[booking_status] = "Cancelled"))
VAR total_bookings = CALCULATE(COUNTROWS(FactTable))
RETURN
DIVIDE(cancellations,total_bookings)
```

- **Revenue**:
```dax
Revenue = sumx(FactTable,
                FactTable[adr] * (FactTable[week_nights] + FactTable[weekend_nights]))
```
- **Revenue Loss**:
```dax
Revenue Loss = 
 VAR revenue_loss = CALCULATE(
    sumx(FactTable,
        FactTable[adr] * (FactTable[week_nights] + FactTable[weekend_nights])),
        FILTER(DimBookingStatus,DimBookingStatus[booking_status] = "Cancelled"))
RETURN
revenue_loss
```

- **Avg.Daily Rate**:
```dax
Avg Daily Rate (ADR) = 
DIVIDE(
    CALCULATE(
       sumx(FactTable,
            FactTable[adr] * (FactTable[week_nights] + FactTable[weekend_nights]))),
    CALCULATE(
        SUMX(FactTable,FactTable[stay_duration])))
```

- **Avg.Window Booking**:
```dax
Avg Window Booking = 
DIVIDE(
    CALCULATE(
        SUMX(FactTable,FactTable[window_booking])),
    CALCULATE(
        COUNTROWS(FactTable)))
```

- **Avg. Length of Stay**:
```dax
Avg Length Of Stay = 
VAR room_nights = CALCULATE(
    SUMX(FactTable,
    FactTable[week_nights] + FactTable[weekend_nights]))
VAR total_bookings = [1_total_bookings]
RETURN
DIVIDE(room_nights,total_bookings)
```
</details>


- `Employ some several DAX formulas to calculate Custom Measure`: 
<details>
    <summary>Click to view examples of DAX formulas</summary>
    <br>

- **Days to Cancellation**:
```dax
days_to_cancellation = FactTable[reservation_date] - FactTable[BookingDate]
Avg Days to Cancellation = AVERAGE(FactTable[days_to_cancellation])
```

- **Cancellation Lead Time**:
```dax
cancellation_lead_time = FactTable[check_in] - FactTable[reservation_date]
Avg Cancellation Lead Time = AVERAGE(FactTable[cancellation_lead_time])
```

- **Repeated Guest**:
```dax
repeated_guests = 
VAR repeated_guests = 
CALCULATE(
    [1_cancelled_bookings],
    filter(DimCustomer,DimCustomer[repeated_guest] = "Yes"))
VAR total_guests = CALCULATE(
    [1_cancelled_bookings])
RETURN
DIVIDE(repeated_guests,total_guests)
```

- **Non Repeated Guest**:
```dax
non_repeated_guests = 
VAR non_repeated_guests = 
CALCULATE(
    [1_cancelled_bookings],
    filter(DimCustomer,DimCustomer[repeated_guest] = "No"))
VAR total_guests = CALCULATE(
    [1_cancelled_bookings])
RETURN
DIVIDE(non_repeated_guests,total_guests)
```
</details>


# 🧠Design Thinking Process
## 1️⃣Empathize
<img width="1230" height="696" alt="image" src="https://github.com/user-attachments/assets/1017d84f-139e-453f-b793-4dfe72f70c62" />


## 2️⃣Define
<img width="1231" height="690" alt="image" src="https://github.com/user-attachments/assets/4ea8687a-9e8e-4b6d-96f6-b2fd0ac8e24f" />


## 3️⃣Ideate
<img width="1234" height="692" alt="image" src="https://github.com/user-attachments/assets/01fbd6ec-f4c1-4390-90df-67d34702265a" />


## 4️⃣Prototype
This part will be in **Key Insights & Visualization** section.


# 🔗Hotel Room Reservation Booking Timeline
<img width="1237" height="693" alt="image" src="https://github.com/user-attachments/assets/a4c486b1-5d63-496f-92a5-c93739358ac5" />



# 📊Key Insights & Visualizations
## I. Business Overview
<img width="1298" height="726" alt="image" src="https://github.com/user-attachments/assets/491ad19b-0998-47c0-abc4-3bb2158fbfec" />


- The total number of bookings recorded from (07/2015 -> 08/2017) was **86.113** bookings:
    - `Confirmed Booking`: **62.109 bookings** (**72%**)
    - `Cancelled Bookings`: **24.004 bookings** (**28%**)
1. **Booking Behavior**:
    - Customer booking trends leaned toward the early-mid months of the year, consistently exceeding the average bookings (**March** - **August**)
    
   -> Showing the hotel booking trend focused during the **peak travel seasons** (`spring`, `summer` and `autumn`) which are the best in terms of visiting **Portugal**.

2. **Revenue & Revenue Loss & Cancellations**:
    - Revenue increased steadily over the years, reaching **$34.41M** in 08/2017. However, **24.004** cancelled bookings led to a potential revenue of **$11.48M** (accounted for **33.37%** of the total revenue).

3. **Average Window Booking** & **ADR**:
    - The hotel applied a **flexible seasonal pricing strategy** with ADR (**$68**-**$183**) to optimize revenue. They set lower ADR during the **off season** (`winter`) and increased ADR during the **peak season**.
    - Customers tended to book early, on average (2-4 months before check-in), especially before the peak season when ADRs were lower in the off season.

    -> The hotel attracted **early-bird bookings**, particularly during the **peak travel season**.

5. **Region & Market & Deposit Type**:
   - `European guests` accounted for **$30M**(**88.54%**) of total revenue but also had the highest rate of cancellations (**86.84%**)
   - The `TA/TO channel ` generated the highest revenue (**$29M** loss) while  contributing to **89.14%** of total cancellations.
   - **95.8%** of all cancellations came from bookings under the `No Deposit` payment option.
     
=> **`The 3 main factors driving the highest revenue loss and cancellations are European guests, TA/TO channel, and the No Deposit policy.`**

## II. Guest Behavior Analysis
<img width="1303" height="728" alt="image" src="https://github.com/user-attachments/assets/5128b36b-df75-4857-813f-b2a6249b5665" />

1. **Correlation between Window Booking Bucket & Cancellation Behavior**:
    - Guests' booking behavior shows a clear pattern: `the longer the booking window, the higher the cancellation rate`.
    - Most cancellations come from within `31-180+ day` bucket, with the `91-180 days` and `180+ days` buckets showing the highest cancellation rates (**60%**-**100%**)

    -> A trend of booking early to secure rooms in advance, then cancelling later.

2. **The cancellation rate within peak season**:
    - During `spring` and `summer` (the peak travel season) - guests booked and cancelled the most (mainly within `31-90 days` & `91-180 days`) buckets.

3. **Most impacted Guest segment**:
    - `Early-Bird guests` accounted for the majority of cancellations (**78%**-**82%** across hotel types). Mainly `domestict Transient guests` from `Portugal` contributed to cancellations about **30%** in City and **60%** in Resort bringing in an estimated **$8.6M** revenue loss out of a total **$11.48M**.

- `Why do guests prefer Long-Window Booking?`
    - They prefer flexibility: booked early to secure their spot, with no deposit involed, they do not need to pay any fees until check-in.
    - Additionally, they could easily to cancel or alter their reservation if something unexpected or find a better deals.
    
=> **`The No Deposit policy, with Early-Bird behavior drives "book early - cancel easily", resulting in high cancellation rates among long-window bookings.`**

## III. Operation Analysis
<img width="1303" height="730" alt="image" src="https://github.com/user-attachments/assets/9d4516fa-2459-472a-975e-e7f54959926f" />

1. **New guests or Old guest canceled the most ?**
    - Cancellation behavior came mostly from **new guests**, accounting for more than **99%** of all cancellations in both the City and Resort hotels.
  
   -> This indicates that `No Deposit` bookings through `TA/TO` channels are largely **non-guaranteed guests**. It makes the hotel difficult for predicting the "book-cancel" behavior of new guests.

2. **Cancellation Behavior of Early-Bird Guests**
    - `Days to Cancellation`
        - On average, guests cancel **46.26** days after making a reservation
        - City & Resort Hotel: many guests cancel **on the same day** they made booking (**972 cancellations** - **12.18%** of total cancellations)

       -> The earlier cancellation, the easier for both hotels to manage room iventory and resell those rooms in time.

    - `Cancellation Lead Time`
        - On average, guests cancel **82.10** days before check-in date
        - Some guests cancel close to check-in date.
            - City Hotel: ~**800** cancellations occured within 7 days of check-in, including **239** made on the check-in day(3% of all cancellations)
            - Resort Hotel: the pattern of cancellations within 7 days of check-in exceeded the average, including  **92** same-day check-in cancellations - with a high volume of cancelled bookings in the week before check-in.



3. **Consequences**
    - `For the Hotel`:
        - Last-Minute cancellation on the check-in day resulted in **331**  unsold rooms, with no time to resell them -> This directly impacted the **Occupancy Rate** and **potential revenue**.
    - `For Guests`:
        - If guests cancel too late and outside the allowed cancellation policy, they may be charged a penalty on their credit card (depending on each hotel's policy)


# 💡Cancellation Policy Hypothesis & Recommendations

⚙️Cancellation Policy Hypothesis based on `Cancellation Lead Time`



| **Hotel Type**             | **Insight**                                                                                                 | **Cancellation Policy**                                                              | **Late Cancelaltion Policy**                                                                                                                                                                                                                 |
| -------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **City Hotel (Lisbon)**    | `The 0–7 day Cancellation Lead Time` recorded the highest volume (**761 cancellations**), including **239 same-day cancellations (3%)**.                | Guests are allowed to cancel **up to 48 hours before Check-In** without penalty. | - Cancellations made **within 48 hours** before check-in are likely charged to the guest’s credit card. <br> - ⚙️ Based on the Cancellation Lead Time pattern: **Day 0 and Day 1 cancellations violate the hotel’s policy**. |
| **Resort Hotel (Algarve)** | `The 0–7 day Cancellation Lead Time` recorded **212 cancellations**, lower than the City hotel, but still above average — including **92 same-day cancellations**. | Guests are allowed to cancel **up to 7 days before Check-In** without penalty.   | - Cancellations made **within 7 days** before Check-In are likely charged to the guest’s credit card. <br> - ⚙️ Based on the Cancellation Lead Time pattern: **Day 0 to Day 7 cancellations violate the hotel’s policy**.                     |


💡Recommendation: Focusing on they key segments (**12.67K** out of **24.00K** cancellations) provides the hotel with solutions that can improve the cancellation problem.










                                                                                                               
                                                                                                                
| **Who**             | **Strategy**                  | **Insight**                                                                                                                                                                                                                                                                                                                                                      | **Recommendation**                                                                                                                                                                                                                                                                                              |
|---------------------|-------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Revenue Manager** | **1.🎯Build Customer Loyalty** | • ⇑99% of cancellations in the key segments came from **new guests** (first-time bookers across both hotels).<br> • These guests tend to "book early to secure a room" in **31-180 days** bucket <br> • The **No Deposit** policy turns the guests into "non-guaranteed", making it hard for the hotel to predict "whether they come" or "when they will cancel". | (1)**💡Create a small-deposit opportunity for early-bird**<br>- If guests book in advance (>120 days), the hotel can offer a discount rate for early commitment during peak season -> `A small deposit can discourage casual cancellations`.<br><br>(2) **💡Increase the guest return rate**<br>- Revenue Manager should build **customer loyalty** for both hotel types targeting: **long-term business**, **"non-guaranteed"** to **"guaranteed"** guests. | **Revenue Manager** && **Operation Team** | **2.🚀Review Cancellation Policy** | <br> • The hotel should avoid same-day check-in cancellation |(1) **💡**💡Review and improve the cancellation policy to prevent same-day check-in cancellations**  <br> - After a guest books a room, proactively send the cancellation policy, especially for TA/TO and No Deposit reservations. <br>- Ensure the policy is clearly visible (Booking Page, Email,etc) <br><br> **(2)💡Improve room operations and track room availability** (48 hours for City Hotel and 1 week for Resort Hotel) to: <br>- Allow the hotel to sell rooms in time for Last-Minute bookings and fill empty rooms.<br> - Reduce 331 cancellations on the day of check-in (2.61%) <br><br> **(3)💡What to do when cancellations happen on the check-in date** <br>- The hotel can promote last-minute deals through email to their customer list. |









