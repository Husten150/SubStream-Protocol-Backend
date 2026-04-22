-- Subscription Cache Schema Migration
-- Creates a highly normalized PostgreSQL schema for lightning-fast API responses
-- Mirrors contract state with off-chain data and maintains data integrity

-- Drop existing tables if they exist (for clean migration)
DROP TABLE IF EXISTS billing_events CASCADE;
DROP TABLE IF EXISTS subscription_events CASCADE;
DROP TABLE IF EXISTS subscription_metrics CASCADE;
DROP TABLE IF EXISTS subscriptions CASCADE;
DROP TABLE IF EXISTS subscription_plans CASCADE;
DROP TABLE IF EXISTS subscription_tiers CASCADE;
DROP TABLE IF EXISTS merchants CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

-- Enable UUID generation extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom types for better data modeling
CREATE TYPE subscription_status AS ENUM (
    'trial',
    'active',
    'paused',
    'cancelled',
    'expired',
    'suspended'
);

CREATE TYPE billing_event_type AS ENUM (
    'subscription_created',
    'subscription_billed',
    'subscription_upgraded',
    'subscription_downgraded',
    'subscription_cancelled',
    'subscription_renewed',
    'trial_started',
    'trial_ended',
    'payment_failed',
    'payment_succeeded',
    'refund_processed',
    'proration_applied'
);

CREATE TYPE plan_type AS ENUM (
    'fixed_monthly',
    'fixed_yearly',
    'usage_based',
    'tiered',
    'custom'
);

CREATE TYPE asset_type AS ENUM (
    'native_xlm',
    'stellar_token',
    'erc20_token',
    'custom'
);

-- Customers table - Stores user profile data
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Stellar identity
    stellar_public_key VARCHAR(56) NOT NULL UNIQUE,
    stellar_address VARCHAR(56),
    
    -- Profile information
    email VARCHAR(255) UNIQUE,
    display_name VARCHAR(100),
    avatar_url TEXT,
    timezone VARCHAR(50) DEFAULT 'UTC',
    language VARCHAR(10) DEFAULT 'en',
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    tags TEXT[] DEFAULT '{}',
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    last_active_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT customers_stellar_public_key_format 
        CHECK (stellar_public_key ~ '^G[A-Z0-9]{55}$'),
    CONSTRAINT customers_email_format 
        CHECK (email IS NULL OR email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Merchants table - Stores off-chain merchant profile data
CREATE TABLE merchants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Identity
    stellar_public_key VARCHAR(56) NOT NULL UNIQUE,
    business_name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    
    -- Profile data
    logo_url TEXT,
    website_url TEXT,
    support_email VARCHAR(255),
    description TEXT,
    business_category VARCHAR(100),
    
    -- API and webhook configuration
    webhook_endpoint TEXT,
    webhook_secret VARCHAR(255),
    api_key_hash VARCHAR(255), -- Hashed API key for security
    api_permissions JSONB DEFAULT '[]',
    
    -- Configuration
    default_currency VARCHAR(3) DEFAULT 'USD',
    timezone VARCHAR(50) DEFAULT 'UTC',
    billing_timezone VARCHAR(50) DEFAULT 'UTC',
    
    -- Status and verification
    is_verified BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    verification_status VARCHAR(20) DEFAULT 'pending',
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    settings JSONB DEFAULT '{}',
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    last_sync_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    CONSTRAINT merchants_stellar_public_key_format 
        CHECK (stellar_public_key ~ '^G[A-Z0-9]{55}$'),
    CONSTRAINT merchants_slug_format 
        CHECK (slug ~ '^[a-z0-9-]+$'),
    CONSTRAINT merchants_webhook_endpoint_format 
        CHECK (webhook_endpoint IS NULL OR webhook_endpoint ~ '^https?://.+')
);

