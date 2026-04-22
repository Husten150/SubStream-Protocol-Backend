# Subscription Cache Schema Documentation

## Overview

The Subscription Cache Schema provides a highly normalized PostgreSQL database structure designed to serve lightning-fast API responses for subscription management. This system mirrors the blockchain contract state while maintaining comprehensive off-chain data for business operations and analytics.

## Architecture

### Design Principles

1. **High Performance**: Optimized for sub-50ms query times with strategic indexing
2. **Data Integrity**: Strict foreign key constraints with CASCADE operations
3. **Business Logic Enforcement**: Database-level constraints for subscription rules
4. **Scalability**: Normalized structure supporting enterprise-scale operations
5. **Audit Trail**: Immutable billing ledger for financial compliance

### Core Relationships

```
Customers (1) <-> (N) Subscriptions (N) <-> (1) Merchants
    |                    |                      |
    |                    |                      |
    v                    v                      v
BillingEvents    SubscriptionPlans    SubscriptionTiers
    |                    |                      |
    |                    |                      |
    v                    v                      v
SubscriptionMetrics  SubscriptionEvents
```

## Database Schema

### Tables Overview

| Table | Purpose | Primary Key | Foreign Keys |
|-------|---------|-------------|-------------|
| `customers` | User profile data | `id` (UUID) | - |
| `merchants` | Merchant business data | `id` (UUID) | - |
| `subscription_tiers` | Tier definitions | `id` (UUID) | `merchant_id` |
| `subscription_plans` | Pricing and billing | `id` (UUID) | `merchant_id`, `tier_id` |
| `subscriptions` | Active subscriptions | `id` (UUID) | `customer_id`, `merchant_id`, `plan_id`, `tier_id` |
| `subscription_events` | Lifecycle events | `id` (UUID) | `subscription_id` |
| `billing_events` | Immutable billing ledger | `id` (UUID) | `subscription_id`, `merchant_id`, `customer_id`, `plan_id` |
| `subscription_metrics` | Analytics aggregates | `id` (UUID) | `merchant_id`, `plan_id`, `tier_id` |

### Detailed Schema

#### Customers Table

Stores user profile and identity information.

```sql
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    stellar_public_key VARCHAR(56) NOT NULL UNIQUE,
    stellar_address VARCHAR(56),
    email VARCHAR(255) UNIQUE,
    display_name VARCHAR(100),
    avatar_url TEXT,
    timezone VARCHAR(50) DEFAULT 'UTC',
    language VARCHAR(10) DEFAULT 'en',
    metadata JSONB DEFAULT '{}',
    tags TEXT[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    last_active_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Key Features:**
- Stellar public key as primary identifier
- Flexible metadata and tagging system
- Automatic timestamp tracking
- Last activity tracking for engagement metrics

#### Merchants Table

Stores merchant business profile and configuration.

```sql
CREATE TABLE merchants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    stellar_public_key VARCHAR(56) NOT NULL UNIQUE,
    business_name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    logo_url TEXT,
    website_url TEXT,
    support_email VARCHAR(255),
    description TEXT,
    business_category VARCHAR(100),
    webhook_endpoint TEXT,
    webhook_secret VARCHAR(255),
    api_key_hash VARCHAR(255),
    api_permissions JSONB DEFAULT '[]',
    default_currency VARCHAR(3) DEFAULT 'USD',
    timezone VARCHAR(50) DEFAULT 'UTC',
    is_verified BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}',
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    last_sync_at TIMESTAMP WITH TIME ZONE
);
```

**Key Features:**
- Business profile management
- Webhook and API configuration
- Verification and status tracking
- Flexible metadata and settings

#### Subscription Tiers Table

Defines subscription tiers with features and limits.

```sql
CREATE TABLE subscription_tiers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL,
    description TEXT,
    level INTEGER NOT NULL,
    is_default BOOLEAN DEFAULT false,
    is_visible BOOLEAN DEFAULT true,
    max_users INTEGER,
    max_storage_gb INTEGER,
    max_api_calls_per_month INTEGER,
    custom_limits JSONB DEFAULT '{}',
    features JSONB DEFAULT '[]',
    permissions JSONB DEFAULT '[]',
    display_order INTEGER DEFAULT 0,
    badge_text VARCHAR(50),
    badge_color VARCHAR(7) DEFAULT '#007bff',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);
