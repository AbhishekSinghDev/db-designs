# Challenge #4 — Booking System
## Design a schema for a hotel/property booking platform (think Booking.com):

- Properties can have multiple room types (e.g. Standard, Deluxe, Suite)
- Each room type has a base price per night
- A property can have multiple actual rooms of a given room type (e.g. 5 Standard rooms)
- Users can book a room for a date range (check-in, check-out)
- No double booking — the same room cannot be booked by two users for overlapping dates
- Bookings have a status: pending, confirmed, cancelled, completed
- Track the total price at time of booking
- Properties belong to a host (a user with host role)
- Users can leave reviews for properties — only if they have a completed booking there