-- Subscription Tiers table - Defines tier levels and their properties
CREATE TABLE subscription_tiers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Basic tier information
    merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL,
    description TEXT,
    
    -- Tier hierarchy and ordering
    level INTEGER NOT NULL,
    is_default BOOLEAN DEFAULT false,
    is_visible BOOLEAN DEFAULT true,
    
    -- Limits and quotas
    max_users INTEGER,
    max_storage_gb INTEGER,
    max_api_calls_per_month INTEGER,
    max_bandwidth_gb INTEGER,
    custom_limits JSONB DEFAULT '{}',
    
    -- Features and capabilities
    features JSONB DEFAULT '[]',
    permissions JSONB DEFAULT '[]',
    
    -- Display and marketing
    display_order INTEGER DEFAULT 0,
    badge_text VARCHAR(50),
    badge_color VARCHAR(7) DEFAULT '#007bff',
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT subscription_tiers_unique_merchant_slug 
        UNIQUE (merchant_id, slug),
    CONSTRAINT subscription_tiers_level_positive 
        CHECK (level > 0),
    CONSTRAINT subscription_tiers_badge_color_format 
        CHECK (badge_color ~ '^#[0-9A-Fa-f]{6}$')
);

-- Subscription Plans table - Stores pricing and billing information
CREATE TABLE subscription_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Basic plan information
    merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    tier_id UUID NOT NULL REFERENCES subscription_tiers(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    
    -- Pricing details
    plan_type plan_type NOT NULL DEFAULT 'fixed_monthly',
    base_price NUMERIC(20, 8) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    billing_interval_months INTEGER NOT NULL DEFAULT 1,
    
    -- Asset configuration for crypto payments
    accepted_assets JSONB DEFAULT '[]',
    default_asset VARCHAR(20) DEFAULT 'USDC',
    asset_type asset_type DEFAULT 'stellar_token',
    
    -- Trial configuration
    trial_days INTEGER DEFAULT 0,
    trial_price NUMERIC(20, 8) DEFAULT 0,
    
    -- Usage-based pricing (if applicable)
    usage_unit VARCHAR(50),
    usage_price_per_unit NUMERIC(20, 8),
    included_usage_units INTEGER DEFAULT 0,
    
    -- Upgrade/downgrade rules
    can_upgrade_to UUID[] DEFAULT '{}',
    can_downgrade_to UUID[] DEFAULT '{}',
    proration_policy VARCHAR(20) DEFAULT 'immediate',
    
    -- Discounts and promotions
    discount_percentage NUMERIC(5, 2) DEFAULT 0,
    max_discount_months INTEGER,
    promotional_periods JSONB DEFAULT '[]',
    
    -- Display and marketing
    display_order INTEGER DEFAULT 0,
    is_popular BOOLEAN DEFAULT false,
    is_featured BOOLEAN DEFAULT false,
    
    -- Status and availability
    is_active BOOLEAN DEFAULT true,
    available_from TIMESTAMP WITH TIME ZONE,
    available_until TIMESTAMP WITH TIME ZONE,
    max_subscribers INTEGER,
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT subscription_plans_unique_merchant_name 
        UNIQUE (merchant_id, name),
    CONSTRAINT subscription_plans_base_price_positive 
        CHECK (base_price >= 0),
    CONSTRAINT subscription_plans_billing_interval_positive 
        CHECK (billing_interval_months > 0),
    CONSTRAINT subscription_plans_trial_days_non_negative 
        CHECK (trial_days >= 0),
    CONSTRAINT subscription_plans_discount_percentage_valid 
        CHECK (discount_percentage >= 0 AND discount_percentage <= 100)
);

