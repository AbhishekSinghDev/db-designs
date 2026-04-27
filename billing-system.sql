CREATE TYPE billing_cycle_enum AS ENUM (
    'monthly',
    'yearly'
);

CREATE TYPE subscription_status_enum AS ENUM (
    'active',
    'cancelled',
    'past_due',
    'trialing'
);

CREATE TYPE invoice_status_enum AS ENUM (
    'draft',
    'open',
    'paid',
    'void'
);

CREATE TYPE payment_attempt_status_enum AS ENUM (
    'pending',
    'succeeded',
    'failed'
);

CREATE TYPE payment_method_type_enum AS ENUM (
    'card',
    'upi',
    'netbanking'
);

CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL UNIQUE,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    billing_cycle billing_cycle_enum NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE payment_methods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    type payment_method_type_enum NOT NULL,
    card_last_four VARCHAR(4),
    is_default BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_payment_method_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    CONSTRAINT card_requires_digits CHECK (
        type != 'card' OR card_last_four IS NOT NULL
    )
);

CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    plan_id UUID NOT NULL,
    status subscription_status_enum NOT NULL DEFAULT 'trialing',
    trial_ends_at TIMESTAMP,
    current_period_start TIMESTAMP NOT NULL,
    current_period_end TIMESTAMP NOT NULL,
    cancelled_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_subscription_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
    CONSTRAINT fk_subscription_plan FOREIGN KEY (plan_id) REFERENCES plans(id)
);

-- one active subscription per customer
CREATE UNIQUE INDEX one_active_subscription_per_customer
ON subscriptions (customer_id) WHERE status = 'active';

CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID NOT NULL,
    status invoice_status_enum NOT NULL DEFAULT 'draft',
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    sub_total NUMERIC(10,2) NOT NULL,
    discount NUMERIC(10,2) NOT NULL DEFAULT 0,
    total_due NUMERIC(10,2) NOT NULL,
    amount_paid NUMERIC(10,2) NOT NULL DEFAULT 0,
    amount_remaining NUMERIC(10,2) NOT NULL,
    paid_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_invoice_subscription FOREIGN KEY (subscription_id) REFERENCES subscriptions(id),
    CONSTRAINT unique_invoice_per_period UNIQUE (subscription_id, from_date, to_date)
);

CREATE TABLE invoice_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id UUID NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    amount NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_invoice_item_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
);

CREATE TABLE payment_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id UUID NOT NULL,
    payment_method_id UUID NOT NULL,
    status payment_attempt_status_enum NOT NULL DEFAULT 'pending',
    failure_reason TEXT,
    attempted_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_payment_attempt_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(id),
    CONSTRAINT fk_payment_attempt_method FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id)
);

-- indexes
CREATE INDEX idx_subscriptions_customer ON subscriptions (customer_id);
CREATE INDEX idx_invoices_subscription ON invoices (subscription_id);
CREATE INDEX idx_invoices_status ON invoices (status);
CREATE INDEX idx_payment_attempts_invoice ON payment_attempts (invoice_id);
CREATE INDEX idx_payment_methods_customer ON payment_methods (customer_id);
