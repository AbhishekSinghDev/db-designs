# Challenge #5 — Payments & Billing
## Design a schema for a SaaS subscription billing system (think Stripe, Paddle):

- A customer can subscribe to a plan (free, starter, pro, enterprise)
- Plans have a billing cycle: monthly or yearly
- A customer can only have one active subscription at a time
- Subscriptions have a status: active, cancelled, past_due, trialing
- Track invoices — generated every billing cycle
- Each invoice has line items (what they're being charged for)
- Invoices have a status: draft, open, paid, void
- Track payment attempts on an invoice — a payment can fail and be retried
- Payment attempts have a status: pending, succeeded, failed
- Store which payment method was used (card last 4 digits, type: card, upi, netbanking)