-- Subscriptions table - Tracks user subscriptions and their status
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Subscription identity
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES subscription_plans(id) ON DELETE CASCADE,
    tier_id UUID NOT NULL REFERENCES subscription_tiers(id) ON DELETE CASCADE,
    
    -- Subscription details
    subscription_number VARCHAR(20) UNIQUE NOT NULL, -- Human-readable ID
    status subscription_status NOT NULL DEFAULT 'trial',
    
    -- Timing information
    started_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    trial_ends_at TIMESTAMP WITH TIME ZONE,
    current_period_starts_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    current_period_ends_at TIMESTAMP WITH TIME ZONE NOT NULL,
    next_billing_at TIMESTAMP WITH TIME ZONE NOT NULL,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    
    -- Pricing and billing
    current_price NUMERIC(20, 8) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    billing_asset VARCHAR(20),
    last_paid_amount NUMERIC(20, 8),
    last_paid_at TIMESTAMP WITH TIME ZONE,
    
    -- Usage tracking (for usage-based plans)
    current_usage_units INTEGER DEFAULT 0,
    usage_reset_at TIMESTAMP WITH TIME ZONE,
    overage_charges NUMERIC(20, 8) DEFAULT 0,
    
    -- Trial information
    trial_used BOOLEAN DEFAULT false,
    trial_converted BOOLEAN DEFAULT false,
    
    -- Cancellation and renewal
    cancel_reason TEXT,
    cancel_reason_category VARCHAR(50),
    auto_renew BOOLEAN DEFAULT true,
    renewal_attempts INTEGER DEFAULT 0,
    
    -- Metadata and configuration
    metadata JSONB DEFAULT '{}',
    custom_attributes JSONB DEFAULT '{}',
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    last_status_change_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT subscriptions_unique_active_subscription 
        UNIQUE (customer_id, merchant_id, plan_id) 
        DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT subscriptions_subscription_number_format 
        CHECK (subscription_number ~ '^SUB-[0-9]{8}-[A-Z0-9]{6}$'),
    CONSTRAINT subscriptions_current_price_positive 
        CHECK (current_price >= 0),
    CONSTRAINT subscriptions_status_transition_valid 
        CHECK (
            (status = 'trial' AND trial_ends_at IS NOT NULL) OR
            (status = 'active' AND current_period_ends_at > NOW()) OR
            (status = 'cancelled' AND cancelled_at IS NOT NULL) OR
            (status = 'expired' AND expires_at IS NOT NULL) OR
            (status = 'paused') OR
            (status = 'suspended')
        )
);

-- Subscription Events table - Tracks all subscription lifecycle events
CREATE TABLE subscription_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Event identity
    subscription_id UUID NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
    event_type billing_event_type NOT NULL,
    
    -- Event data
    previous_status subscription_status,
    new_status subscription_status,
    previous_plan_id UUID REFERENCES subscription_plans(id),
    new_plan_id UUID REFERENCES subscription_plans(id),
    
    -- Financial data
    amount NUMERIC(20, 8),
    currency VARCHAR(3),
    asset VARCHAR(20),
    usd_equivalent NUMERIC(20, 8),
    
    -- Blockchain references
    transaction_hash VARCHAR(64),
    ledger_sequence BIGINT,
    event_index INTEGER,
    contract_id VARCHAR(64),
    
    -- Event details
    description TEXT,
    reason TEXT,
    metadata JSONB DEFAULT '{}',
    
    -- Timestamps
    event_timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT subscription_events_transaction_hash_format 
        CHECK (transaction_hash IS NULL OR transaction_hash ~ '^[a-f0-9]{64}$')
);

-- Billing Events table - Immutable ledger for all billing transactions
CREATE TABLE billing_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Event identity
    subscription_id UUID NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
    merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES subscription_plans(id) ON DELETE CASCADE,
    
    -- Event classification
    event_type billing_event_type NOT NULL,
    category VARCHAR(50) NOT NULL, -- 'recurring', 'setup', 'upgrade', 'downgrade', 'refund', etc.
    
    -- Financial details
    amount NUMERIC(20, 8) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    asset VARCHAR(20),
    usd_equivalent NUMERIC(20, 8),
    price_per_unit NUMERIC(20, 8),
    
    -- Billing period
    billing_period_start TIMESTAMP WITH TIME ZONE NOT NULL,
    billing_period_end TIMESTAMP WITH TIME ZONE NOT NULL,
    proration_factor NUMERIC(5, 4) DEFAULT 1.0000,
    
    -- Blockchain references
    transaction_hash VARCHAR(64) NOT NULL,
    ledger_sequence BIGINT NOT NULL,
    event_index INTEGER NOT NULL,
    contract_id VARCHAR(64) NOT NULL,
    
    -- Payment processing
    payment_status VARCHAR(20) NOT NULL DEFAULT 'pending',
    payment_method VARCHAR(20),
    payment_processor VARCHAR(50),
    failure_reason TEXT,
    
    -- Refund information (if applicable)
    refund_amount NUMERIC(20, 8),
    refund_reason TEXT,
    refund_transaction_hash VARCHAR(64),
    
    -- Discounts and adjustments
    discount_amount NUMERIC(20, 8) DEFAULT 0,
    discount_type VARCHAR(20), -- 'percentage', 'fixed', 'promotional'
    discount_code VARCHAR(50),
    
    -- Metadata and context
    metadata JSONB DEFAULT '{}',
    raw_event_data JSONB,
    
    -- Timestamps
    event_timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    ingested_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    CONSTRAINT billing_events_transaction_hash_unique 
        UNIQUE (transaction_hash, event_index),
    CONSTRAINT billing_events_amount_positive 
        CHECK (amount > 0),
    CONSTRAINT billing_events_usd_equivalent_positive 
        CHECK (usd_equivalent IS NULL OR usd_equivalent >= 0),
    CONSTRAINT billing_events_proration_factor_valid 
        CHECK (proration_factor >= 0 AND proration_factor <= 1),
    CONSTRAINT billing_events_transaction_hash_format 
        CHECK (transaction_hash ~ '^[a-f0-9]{64}$')
);