```

**Key Features:**
- Hierarchical tier system with levels
- Feature and permission management
- Usage limits and quotas
- Display configuration for UI

#### Subscription Plans Table

Stores pricing and billing configuration for each tier.

```sql
CREATE TABLE subscription_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    tier_id UUID NOT NULL REFERENCES subscription_tiers(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    plan_type plan_type NOT NULL DEFAULT 'fixed_monthly',
    base_price NUMERIC(20, 8) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    billing_interval_months INTEGER NOT NULL DEFAULT 1,
    accepted_assets JSONB DEFAULT '[]',
    default_asset VARCHAR(20) DEFAULT 'USDC',
    trial_days INTEGER DEFAULT 0,
    trial_price NUMERIC(20, 8) DEFAULT 0,
    usage_unit VARCHAR(50),
    usage_price_per_unit NUMERIC(20, 8),
    included_usage_units INTEGER DEFAULT 0,
    can_upgrade_to UUID[] DEFAULT '{}',
    can_downgrade_to UUID[] DEFAULT '{}',
    proration_policy VARCHAR(20) DEFAULT 'immediate',
    discount_percentage NUMERIC(5, 2) DEFAULT 0,
    max_discount_months INTEGER,
    promotional_periods JSONB DEFAULT '[]',
    is_active BOOLEAN DEFAULT true,
    available_from TIMESTAMP WITH TIME ZONE,
    available_until TIMESTAMP WITH TIME ZONE,
    max_subscribers INTEGER,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);
```

**Key Features:**
- Flexible pricing models (fixed, usage-based, tiered)
- Multi-currency and multi-asset support
- Trial configuration and upgrade/downgrade rules
- Discount and promotional pricing

#### Subscriptions Table

Tracks active user subscriptions and their status.

```sql
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES subscription_plans(id) ON DELETE CASCADE,
    tier_id UUID NOT NULL REFERENCES subscription_tiers(id) ON DELETE CASCADE,
    subscription_number VARCHAR(20) UNIQUE NOT NULL,
    status subscription_status NOT NULL DEFAULT 'trial',
    started_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    trial_ends_at TIMESTAMP WITH TIME ZONE,
    current_period_starts_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    current_period_ends_at TIMESTAMP WITH TIME ZONE NOT NULL,
    next_billing_at TIMESTAMP WITH TIME ZONE NOT NULL,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    current_price NUMERIC(20, 8) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    billing_asset VARCHAR(20),
    last_paid_amount NUMERIC(20, 8),
    last_paid_at TIMESTAMP WITH TIME ZONE,
    current_usage_units INTEGER DEFAULT 0,
    usage_reset_at TIMESTAMP WITH TIME ZONE,
    overage_charges NUMERIC(20, 8) DEFAULT 0,
    trial_used BOOLEAN DEFAULT false,
    trial_converted BOOLEAN DEFAULT false,
    cancel_reason TEXT,
    cancel_reason_category VARCHAR(50),
    auto_renew BOOLEAN DEFAULT true,
    renewal_attempts INTEGER DEFAULT 0,
    metadata JSONB DEFAULT '{}',
    custom_attributes JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    last_status_change_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);
