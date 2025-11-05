✅ Features
🟢 Add and manage customers, drivers, and cabs
🟢 Automatically assign the first available cab and driver
🟢 Calculate fare based on distance with 5% GST added
🟢 Use of SQL Function – calculate_fare()
🟢 Use of Stored Procedure – book_cab_auto() for automatic booking
🟢 Use of Stored Procedure – cancel_booking() to cancel rides
🟢 Use of Triggers to update cab status from Available → Booked → Available
🟢 Ensures data integrity using Primary Keys, Foreign Keys & Constraints
🛠️ Technologies Used
Database: MySQL
Concepts: ADBMS, Stored Procedures, Functions, Triggers, Joins, Constraints
Tools: MySQL Workbench / XAMPP / phpMyAdmin
Language Used: Pure SQL (No frontend required)
📂 Database Structure
Tables Included:
drivers – Stores driver information
cabs – Stores cab details and availability status
customers – Stores customer information
bookings – Stores booking records including fare, distance, time
⚙️ How It Works
User books a cab → system checks for available cab and driver
Fare is auto-calculated using an SQL function
Booking details are inserted into the database
A trigger updates cab status from Available → Booked
On cancellation, booking is deleted and cab status is set to Available again