-- Subscription Metrics table - Aggregated metrics for analytics
CREATE TABLE subscription_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Metric identity
    merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    plan_id UUID REFERENCES subscription_plans(id) ON DELETE CASCADE,
    tier_id UUID REFERENCES subscription_tiers(id) ON DELETE CASCADE,
    
    -- Time period
    metric_date DATE NOT NULL,
    metric_period VARCHAR(10) NOT NULL, -- 'daily', 'weekly', 'monthly'
    
    -- Subscription counts
    new_subscriptions INTEGER DEFAULT 0,
    active_subscriptions INTEGER DEFAULT 0,
    cancelled_subscriptions INTEGER DEFAULT 0,
    churned_subscriptions INTEGER DEFAULT 0,
    trial_conversions INTEGER DEFAULT 0,
    
    -- Financial metrics
    total_revenue NUMERIC(20, 8) DEFAULT 0,
    total_refunds NUMERIC(20, 8) DEFAULT 0,
    net_revenue NUMERIC(20, 8) DEFAULT 0,
    average_revenue_per_subscription NUMERIC(20, 8) DEFAULT 0,
    
    -- Usage metrics
    total_usage_units INTEGER DEFAULT 0,
    average_usage_per_subscription NUMERIC(20, 8) DEFAULT 0,
    
    -- Calculated metrics
    monthly_recurring_revenue NUMERIC(20, 8) DEFAULT 0,
    annual_recurring_revenue NUMERIC(20, 8) DEFAULT 0,
    customer_lifetime_value NUMERIC(20, 8) DEFAULT 0,
    churn_rate NUMERIC(5, 4) DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT subscription_metrics_unique_period 
        UNIQUE (merchant_id, plan_id, metric_date, metric_period),
    CONSTRAINT subscription_metrics_period_valid 
        CHECK (metric_period IN ('daily', 'weekly', 'monthly')),
    CONSTRAINT subscription_metrics_revenue_non_negative 
        CHECK (
            total_revenue >= 0 AND 
            total_refunds >= 0 AND 
            net_revenue >= 0 AND
            monthly_recurring_revenue >= 0 AND
            annual_recurring_revenue >= 0
        ),
    CONSTRAINT subscription_metrics_churn_rate_valid 
        CHECK (churn_rate >= 0 AND churn_rate <= 1)
);

-- Create indexes for sub-50ms query performance

-- Customers indexes
CREATE INDEX idx_customers_stellar_public_key ON customers(stellar_public_key);
CREATE INDEX idx_customers_email ON customers(email) WHERE email IS NOT NULL;
CREATE INDEX idx_customers_created_at ON customers(created_at);
CREATE INDEX idx_customers_last_active_at ON customers(last_active_at) WHERE last_active_at IS NOT NULL;

-- Merchants indexes
CREATE INDEX idx_merchants_stellar_public_key ON merchants(stellar_public_key);
CREATE INDEX idx_merchants_slug ON merchants(slug);
CREATE INDEX idx_merchants_is_active ON merchants(is_active) WHERE is_active = true;
CREATE INDEX idx_merchants_is_verified ON merchants(is_verified) WHERE is_verified = true;
CREATE INDEX idx_merchants_created_at ON merchants(created_at);
CREATE INDEX idx_merchants_business_category ON merchants(business_category) WHERE business_category IS NOT NULL;