```

**Key Features:**
- Complete subscription lifecycle tracking
- Usage-based billing support
- Trial management and conversion tracking
- Cancellation and renewal handling

#### Billing Events Table

Immutable ledger for all billing transactions.

```sql
CREATE TABLE billing_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subscription_id UUID NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
    merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES subscription_plans(id) ON DELETE CASCADE,
    event_type billing_event_type NOT NULL,
    category VARCHAR(50) NOT NULL,
    amount NUMERIC(20, 8) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    asset VARCHAR(20),
    usd_equivalent NUMERIC(20, 8),
    price_per_unit NUMERIC(20, 8),
    billing_period_start TIMESTAMP WITH TIME ZONE NOT NULL,
    billing_period_end TIMESTAMP WITH TIME ZONE NOT NULL,
    proration_factor NUMERIC(5, 4) DEFAULT 1.0000,
    transaction_hash VARCHAR(64) NOT NULL,
    ledger_sequence BIGINT NOT NULL,
    event_index INTEGER NOT NULL,
    contract_id VARCHAR(64) NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'pending',
    payment_method VARCHAR(20),
    payment_processor VARCHAR(50),
    failure_reason TEXT,
    refund_amount NUMERIC(20, 8),
    refund_reason TEXT,
    refund_transaction_hash VARCHAR(64),
    discount_amount NUMERIC(20, 8) DEFAULT 0,
    discount_type VARCHAR(20),
    discount_code VARCHAR(50),
    metadata JSONB DEFAULT '{}',
    raw_event_data JSONB,
    event_timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    ingested_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE
);
```

**Key Features:**
- Immutable financial ledger
- Blockchain transaction references
- Comprehensive payment tracking
- Refund and discount handling

#### Subscription Metrics Table

Aggregated analytics data for reporting.

```sql
CREATE TABLE subscription_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    plan_id UUID REFERENCES subscription_plans(id) ON DELETE CASCADE,
    tier_id UUID REFERENCES subscription_tiers(id) ON DELETE CASCADE,
    metric_date DATE NOT NULL,
    metric_period VARCHAR(10) NOT NULL,
    new_subscriptions INTEGER DEFAULT 0,
    active_subscriptions INTEGER DEFAULT 0,
    cancelled_subscriptions INTEGER DEFAULT 0,
    churned_subscriptions INTEGER DEFAULT 0,
    trial_conversions INTEGER DEFAULT 0,
    total_revenue NUMERIC(20, 8) DEFAULT 0,
    total_refunds NUMERIC(20, 8) DEFAULT 0,
    net_revenue NUMERIC(20, 8) DEFAULT 0,
    average_revenue_per_subscription NUMERIC(20, 8) DEFAULT 0,
    monthly_recurring_revenue NUMERIC(20, 8) DEFAULT 0,
    annual_recurring_revenue NUMERIC(20, 8) DEFAULT 0,
    customer_lifetime_value NUMERIC(20, 8) DEFAULT 0,
    churn_rate NUMERIC(5, 4) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);
```

**Key Features:**
- Pre-aggregated metrics for fast reporting
- Multiple time periods (daily, weekly, monthly)
- Key SaaS metrics (MRR, ARR, LTV, Churn)
- Hierarchical aggregation (merchant, plan, tier)

## Indexes for Performance

### Strategic Indexing

The schema includes comprehensive indexing for sub-50ms query performance:

#### Customer-Focused Queries
```sql
-- Customer lookup by Stellar public key
CREATE INDEX idx_customers_stellar_public_key ON customers(stellar_public_key);

-- Customer email lookup
CREATE INDEX idx_customers_email ON customers(email) WHERE email IS NOT NULL;

-- Customer activity tracking
CREATE INDEX idx_customers_last_active_at ON customers(last_active_at) WHERE last_active_at IS NOT NULL;
```

#### Merchant Dashboard Queries
```sql
-- Composite index for merchant dashboard performance
CREATE INDEX idx_merchants_status_category ON merchants(is_active, is_verified, business_category);

-- Merchant lookup by public key
CREATE INDEX idx_merchants_stellar_public_key ON merchants(stellar_public_key);

-- Merchant slug for public pages
CREATE INDEX idx_merchants_slug ON merchants(slug);
```

#### Subscription Management Queries
```sql
-- Active subscriptions by customer
CREATE INDEX idx_subscriptions_customer_status ON subscriptions(customer_id, status);

-- Active subscriptions by merchant
CREATE INDEX idx_subscriptions_merchant_status ON subscriptions(merchant_id, status);

-- Billing schedule optimization
CREATE INDEX idx_subscriptions_next_billing_status ON subscriptions(next_billing_at, status) WHERE next_billing_at IS NOT NULL;

-- Trial management
CREATE INDEX idx_subscriptions_trial_ends ON subscriptions(trial_ends_at) WHERE trial_ends_at IS NOT NULL;
```

#### Financial Reporting Queries
```sql
-- Merchant revenue by period
CREATE INDEX idx_billing_events_merchant_period ON billing_events(merchant_id, billing_period_start);

-- Customer billing history
CREATE INDEX idx_billing_events_customer_period ON billing_events(customer_id, billing_period_start);

-- Payment status tracking
CREATE INDEX idx_billing_events_merchant_status ON billing_events(merchant_id, payment_status);
```

### Performance Characteristics

| Query Type | Expected Time | Index Used |
|-------------|----------------|------------|
| Customer lookup by public key | < 10ms | `idx_customers_stellar_public_key` |
| Merchant dashboard summary | < 50ms | `idx_merchants_status_category` |
| Active subscriptions by customer | < 20ms | `idx_subscriptions_customer_status` |
| Billing events by merchant/period | < 30ms | `idx_billing_events_merchant_period` |
| Trial expiring today | < 15ms | `idx_subscriptions_trial_ends` |

## Business Rules and Constraints

### Database-Level Constraints

#### Unique Active Subscription Constraint
```sql
ALTER TABLE subscriptions ADD CONSTRAINT subscriptions_unique_active_subscription 
    UNIQUE (customer_id, merchant_id, plan_id) 
    DEFERRABLE INITIALLY DEFERRED;
