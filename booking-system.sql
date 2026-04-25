CREATE TYPE booking_status AS ENUM (
    'pending',
    'confirmed',
    'cancelled',
    'completed'
);

CREATE TYPE user_role AS ENUM (
    'host',
    'member'
);

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    name VARHCAR(50) NOT NULL,
    role user_role DEFAULT ('member'),
    email VARCHAR(50) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW() ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE room_types (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    type TEXT NOT NULL,
    base_price_per_night INTEGER NOT NULL CHECK (base_price_per_night > 0),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW() ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE properties (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    name TEXT NOT NULL,
    description TEXT,
    owner_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW() ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_property_user FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT check_user_with_host_role CHECK (users(role) == 'host')
);

CREATE TABLE property_rooms (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    image_url TEXT NOT NULL,
    property_id UUID NOT NULL,
    room_type_id UUID NOT NULL,
    CONSTRAINT fk_property_room_property FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    CONSTRAINT fk_property_room_room_type FOREIGN KEY (room_type_id) REFERENCES room_types(id) ON DELETE CASCADE
);

CREATE TABLE user_bookings (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    status booking_status DEFAULT('pending'),
    total_price INTEGER NOT NULL CHECK (total_price > 0),
    check_in TIMESTAMP NOT NULL,
    check_out TIMESTAMP NOT NULL,
    user_id UUID NOT NULL,
    room_id UUID NOT NULL,
    CONSTRAINT fk_user_booking_room FOREIGN KEY (room_id) REFERENCES property_rooms(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_booking_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT check_in_less_than_check_out CHECK (check_in < check_out),
    EXCLUDE USING gist (
        room_id WITH =,
        daterange(check_in, check_out) WITH &&
    )
);

CREATE TABLE property_reviews (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    title VARHCAR(100) NOT NULL,
    description TEXT NOT NULL,
    stars INTEGER NOT NULL CHECK (stars > 0 AND stars <= 5),
    user_id UUID NOT NULL,
    property_id UUID NOT NULL,
    CONSTRAINT fk_property_review_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_property_review_property FOREIGN KEY (property_id) REFERENCES properties(id)
);

CREATE EXTENSION IF NOT EXISTS btree_gist;

-- i will enforce property review with completed booking on application layer.

CREATE INDEX idx_user_bookings ON user_bookings (user_id);
CREATE INDEX idx_user_properties ON properties (owner_id);
CREATE INDEX idx_property_rooms_room_type ON property_rooms (room_type_id);
CREATE INDEX idx_bookings_with_check_in_time ON user_bookings (check_in);
CREATE INDEX idx_bookings_with_checkout_out_time ON user_bookings (check_out);
CREATE INDEX idx_property_reviews property_reviews ON (property_id);
CREATE INDEX idx_user_property_reviews property_reviews ON (user_id);