-- Composite index for merchant dashboard queries
CREATE INDEX idx_merchants_status_category ON merchants(is_active, is_verified, business_category);

-- Subscription Tiers indexes
CREATE INDEX idx_subscription_tiers_merchant_id ON subscription_tiers(merchant_id);
CREATE INDEX idx_subscription_tiers_merchant_active ON subscription_tiers(merchant_id, is_active) WHERE is_active = true;
CREATE INDEX idx_subscription_tiers_level ON subscription_tiers(merchant_id, level);
CREATE INDEX idx_subscription_tiers_display_order ON subscription_tiers(merchant_id, display_order);

-- Subscription Plans indexes
CREATE INDEX idx_subscription_plans_merchant_id ON subscription_plans(merchant_id);
CREATE INDEX idx_subscription_plans_tier_id ON subscription_plans(tier_id);
CREATE INDEX idx_subscription_plans_merchant_active ON subscription_plans(merchant_id, is_active) WHERE is_active = true;
CREATE INDEX idx_subscription_plans_plan_type ON subscription_plans(plan_type);
CREATE INDEX idx_subscription_plans_price_range ON subscription_plans(base_price) WHERE base_price > 0;
CREATE INDEX idx_subscription_plans_billing_interval ON subscription_plans(billing_interval_months);
CREATE INDEX idx_subscription_plans_display_order ON subscription_plans(merchant_id, display_order);

-- Composite index for plan lookup queries
CREATE INDEX idx_subscription_plans_merchant_type_active ON subscription_plans(merchant_id, plan_type, is_active) WHERE is_active = true;