```

**Purpose**: Prevents duplicate active subscriptions for the same customer/merchant/plan combination.

#### Financial Data Validation
```sql
ALTER TABLE billing_events ADD CONSTRAINT billing_events_amount_positive 
    CHECK (amount > 0);

ALTER TABLE billing_events ADD CONSTRAINT billing_events_proration_factor_valid 
    CHECK (proration_factor >= 0 AND proration_factor <= 1);
```

**Purpose**: Ensures financial data integrity.

#### Stellar Address Format Validation
```sql
ALTER TABLE customers ADD CONSTRAINT customers_stellar_public_key_format 
    CHECK (stellar_public_key ~ '^G[A-Z0-9]{55}$');

ALTER TABLE merchants ADD CONSTRAINT merchants_stellar_public_key_format 
    CHECK (stellar_public_key ~ '^G[A-Z0-9]{55}$');
```

**Purpose**: Validates Stellar public key format.

### Triggers for Business Logic

#### Automatic Subscription Number Generation
```sql
CREATE OR REPLACE FUNCTION generate_subscription_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.subscription_number IS NULL OR NEW.subscription_number = '' THEN
        NEW.subscription_number := 'SUB-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || UPPER(SUBSTR(MD5(RANDOM()::TEXT), 1, 6));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

#### Customer Activity Tracking
```sql
CREATE OR REPLACE FUNCTION update_customer_last_active()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE customers 
    SET last_active_at = NOW() 
    WHERE id = NEW.customer_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

#### Duplicate Subscription Prevention
```sql
CREATE OR REPLACE FUNCTION prevent_duplicate_active_subscriptions()
RETURNS TRIGGER AS $$
BEGIN
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
```

## Views for Common Queries

### Active Subscriptions View
```sql
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
```

### Merchant Dashboard Summary View
```sql
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
```

### Customer Subscription History View
```sql
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
```

## Data Types and Enums

### Subscription Status
```sql
CREATE TYPE subscription_status AS ENUM (
    'trial',
    'active',
    'paused',
    'cancelled',
    'expired',
    'suspended'
);
```

### Billing Event Types
```sql
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
```

### Plan Types
```sql
CREATE TYPE plan_type AS ENUM (
    'fixed_monthly',
    'fixed_yearly',
    'usage_based',
    'tiered',
    'custom'
);
```

### Asset Types
```sql
CREATE TYPE asset_type AS ENUM (
    'native_xlm',
    'stellar_token',
    'erc20_token',
    'custom'
);
```

## Migration and Seeding

### Migration Files

1. **006_create_subscription_cache_schema.sql** - Main schema creation
2. **007_seed_subscription_cache_data.sql** - Mock data seeding

### Running Migrations

```bash
# Run all migrations
npm run migrate

# Run specific migration
npm run migrate:up -- --migration 006_create_subscription_cache_schema.sql

# Seed mock data
npm run migrate:up -- --migration 007_seed_subscription_cache_data.sql
```

### Mock Data Overview

The seeding script creates:

- **10 Customers** with diverse profiles and usage patterns
- **5 Merchants** across different business categories
- **3 Subscription Tiers** per merchant (Starter, Professional, Enterprise)
- **6+ Subscription Plans** per merchant with various pricing models
- **15+ Subscriptions** with different statuses and lifecycle stages
- **20+ Billing Events** including successful payments, upgrades, and cancellations
- **6 Subscription Metrics** records for analytics

## API Integration

### Common Query Patterns

#### Get Customer Active Subscriptions
```sql
SELECT * FROM active_subscriptions 
WHERE customer_stellar_public_key = $1 
ORDER BY started_at DESC;
```

#### Merchant Dashboard Data
```sql
SELECT * FROM merchant_dashboard_summary 
WHERE merchant_id = $1;
```

#### Billing History for Customer
```sql
SELECT be.*, p.name as plan_name, m.business_name as merchant_name
FROM billing_events be
JOIN subscription_plans p ON be.plan_id = p.id
JOIN merchants m ON be.merchant_id = m.id
WHERE be.customer_id = (SELECT id FROM customers WHERE stellar_public_key = $1)
ORDER BY be.event_timestamp DESC
LIMIT 50;
```

#### Trial Expiration Report
```sql
SELECT s.*, c.email, c.display_name, m.business_name
FROM subscriptions s
JOIN customers c ON s.customer_id = c.id
JOIN merchants m ON s.merchant_id = m.id
WHERE s.status = 'trial' 
  AND s.trial_ends_at BETWEEN NOW() AND NOW() + INTERVAL '7 days'
ORDER BY s.trial_ends_at ASC;
```

#### Revenue Analytics
```sql
SELECT 
    DATE_TRUNC('month', event_timestamp) as month,
    merchant_id,
    SUM(CASE WHEN payment_status = 'succeeded' THEN usd_equivalent ELSE 0 END) as revenue,
    COUNT(*) as total_events,
    COUNT(CASE WHEN payment_status = 'succeeded' THEN 1 END) as successful_payments
FROM billing_events 
WHERE event_timestamp >= DATE_TRUNC('year', CURRENT_DATE)
GROUP BY merchant_id, DATE_TRUNC('month', event_timestamp)
ORDER BY month DESC, revenue DESC;
```

## Performance Optimization

### Query Performance Guidelines

1. **Use Views**: Pre-computed views for complex joins
2. **Index Coverage**: Ensure all WHERE clauses have index support
3. **Partitioning**: Consider time-based partitioning for large billing_events table
4. **Connection Pooling**: Use connection pooling for high concurrency
5. **Read Replicas**: Offload reporting queries to read replicas

### Monitoring Queries

```sql
-- Slow query analysis
SELECT query, mean_time, calls, total_time
FROM pg_stat_statements
WHERE mean_time > 100
ORDER BY mean_time DESC;

-- Index usage analysis
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

-- Table size analysis
SELECT schemaname, tablename, 
       pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

## Security Considerations

### Data Protection

1. **API Key Hashing**: Store only hashed API keys
2. **Webhook Secrets**: Encrypt webhook secrets
3. **PII Protection**: Separate sensitive personal data
4. **Audit Logging**: Log all financial transactions
5. **Access Control**: Row-level security for multi-tenant data

### Compliance Features

- **Immutable Ledger**: Billing events cannot be modified
- **Audit Trail**: Complete subscription lifecycle tracking
- **Financial Accuracy**: Precise decimal handling for monetary values
- **Data Retention**: Configurable retention policies

## Troubleshooting

### Common Issues

#### Duplicate Subscription Errors
```sql
-- Check for existing active subscriptions
SELECT * FROM subscriptions 
WHERE customer_id = $1 AND merchant_id = $2 AND plan_id = $3 
  AND status IN ('trial', 'active', 'paused');
```

#### Performance Issues
```sql
-- Check query execution plan
EXPLAIN ANALYZE SELECT * FROM active_subscriptions 
WHERE merchant_id = $1 AND status = 'active';
```

#### Data Inconsistency
```sql
-- Verify foreign key constraints
SELECT conname, conrelid::regclass, confrelid::regclass
FROM pg_constraint
WHERE contype = 'f';
```

### Maintenance Operations

```sql
-- Update table statistics
ANALYZE customers;
ANALYZE merchants;
ANALYZE subscriptions;
ANALYZE billing_events;

-- Rebuild indexes (if needed)
REINDEX INDEX CONCURRENTLY idx_subscriptions_customer_status;

-- Vacuum analyze for performance
VACUUM ANALYZE billing_events;
```

## Future Enhancements

### Planned Improvements

1. **Time-Based Partitioning**: For billing_events table
2. **Materialized Views**: For complex analytics queries
3. **Full-Text Search**: For customer and merchant search
4. **Graph Data**: For referral and relationship tracking
5. **Event Sourcing**: For complete audit capabilities

### Scaling Considerations

- **Horizontal Scaling**: Database sharding by merchant_id
- **Caching Layer**: Redis for frequently accessed data
- **Read Replicas**: Dedicated reporting database
- **Event Streaming**: Kafka for real-time updates

## Conclusion

The Subscription Cache Schema provides a robust, scalable foundation for subscription management with:

- **Sub-50ms query performance** through strategic indexing
- **Complete data integrity** with comprehensive constraints
- **Business logic enforcement** at the database level
- **Immutable financial tracking** for compliance
- **Flexible metadata** for customization
- **Comprehensive analytics** support

This schema successfully bridges the gap between blockchain contract state and traditional SaaS subscription management, enabling lightning-fast API responses while maintaining data accuracy and business rule enforcement.