-- Subscriptions indexes (critical for performance)
CREATE INDEX idx_subscriptions_customer_id ON subscriptions(customer_id);
CREATE INDEX idx_subscriptions_merchant_id ON subscriptions(merchant_id);
CREATE INDEX idx_subscriptions_plan_id ON subscriptions(plan_id);
CREATE INDEX idx_subscriptions_tier_id ON subscriptions(tier_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_subscriptions_next_billing ON subscriptions(next_billing_at) WHERE next_billing_at IS NOT NULL;
CREATE INDEX idx_subscriptions_current_period ON subscriptions(current_period_ends_at);
CREATE INDEX idx_subscriptions_trial_ends ON subscriptions(trial_ends_at) WHERE trial_ends_at IS NOT NULL;
CREATE INDEX idx_subscriptions_cancelled ON subscriptions(cancelled_at) WHERE cancelled_at IS NOT NULL;
CREATE INDEX idx_subscriptions_auto_renew ON subscriptions(auto_renew) WHERE auto_renew = true;

-- Composite indexes for common API queries
CREATE INDEX idx_subscriptions_customer_status ON subscriptions(customer_id, status);
CREATE INDEX idx_subscriptions_merchant_status ON subscriptions(merchant_id, status);
CREATE INDEX idx_subscriptions_plan_status ON subscriptions(plan_id, status);
CREATE INDEX idx_subscriptions_merchant_plan_status ON subscriptions(merchant_id, plan_id, status);
CREATE INDEX idx_subscriptions_next_billing_status ON subscriptions(next_billing_at, status) WHERE next_billing_at IS NOT NULL;

-- Subscription Events indexes
CREATE INDEX idx_subscription_events_subscription_id ON subscription_events(subscription_id);
CREATE INDEX idx_subscription_events_type ON subscription_events(event_type);
CREATE INDEX idx_subscription_events_timestamp ON subscription_events(event_timestamp);
CREATE INDEX idx_subscription_events_subscription_type ON subscription_events(subscription_id, event_type);
CREATE INDEX idx_subscription_events_transaction_hash ON subscription_events(transaction_hash) WHERE transaction_hash IS NOT NULL;

-- Billing Events indexes (critical for financial reporting)
CREATE INDEX idx_billing_events_subscription_id ON billing_events(subscription_id);
CREATE INDEX idx_billing_events_merchant_id ON billing_events(merchant_id);
CREATE INDEX idx_billing_events_customer_id ON billing_events(customer_id);
CREATE INDEX idx_billing_events_plan_id ON billing_events(plan_id);
CREATE INDEX idx_billing_events_type ON billing_events(event_type);
CREATE INDEX idx_billing_events_category ON billing_events(category);
CREATE INDEX idx_billing_events_transaction_hash ON billing_events(transaction_hash);
CREATE INDEX idx_billing_events_ledger_sequence ON billing_events(ledger_sequence);
CREATE INDEX idx_billing_events_event_timestamp ON billing_events(event_timestamp);
CREATE INDEX idx_billing_events_billing_period ON billing_events(billing_period_start, billing_period_end);
CREATE INDEX idx_billing_events_payment_status ON billing_events(payment_status);
CREATE INDEX idx_billing_events_amount ON billing_events(amount) WHERE amount > 0;
CREATE INDEX idx_billing_events_usd_equivalent ON billing_events(usd_equivalent) WHERE usd_equivalent IS NOT NULL;

-- Composite indexes for financial reporting
CREATE INDEX idx_billing_events_merchant_type ON billing_events(merchant_id, event_type);
CREATE INDEX idx_billing_events_merchant_period ON billing_events(merchant_id, billing_period_start);
CREATE INDEX idx_billing_events_customer_period ON billing_events(customer_id, billing_period_start);
CREATE INDEX idx_billing_events_plan_period ON billing_events(plan_id, billing_period_start);
CREATE INDEX idx_billing_events_merchant_status ON billing_events(merchant_id, payment_status);

-- Subscription Metrics indexes
CREATE INDEX idx_subscription_metrics_merchant_id ON subscription_metrics(merchant_id);
CREATE INDEX idx_subscription_metrics_plan_id ON subscription_metrics(plan_id);
CREATE INDEX idx_subscription_metrics_tier_id ON subscription_metrics(tier_id);
CREATE INDEX idx_subscription_metrics_date_period ON subscription_metrics(metric_date, metric_period);
CREATE INDEX idx_subscription_metrics_merchant_date ON subscription_metrics(merchant_id, metric_date);
CREATE INDEX idx_subscription_metrics_mrr ON subscription_metrics(monthly_recurring_revenue) WHERE monthly_recurring_revenue > 0;

-- Composite index for analytics dashboard
CREATE INDEX idx_subscription_metrics_merchant_period_date ON subscription_metrics(merchant_id, metric_period, metric_date);

-- Create triggers for automatic timestamp updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers to all relevant tables
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_merchants_updated_at BEFORE UPDATE ON merchants
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscription_tiers_updated_at BEFORE UPDATE ON subscription_tiers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscription_plans_updated_at BEFORE UPDATE ON subscription_plans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscription_metrics_updated_at BEFORE UPDATE ON subscription_metrics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create business rule constraints and triggers

-- Prevent duplicate active subscriptions for same customer/merchant/plan
CREATE OR REPLACE FUNCTION prevent_duplicate_active_subscriptions()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if there's already an active subscription for this customer, merchant, and plan
    IF EXISTS (
        SELECT 1 FROM subscriptions 
        WHERE customer_id = NEW.customer_id 
          AND merchant_id = NEW.merchant_id 
          AND plan_id = NEW.plan_id 
          AND status IN ('trial', 'active', 'paused')
          AND id != COALESCE(NEW.id, uuid_generate_v4())
    ) THEN
        RAISE EXCEPTION 'Customer already has an active subscription to this plan';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER prevent_duplicate_active_subscriptions_trigger
    BEFORE INSERT OR UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION prevent_duplicate_active_subscriptions();

-- Generate subscription numbers automatically
CREATE OR REPLACE FUNCTION generate_subscription_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.subscription_number IS NULL OR NEW.subscription_number = '' THEN
        NEW.subscription_number := 'SUB-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || UPPER(SUBSTR(MD5(RANDOM()::TEXT), 1, 6));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_subscription_number_trigger
    BEFORE INSERT ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION generate_subscription_number();

-- Update last_active_at for customers when they interact
CREATE OR REPLACE FUNCTION update_customer_last_active()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE customers 
    SET last_active_at = NOW() 
    WHERE id = NEW.customer_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_customer_last_active_trigger
    AFTER INSERT OR UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_customer_last_active();

-- Create views for common queries

-- Active subscriptions view
CREATE OR REPLACE VIEW active_subscriptions AS
SELECT 
    s.*,
    c.stellar_public_key as customer_stellar_public_key,
    c.email as customer_email,
    c.display_name as customer_display_name,
    m.business_name as merchant_name,
    m.slug as merchant_slug,
    p.name as plan_name,
    p.base_price as plan_base_price,
    p.currency as plan_currency,
    t.name as tier_name,
    t.level as tier_level,
    CASE 
        WHEN s.status = 'trial' THEN s.trial_ends_at
        ELSE s.current_period_ends_at
    END as effective_end_date
FROM subscriptions s
JOIN customers c ON s.customer_id = c.id
JOIN merchants m ON s.merchant_id = m.id
JOIN subscription_plans p ON s.plan_id = p.id
JOIN subscription_tiers t ON s.tier_id = t.id
WHERE s.status IN ('trial', 'active', 'paused')
  AND m.is_active = true
  AND p.is_active = true;

-- Merchant dashboard summary view
CREATE OR REPLACE VIEW merchant_dashboard_summary AS
SELECT 
    m.id as merchant_id,
    m.business_name,
    m.slug,
    COUNT(DISTINCT s.id) as total_subscriptions,
    COUNT(DISTINCT CASE WHEN s.status = 'active' THEN s.id END) as active_subscriptions,
    COUNT(DISTINCT CASE WHEN s.status = 'trial' THEN s.id END) as trial_subscriptions,
    COUNT(DISTINCT CASE WHEN s.status = 'cancelled' THEN s.id END) as cancelled_subscriptions,
    COALESCE(SUM(CASE WHEN s.status = 'active' THEN s.current_price ELSE 0 END), 0) as monthly_recurring_revenue,
    COALESCE(SUM(CASE WHEN be.event_type = 'subscription_billed' AND be.payment_status = 'succeeded' 
        AND be.event_timestamp >= DATE_TRUNC('month', CURRENT_DATE) THEN be.usd_equivalent ELSE 0 END), 0) as monthly_revenue,
    COUNT(DISTINCT c.id) as total_customers,
    COUNT(DISTINCT CASE WHEN s.status = 'active' THEN c.id END) as active_customers
FROM merchants m
LEFT JOIN subscriptions s ON m.id = s.merchant_id
LEFT JOIN billing_events be ON m.id = be.merchant_id
LEFT JOIN customers c ON s.customer_id = c.id
WHERE m.is_active = true
GROUP BY m.id, m.business_name, m.slug;

-- Customer subscription history view
CREATE OR REPLACE VIEW customer_subscription_history AS
SELECT 
    c.id as customer_id,
    c.stellar_public_key,
    c.email,
    c.display_name,
    s.id as subscription_id,
    s.subscription_number,
    s.status,
    m.business_name as merchant_name,
    m.slug as merchant_slug,
    p.name as plan_name,
    t.name as tier_name,
    s.current_price,
    s.currency,
    s.started_at,
    s.current_period_ends_at,
    s.next_billing_at,
    s.cancelled_at,
    CASE 
        WHEN s.status = 'cancelled' THEN s.cancelled_at
        WHEN s.status = 'expired' THEN s.expires_at
        ELSE NULL
    END as ended_at,
    ROW_NUMBER() OVER (PARTITION BY c.id ORDER BY s.started_at DESC) as subscription_rank
FROM customers c
JOIN subscriptions s ON c.id = s.customer_id
JOIN merchants m ON s.merchant_id = m.id
JOIN subscription_plans p ON s.plan_id = p.id
JOIN subscription_tiers t ON s.tier_id = t.id;

-- Grant necessary permissions (adjust as needed)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON all tables IN SCHEMA public TO app_user;
-- GRANT SELECT ON all views IN SCHEMA public TO readonly_user;
-- GRANT EXECUTE ON all functions IN SCHEMA public TO app_user;

-- Update table statistics for optimal query planning
ANALYZE customers;
ANALYZE merchants;
ANALYZE subscription_tiers;
ANALYZE subscription_plans;
ANALYZE subscriptions;
ANALYZE subscription_events;
ANALYZE billing_events;
ANALYZE subscription_metrics;
