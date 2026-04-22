-- Subscription Cache Mock Data Seeding
-- Populates the database with realistic test data for local development and testing

-- Insert mock customers
INSERT INTO customers (id, stellar_public_key, email, display_name, timezone, language, metadata, created_at) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'GABC1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890', 'john.doe@example.com', 'John Doe', 'UTC', 'en', '{"source": "web", "referral": "organic"}', NOW() - INTERVAL '6 months'),
('550e8400-e29b-41d4-a716-446655440001', 'GDEF1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890', 'jane.smith@example.com', 'Jane Smith', 'America/New_York', 'en', '{"source": "mobile", "referral": "twitter"}', NOW() - INTERVAL '4 months'),
('550e8400-e29b-41d4-a716-446655440002', 'GHIJ1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890', 'bob.wilson@example.com', 'Bob Wilson', 'Europe/London', 'en', '{"source": "api", "referral": "partner"}', NOW() - INTERVAL '3 months'),
('550e8400-e29b-41d4-a716-446655440003', 'KLMN1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890', 'alice.brown@example.com', 'Alice Brown', 'Asia/Tokyo', 'en', '{"source": "web", "referral": "google"}', NOW() - INTERVAL '2 months'),
('550e8400-e29b-41d4-a716-446655440004', 'OPQR1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890', 'charlie.davis@example.com', 'Charlie Davis', 'Australia/Sydney', 'en', '{"source": "mobile", "referral": "facebook"}', NOW() - INTERVAL '1 month'),
('550e8400-e29b-41d4-a716-446655440005', 'STUV1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890', 'eva.martinez@example.com', 'Eva Martinez', 'UTC', 'es', '{"source": "web", "referral": "linkedin"}', NOW() - INTERVAL '3 weeks'),
('550e8400-e29b-41d4-a716-446655440006', 'WXYZ1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890', 'frank.taylor@example.com', 'Frank Taylor', 'America/Chicago', 'en', '{"source": "api", "referral": "direct"}', NOW() - INTERVAL '2 weeks'),
('550e8400-e29b-41d4-a716-446655440007', 'ABCD1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890', 'grace.anderson@example.com', 'Grace Anderson', 'UTC', 'en', '{"source": "web", "referral": "reddit"}', NOW() - INTERVAL '1 week'),
('550e8400-e29b-41d4-a716-446655440008', 'EFGH1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890', 'henry.thomas@example.com', 'Henry Thomas', 'Europe/Paris', 'en', '{"source": "mobile", "referral": "instagram"}', NOW() - INTERVAL '5 days'),
('550e8400-e29b-41d4-a716-446655440009', 'IJKL1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890', 'ivy.jackson@example.com', 'Ivy Jackson', 'America/Los_Angeles', 'en', '{"source": "web", "referral": "blog"}', NOW() - INTERVAL '3 days');

-- Insert mock merchants
INSERT INTO merchants (id, stellar_public_key, business_name, slug, logo_url, website_url, support_email, description, business_category, webhook_endpoint, api_key_hash, default_currency, timezone, is_verified, is_active, metadata, created_at) VALUES
('660e8400-e29b-41d4-a716-446655440000', 'MERCHANT1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890', 'TechStart Inc', 'techstart-inc', 'https://example.com/logo1.png', 'https://techstart.example.com', 'support@techstart.example.com', 'Leading SaaS platform for tech startups', 'technology', 'https://webhook.techstart.example.com/billing', 'hash1', 'USD', 'UTC', true, true, '{"employees": 50, "founded": 2020}', NOW() - INTERVAL '1 year'),
('660e8400-e29b-41d4-a716-446655440001', 'MERCHANT1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567891', 'Creative Studio Pro', 'creative-studio-pro', 'https://example.com/logo2.png', 'https://creativestudio.example.com', 'hello@creativestudio.example.com', 'Professional design and marketing services', 'creative', 'https://webhook.creativestudio.example.com/webhooks', 'hash2', 'USD', 'America/New_York', true, true, '{"employees": 15, "founded": 2019}', NOW() - INTERVAL '10 months'),
('660e8400-e29b-41d4-a716-446655440002', 'MERCHANT1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567892', 'DataFlow Analytics', 'dataflow-analytics', 'https://example.com/logo3.png', 'https://dataflow.example.com', 'info@dataflow.example.com', 'Advanced analytics and data visualization platform', 'data_analytics', 'https://webhook.dataflow.example.com/api', 'hash3', 'USD', 'Europe/London', false, true, '{"employees": 30, "founded": 2021}', NOW() - INTERVAL '8 months'),
('660e8400-e29b-41d4-a716-446655440003', 'MERCHANT1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567893', 'CloudHost Solutions', 'cloudhost-solutions', 'https://example.com/logo4.png', 'https://cloudhost.example.com', 'support@cloudhost.example.com', 'Enterprise cloud hosting and infrastructure', 'hosting', 'https://webhook.cloudhost.example.com/billing', 'hash4', 'USD', 'UTC', true, true, '{"employees": 100, "founded": 2018}', NOW() - INTERVAL '6 months'),
('660e8400-e29b-41d4-a716-446655440004', 'MERCHANT1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567894', 'EduLearn Platform', 'edulearn-platform', 'https://example.com/logo5.png', 'https://edulearn.example.com', 'contact@edulearn.example.com', 'Online learning management system for schools', 'education', 'https://webhook.edulearn.example.com/learn', 'hash5', 'USD', 'Asia/Tokyo', false, true, '{"employees": 25, "founded": 2020}', NOW() - INTERVAL '4 months');

-- Insert subscription tiers for TechStart Inc
INSERT INTO subscription_tiers (id, merchant_id, name, slug, description, level, is_default, is_visible, max_users, max_storage_gb, max_api_calls_per_month, features, display_order, created_at) VALUES
('770e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000', 'Starter', 'starter', 'Perfect for individuals and small teams', 1, true, true, 5, 10, 10000, '["basic_analytics", "email_support", "api_access"]', 1, NOW() - INTERVAL '1 year'),
('770e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440000', 'Professional', 'professional', 'For growing businesses and teams', 2, false, true, 25, 100, 100000, '["advanced_analytics", "priority_support", "api_access", "team_collaboration", "custom_integrations"]', 2, NOW() - INTERVAL '1 year'),
('770e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440000', 'Enterprise', 'enterprise', 'Complete solution for large organizations', 3, false, true, 100, 1000, 1000000, '["enterprise_analytics", "dedicated_support", "api_access", "team_collaboration", "custom_integrations", "sla_guarantee", "advanced_security"]', 3, NOW() - INTERVAL '1 year');

-- Insert subscription tiers for Creative Studio Pro
INSERT INTO subscription_tiers (id, merchant_id, name, slug, description, level, is_default, is_visible, max_users, max_storage_gb, max_api_calls_per_month, features, display_order, created_at) VALUES
('770e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440001', 'Basic', 'basic', 'Essential design tools for freelancers', 1, true, true, 1, 5, 1000, '["basic_templates", "stock_photos", "community_support"]', 1, NOW() - INTERVAL '10 months'),
('770e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440001', 'Pro', 'pro', 'Professional design suite for agencies', 2, false, true, 10, 50, 10000, '["premium_templates", "unlimited_photos", "priority_support", "brand_kit", "team_collaboration"]', 2, NOW() - INTERVAL '10 months'),
('770e8400-e29b-41d4-a716-446655440005', '660e8400-e29b-41d4-a716-446655440001', 'Agency', 'agency', 'Complete solution for design agencies', 3, false, true, 50, 500, 100000, '["all_templates", "unlimited_assets", "dedicated_support", "white_label", "api_access", "advanced_analytics"]', 3, NOW() - INTERVAL '10 months');

-- Insert subscription tiers for DataFlow Analytics
INSERT INTO subscription_tiers (id, merchant_id, name, slug, description, level, is_default, is_visible, max_users, max_storage_gb, max_api_calls_per_month, features, display_order, created_at) VALUES
('770e8400-e29b-41d4-a716-446655440006', '660e8400-e29b-41d4-a716-446655440002', 'Free', 'free', 'Basic analytics for personal use', 1, true, true, 1, 1, 1000, '["basic_dashboard", "5_reports", "community_support"]', 1, NOW() - INTERVAL '8 months'),
('770e8400-e29b-41d4-a716-446655440007', '660e8400-e29b-41d4-a716-446655440002', 'Business', 'business', 'Advanced analytics for businesses', 2, false, true, 10, 50, 10000, '["advanced_dashboard", "unlimited_reports", "custom_dashboards", "api_access", "email_support"]', 2, NOW() - INTERVAL '8 months'),
('770e8400-e29b-41d4-a716-446655440008', '660e8400-e29b-41d4-a716-446655440002', 'Enterprise', 'enterprise', 'Complete analytics platform for enterprises', 3, false, true, 100, 1000, 1000000, '["all_features", "white_label", "dedicated_support", "sla_guarantee", "custom_integrations"]', 3, NOW() - INTERVAL '8 months');

-- Insert subscription plans for TechStart Inc
INSERT INTO subscription_plans (id, merchant_id, tier_id, name, description, plan_type, base_price, currency, billing_interval_months, accepted_assets, default_asset, trial_days, trial_price, is_active, created_at) VALUES
('880e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000', '770e8400-e29b-41d4-a716-446655440000', 'Starter Monthly', 'Monthly billing for Starter tier', 'fixed_monthly', 29.99, 'USD', 1, '["USDC", "XLM", "ETH"]', 'USDC', 14, 0, true, NOW() - INTERVAL '1 year'),
('880e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440000', '770e8400-e29b-41d4-a716-446655440000', 'Starter Yearly', 'Yearly billing for Starter tier (20% off)', 'fixed_yearly', 287.90, 'USD', 12, '["USDC", "XLM", "ETH"]', 'USDC', 14, 0, true, NOW() - INTERVAL '1 year'),
('880e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440000', '770e8400-e29b-41d4-a716-446655440001', 'Professional Monthly', 'Monthly billing for Professional tier', 'fixed_monthly', 99.99, 'USD', 1, '["USDC", "XLM", "ETH"]', 'USDC', 14, 0, true, NOW() - INTERVAL '1 year'),
('880e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440000', '770e8400-e29b-41d4-a716-446655440001', 'Professional Yearly', 'Yearly billing for Professional tier (20% off)', 'fixed_yearly', 959.90, 'USD', 12, '["USDC", "XLM", "ETH"]', 'USDC', 14, 0, true, NOW() - INTERVAL '1 year'),
('880e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440000', '770e8400-e29b-41d4-a716-446655440002', 'Enterprise Monthly', 'Monthly billing for Enterprise tier', 'fixed_monthly', 499.99, 'USD', 1, '["USDC", "XLM", "ETH"]', 'USDC', 30, 0, true, NOW() - INTERVAL '1 year'),
('880e8400-e29b-41d4-a716-446655440005', '660e8400-e29b-41d4-a716-446655440000', '770e8400-e29b-41d4-a716-446655440002', 'Enterprise Yearly', 'Yearly billing for Enterprise tier (20% off)', 'fixed_yearly', 4799.90, 'USD', 12, '["USDC", "XLM", "ETH"]', 'USDC', 30, 0, true, NOW() - INTERVAL '1 year');

-- Insert subscription plans for Creative Studio Pro
INSERT INTO subscription_plans (id, merchant_id, tier_id, name, description, plan_type, base_price, currency, billing_interval_months, accepted_assets, default_asset, trial_days, trial_price, is_active, created_at) VALUES
('880e8400-e29b-41d4-a716-446655440006', '660e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440003', 'Basic Monthly', 'Monthly billing for Basic tier', 'fixed_monthly', 19.99, 'USD', 1, '["USDC", "XLM"]', 'USDC', 7, 0, true, NOW() - INTERVAL '10 months'),
('880e8400-e29b-41d4-a716-446655440007', '660e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440003', 'Basic Yearly', 'Yearly billing for Basic tier (15% off)', 'fixed_yearly', 203.90, 'USD', 12, '["USDC", "XLM"]', 'USDC', 7, 0, true, NOW() - INTERVAL '10 months'),
('880e8400-e29b-41d4-a716-446655440008', '660e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440004', 'Pro Monthly', 'Monthly billing for Pro tier', 'fixed_monthly', 79.99, 'USD', 1, '["USDC", "XLM", "ETH"]', 'USDC', 14, 0, true, NOW() - INTERVAL '10 months'),
('880e8400-e29b-41d4-a716-446655440009', '660e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440004', 'Pro Yearly', 'Yearly billing for Pro tier (20% off)', 'fixed_yearly', 767.90, 'USD', 12, '["USDC", "XLM", "ETH"]', 'USDC', 14, 0, true, NOW() - INTERVAL '10 months'),
('880e8400-e29b-41d4-a716-446655440010', '660e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440005', 'Agency Monthly', 'Monthly billing for Agency tier', 'fixed_monthly', 299.99, 'USD', 1, '["USDC", "XLM", "ETH"]', 'USDC', 21, 0, true, NOW() - INTERVAL '10 months'),
('880e8400-e29b-41d4-a716-446655440011', '660e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440005', 'Agency Yearly', 'Yearly billing for Agency tier (25% off)', 'fixed_yearly', 2699.90, 'USD', 12, '["USDC", "XLM", "ETH"]', 'USDC', 21, 0, true, NOW() - INTERVAL '10 months');

-- Insert subscription plans for DataFlow Analytics
INSERT INTO subscription_plans (id, merchant_id, tier_id, name, description, plan_type, base_price, currency, billing_interval_months, accepted_assets, default_asset, trial_days, trial_price, is_active, created_at) VALUES
('880e8400-e29b-41d4-a716-446655440012', '660e8400-e29b-41d4-a716-446655440002', '770e8400-e29b-41d4-a716-446655440006', 'Free Forever', 'Free tier with basic features', 'fixed_monthly', 0.00, 'USD', 1, '["USDC", "XLM"]', 'USDC', 0, 0, true, NOW() - INTERVAL '8 months'),
('880e8400-e29b-41d4-a716-446655440013', '660e8400-e29b-41d4-a716-446655440002', '770e8400-e29b-41d4-a716-446655440007', 'Business Monthly', 'Monthly billing for Business tier', 'fixed_monthly', 49.99, 'USD', 1, '["USDC", "XLM", "ETH"]', 'USDC', 14, 0, true, NOW() - INTERVAL '8 months'),
('880e8400-e29b-41d4-a716-446655440014', '660e8400-e29b-41d4-a716-446655440002', '770e8400-e29b-41d4-a716-446655440007', 'Business Yearly', 'Yearly billing for Business tier (15% off)', 'fixed_yearly', 509.90, 'USD', 12, '["USDC", "XLM", "ETH"]', 'USDC', 14, 0, true, NOW() - INTERVAL '8 months'),
('880e8400-e29b-41d4-a716-446655440015', '660e8400-e29b-41d4-a716-446655440002', '770e8400-e29b-41d4-a716-446655440008', 'Enterprise Monthly', 'Monthly billing for Enterprise tier', 'fixed_monthly', 199.99, 'USD', 1, '["USDC", "XLM", "ETH"]', 'USDC', 30, 0, true, NOW() - INTERVAL '8 months'),
('880e8400-e29b-41d4-a716-446655440016', '660e8400-e29b-41d4-a716-446655440002', '770e8400-e29b-41d4-a716-446655440008', 'Enterprise Yearly', 'Yearly billing for Enterprise tier (20% off)', 'fixed_yearly', 1919.90, 'USD', 12, '["USDC", "XLM", "ETH"]', 'USDC', 30, 0, true, NOW() - INTERVAL '8 months');

-- Insert mock subscriptions with various statuses
INSERT INTO subscriptions (id, customer_id, merchant_id, plan_id, tier_id, status, started_at, trial_ends_at, current_period_starts_at, current_period_ends_at, next_billing_at, current_price, currency, billing_asset, auto_renew, metadata, created_at) VALUES
-- Active subscriptions
('990e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000', '880e8400-e29b-41d4-a716-446655440000', '770e8400-e29b-41d4-a716-446655440000', 'active', NOW() - INTERVAL '5 months', NULL, NOW() - INTERVAL '1 month', NOW() + INTERVAL '1 month', NOW() + INTERVAL '1 month', 29.99, 'USD', 'USDC', true, '{"source": "web", "campaign": "spring_sale"}', NOW() - INTERVAL '5 months'),
('990e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440008', '770e8400-e29b-41d4-a716-446655440004', 'active', NOW() - INTERVAL '3 months', NULL, NOW() - INTERVAL '1 month', NOW() + INTERVAL '1 month', NOW() + INTERVAL '1 month', 79.99, 'USD', 'USDC', true, '{"source": "mobile", "campaign": "summer_promo"}', NOW() - INTERVAL '3 months'),
('990e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440013', '770e8400-e29b-41d4-a716-446655440007', 'active', NOW() - INTERVAL '2 months', NULL, NOW() - INTERVAL '1 month', NOW() + INTERVAL '1 month', NOW() + INTERVAL '1 month', 49.99, 'USD', 'USDC', true, '{"source": "api", "partner": "data_partner"}', NOW() - INTERVAL '2 months'),
('990e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440000', '880e8400-e29b-41d4-a716-446655440002', '770e8400-e29b-41d4-a716-446655440001', 'active', NOW() - INTERVAL '4 months', NULL, NOW() - INTERVAL '1 month', NOW() + INTERVAL '1 month', NOW() + INTERVAL '1 month', 99.99, 'USD', 'USDC', true, '{"source": "web", "referral": "customer_referral"}', NOW() - INTERVAL '4 months'),

-- Trial subscriptions
('990e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440006', '770e8400-e29b-41d4-a716-446655440003', 'trial', NOW() - INTERVAL '1 week', NOW() + INTERVAL '6 days', NOW() - INTERVAL '1 week', NOW() + INTERVAL '6 days', NOW() + INTERVAL '6 days', 19.99, 'USD', 'USDC', true, '{"source": "mobile", "trial_source": "app_store"}', NOW() - INTERVAL '1 week'),
('990e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440005', '660e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440012', '770e8400-e29b-41d4-a716-446655440006', 'trial', NOW() - INTERVAL '3 days', NOW() + INTERVAL '4 days', NOW() - INTERVAL '3 days', NOW() + INTERVAL '4 days', NOW() + INTERVAL '4 days', 0.00, 'USD', 'USDC', true, '{"source": "web", "trial_source": "google_ads"}', NOW() - INTERVAL '3 days'),

-- Cancelled subscriptions
('990e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440006', '660e8400-e29b-41d4-a716-446655440000', '880e8400-e29b-41d4-a716-446655440000', '770e8400-e29b-41d4-a716-446655440000', 'cancelled', NOW() - INTERVAL '3 months', NULL, NOW() - INTERVAL '3 months', NOW() - INTERVAL '2 months', NULL, NOW() - INTERVAL '2 months', 29.99, 'USD', 'USDC', false, '{"source": "web", "cancel_reason": "too_expensive"}', NOW() - INTERVAL '3 months'),
('990e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440007', '660e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440006', '770e8400-e29b-41d4-a716-446655440003', 'cancelled', NOW() - INTERVAL '1 month', NULL, NOW() - INTERVAL '1 month', NOW() - INTERVAL '1 week', NULL, NOW() - INTERVAL '1 week', 19.99, 'USD', 'USDC', false, '{"source": "mobile", "cancel_reason": "found_alternative"}', NOW() - INTERVAL '1 month'),

-- Expired subscriptions
('990e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440008', '660e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440012', '770e8400-e29b-41d4-a716-446655440006', 'expired', NOW() - INTERVAL '2 months', NULL, NOW() - INTERVAL '2 months', NOW() - INTERVAL '1 month', NULL, NOW() - INTERVAL '1 month', 0.00, 'USD', 'USDC', false, '{"source": "web", "expire_reason": "trial_not_converted"}', NOW() - INTERVAL '2 months'),

-- Paused subscriptions
('990e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440009', '660e8400-e29b-41d4-a716-446655440000', '880e8400-e29b-41d4-a716-446655440004', '770e8400-e29b-41d4-a716-446655440002', 'paused', NOW() - INTERVAL '1 month', NULL, NOW() - INTERVAL '1 month', NOW() + INTERVAL '2 months', NOW() + INTERVAL '2 months', 99.99, 'USD', 'USDC', false, '{"source": "web", "pause_reason": "vacation"}', NOW() - INTERVAL '1 month');

-- Insert subscription events
INSERT INTO subscription_events (id, subscription_id, event_type, previous_status, new_status, amount, currency, asset, usd_equivalent, transaction_hash, ledger_sequence, event_index, contract_id, description, event_timestamp, processed_at) VALUES
('aa0e8400-e29b-41d4-a716-446655440000', '990e8400-e29b-41d4-a716-446655440000', 'subscription_created', NULL, 'trial', 0.00, 'USD', 'USDC', 0.00, 'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890', 12345678, 0, 'CONTRACT1234567890', 'Subscription created with trial period', NOW() - INTERVAL '5 months', NOW() - INTERVAL '5 months'),
('aa0e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440000', 'trial_ended', 'trial', 'active', 29.99, 'USD', 'USDC', 29.99, 'bcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890', 12345679, 1, 'CONTRACT1234567890', 'Trial ended, converted to paid subscription', NOW() - INTERVAL '4 months', NOW() - INTERVAL '4 months'),
('aa0e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440000', 'subscription_billed', 'active', 'active', 29.99, 'USD', 'USDC', 29.99, 'cdef01234567890abcdef1234567890abcdef1234567890abcdef1234567890', 12345680, 0, 'CONTRACT1234567890', 'Monthly billing successful', NOW() - INTERVAL '3 months', NOW() - INTERVAL '3 months'),
('aa0e8400-e29b-41d4-a716-446655440003', '990e8400-e29b-41d4-a716-446655440000', 'subscription_billed', 'active', 'active', 29.99, 'USD', 'USDC', 29.99, 'def01234567890abcdef1234567890abcdef1234567890abcdef1234567890', 12345681, 0, 'CONTRACT1234567890', 'Monthly billing successful', NOW() - INTERVAL '2 months', NOW() - INTERVAL '2 months'),
('aa0e8400-e29b-41d4-a716-446655440004', '990e8400-e29b-41d4-a716-446655440000', 'subscription_billed', 'active', 'active', 29.99, 'USD', 'USDC', 29.99, 'ef01234567890abcdef1234567890abcdef1234567890abcdef1234567890', 12345682, 0, 'CONTRACT1234567890', 'Monthly billing successful', NOW() - INTERVAL '1 month', NOW() - INTERVAL '1 month'),

-- Events for cancelled subscription
('aa0e8400-e29b-41d4-a716-446655440005', '990e8400-e29b-41d4-a716-446655440006', 'subscription_created', NULL, 'trial', 0.00, 'USD', 'USDC', 0.00, 'f01234567890abcdef1234567890abcdef1234567890abcdef1234567890', 12345683, 0, 'CONTRACT1234567890', 'Subscription created with trial period', NOW() - INTERVAL '3 months', NOW() - INTERVAL '3 months'),
('aa0e8400-e29b-41d4-a716-446655440006', '990e8400-e29b-41d4-a716-446655440006', 'trial_ended', 'trial', 'active', 29.99, 'USD', 'USDC', 29.99, '01234567890abcdef1234567890abcdef1234567890abcdef1234567890', 12345684, 1, 'CONTRACT1234567890', 'Trial ended, converted to paid subscription', NOW() - INTERVAL '2 months', NOW() - INTERVAL '2 months'),
('aa0e8400-e29b-41d4-a716-446655440007', '990e8400-e29b-41d4-a716-446655440006', 'subscription_cancelled', 'active', 'cancelled', 0.00, 'USD', 'USDC', 0.00, '1234567890abcdef1234567890abcdef1234567890abcdef1234567890', 12345685, 0, 'CONTRACT1234567890', 'Subscription cancelled by user', NOW() - INTERVAL '2 months', NOW() - INTERVAL '2 months');

-- Insert billing events
INSERT INTO billing_events (id, subscription_id, merchant_id, customer_id, plan_id, event_type, category, amount, currency, asset, usd_equivalent, billing_period_start, billing_period_end, proration_factor, transaction_hash, ledger_sequence, event_index, contract_id, payment_status, metadata, event_timestamp, ingested_at) VALUES
-- Successful billing events
('bb0e8400-e29b-41d4-a716-446655440000', '990e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440000', '880e8400-e29b-41d4-a716-446655440000', 'subscription_billed', 'recurring', 29.99, 'USD', 'USDC', 29.99, NOW() - INTERVAL '2 months', NOW() - INTERVAL '1 month', 1.0000, 'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890', 12345680, 0, 'CONTRACT1234567890', 'succeeded', '{"payment_method": "stellar", "network": "public"}', NOW() - INTERVAL '2 months', NOW() - INTERVAL '2 months'),
('bb0e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440000', '880e8400-e29b-41d4-a716-446655440000', 'subscription_billed', 'recurring', 29.99, 'USD', 'USDC', 29.99, NOW() - INTERVAL '1 month', NOW(), 1.0000, 'bcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890', 12345681, 0, 'CONTRACT1234567890', 'succeeded', '{"payment_method": "stellar", "network": "public"}', NOW() - INTERVAL '1 month', NOW() - INTERVAL '1 month'),
('bb0e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440008', 'subscription_billed', 'recurring', 79.99, 'USD', 'USDC', 79.99, NOW() - INTERVAL '1 month', NOW(), 1.0000, 'cdef01234567890abcdef1234567890abcdef1234567890abcdef1234567890', 12345682, 1, 'CONTRACT1234567890', 'succeeded', '{"payment_method": "stellar", "network": "public"}', NOW() - INTERVAL '1 month', NOW() - INTERVAL '1 month'),
('bb0e8400-e29b-41d4-a716-446655440003', '990e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440013', 'subscription_billed', 'recurring', 49.99, 'USD', 'USDC', 49.99, NOW() - INTERVAL '1 month', NOW(), 1.0000, 'def01234567890abcdef1234567890abcdef1234567890abcdef1234567890', 12345683, 0, 'CONTRACT1234567890', 'succeeded', '{"payment_method": "stellar", "network": "public"}', NOW() - INTERVAL '1 month', NOW() - INTERVAL '1 month'),
('bb0e8400-e29b-41d4-a716-446655440004', '990e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440003', '880e8400-e29b-41d4-a716-446655440002', 'subscription_billed', 'recurring', 99.99, 'USD', 'USDC', 99.99, NOW() - INTERVAL '1 month', NOW(), 1.0000, 'ef01234567890abcdef1234567890abcdef1234567890abcdef1234567890', 12345684, 0, 'CONTRACT1234567890', 'succeeded', '{"payment_method": "stellar", "network": "public"}', NOW() - INTERVAL '1 month', NOW() - INTERVAL '1 month'),

-- Setup fee events
('bb0e8400-e29b-41d4-a716-446655440005', '990e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440004', '880e8400-e29b-41d4-a716-446655440006', 'subscription_created', 'setup', 0.00, 'USD', 'USDC', 0.00, NOW() - INTERVAL '1 week', NOW() + INTERVAL '6 days', 0.0000, '01234567890abcdef1234567890abcdef1234567890abcdef1234567890', 12345685, 0, 'CONTRACT1234567890', 'succeeded', '{"payment_method": "stellar", "network": "public", "trial": true}', NOW() - INTERVAL '1 week', NOW() - INTERVAL '1 week'),
('bb0e8400-e29b-41d4-a716-446655440006', '990e8400-e29b-41d4-a716-446655440005', '660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440005', '880e8400-e29b-41d4-a716-446655440012', 'subscription_created', 'setup', 0.00, 'USD', 'USDC', 0.00, NOW() - INTERVAL '3 days', NOW() + INTERVAL '4 days', 0.0000, '1234567890abcdef1234567890abcdef1234567890abcdef1234567890', 12345686, 1, 'CONTRACT1234567890', 'succeeded', '{"payment_method": "stellar", "network": "public", "trial": true}', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'),

-- Upgrade events
('bb0e8400-e29b-41d4-a716-446655440007', '990e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440010', 'subscription_upgraded', 'upgrade', 0.00, 'USD', 'USDC', 0.00, NOW() - INTERVAL '2 weeks', NOW() + INTERVAL '2 weeks', 0.0000, '234567890abcdef1234567890abcdef1234567890abcdef1234567890', 12345687, 0, 'CONTRACT1234567890', 'succeeded', '{"previous_plan": "Basic", "new_plan": "Agency", "proration": true}', NOW() - INTERVAL '2 weeks', NOW() - INTERVAL '2 weeks');

-- Insert subscription metrics for analytics
INSERT INTO subscription_metrics (id, merchant_id, plan_id, tier_id, metric_date, metric_period, new_subscriptions, active_subscriptions, cancelled_subscriptions, churned_subscriptions, trial_conversions, total_revenue, total_refunds, net_revenue, average_revenue_per_subscription, monthly_recurring_revenue, annual_recurring_revenue, customer_lifetime_value, churn_rate, created_at) VALUES
-- TechStart Inc metrics
('cc0e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000', '880e8400-e29b-41d4-a716-446655440000', '770e8400-e29b-41d4-a716-446655440000', CURRENT_DATE - INTERVAL '1 month', 'monthly', 2, 3, 1, 0, 1, 89.97, 0.00, 89.97, 29.99, 89.97, 1079.64, 2159.28, 359.94, 0.25, NOW() - INTERVAL '1 month'),
('cc0e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440000', '880e8400-e29b-41d4-a716-446655440002', '770e8400-e29b-41d4-a716-446655440001', CURRENT_DATE - INTERVAL '1 month', 'monthly', 1, 2, 0, 0, 0, 199.98, 0.00, 199.98, 99.99, 199.98, 2399.76, 4799.52, 599.94, 0.00, NOW() - INTERVAL '1 month'),
('cc0e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440000', '880e8400-e29b-41d4-a716-446655440004', '770e8400-e29b-41d4-a716-446655440002', CURRENT_DATE - INTERVAL '1 month', 'monthly', 0, 1, 0, 0, 0, 99.99, 0.00, 99.99, 99.99, 99.99, 1199.88, 2399.76, 199.98, 0.00, NOW() - INTERVAL '1 month'),

-- Creative Studio Pro metrics
('cc0e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440006', '770e8400-e29b-41d4-a716-446655440003', CURRENT_DATE - INTERVAL '1 month', 'monthly', 1, 1, 1, 0, 0, 19.99, 0.00, 19.99, 19.99, 19.99, 239.88, 239.88, 39.98, 0.50, NOW() - INTERVAL '1 month'),
('cc0e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440008', '770e8400-e29b-41d4-a716-446655440004', CURRENT_DATE - INTERVAL '1 month', 'monthly', 0, 1, 0, 0, 0, 79.99, 0.00, 79.99, 79.99, 79.99, 959.88, 959.88, 159.98, 0.00, NOW() - INTERVAL '1 month'),

-- DataFlow Analytics metrics
('cc0e8400-e29b-41d4-a716-446655440005', '660e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440012', '770e8400-e29b-41d4-a716-446655440006', CURRENT_DATE - INTERVAL '1 month', 'monthly', 1, 1, 0, 1, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.00, NOW() - INTERVAL '1 month'),
('cc0e8400-e29b-41d4-a716-446655440006', '660e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440013', '770e8400-e29b-41d4-a716-446655440007', CURRENT_DATE - INTERVAL '1 month', 'monthly', 0, 1, 0, 0, 0, 49.99, 0.00, 49.99, 49.99, 49.99, 599.88, 599.88, 99.98, 0.00, NOW() - INTERVAL '1 month');

-- Update last_sync_at for merchants
UPDATE merchants SET last_sync_at = NOW() WHERE is_active = true;

-- Update statistics in subscription_tiers
UPDATE subscription_tiers SET 
    max_users = CASE 
        WHEN level = 1 THEN 5
        WHEN level = 2 THEN 25
        WHEN level = 3 THEN 100
        ELSE max_users
    END,
    max_storage_gb = CASE 
        WHEN level = 1 THEN 10
        WHEN level = 2 THEN 100
        WHEN level = 3 THEN 1000
        ELSE max_storage_gb
    END,
    max_api_calls_per_month = CASE 
        WHEN level = 1 THEN 10000
        WHEN level = 2 THEN 100000
        WHEN level = 3 THEN 1000000
        ELSE max_api_calls_per_month
    END;

-- Add some tags to customers for testing
UPDATE customers SET tags = ARRAY['premium', 'early_adopter'] WHERE id IN ('550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440001');
UPDATE customers SET tags = ARRAY['trial_user', 'mobile'] WHERE id IN ('550e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440005');
UPDATE customers SET tags = ARRAY['churned', 'price_sensitive'] WHERE id IN ('550e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440007');

-- Add custom attributes to subscriptions for testing
UPDATE subscriptions SET custom_attributes = '{"utm_source": "google", "utm_campaign": "spring_sale", "referral_code": "FRIEND2023"}' WHERE id IN ('990e8400-e29b-41d4-a716-446655440000', '990e8400-e29b-41d4-a716-446655440001');
UPDATE subscriptions SET custom_attributes = '{"support_tier": "priority", "account_manager": "john.doe@company.com"}' WHERE id IN ('990e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440003');

-- Create some additional mock data for stress testing
INSERT INTO customers (id, stellar_public_key, email, display_name, created_at) VALUES
('550e8400-e29b-41d4-a716-446655440010', 'TEST111111111111111111111111111111111111111111111111111111111', 'user10@example.com', 'User Ten', NOW() - INTERVAL '1 day'),
('550e8400-e29b-41d4-a716-446655440011', 'TEST222222222222222222222222222222222222222222222222222222222', 'user11@example.com', 'User Eleven', NOW() - INTERVAL '1 day'),
('550e8400-e29b-41d4-a716-446655440012', 'TEST333333333333333333333333333333333333333333333333333333333', 'user12@example.com', 'User Twelve', NOW() - INTERVAL '1 day'),
('550e8400-e29b-41d4-a716-446655440013', 'TEST444444444444444444444444444444444444444444444444444444444', 'user13@example.com', 'User Thirteen', NOW() - INTERVAL '1 day'),
('550e8400-e29b-41d4-a716-446655440014', 'TEST555555555555555555555555555555555555555555555555555555555555', 'user14@example.com', 'User Fourteen', NOW() - INTERVAL '1 day');

-- Add some active subscriptions for stress testing
INSERT INTO subscriptions (id, customer_id, merchant_id, plan_id, tier_id, status, started_at, current_period_starts_at, current_period_ends_at, next_billing_at, current_price, currency, billing_asset, auto_renew, created_at) VALUES
('990e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440010', '660e8400-e29b-41d4-a716-446655440000', '880e8400-e29b-41d4-a716-446655440000', '770e8400-e29b-41d4-a716-446655440000', 'active', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day', NOW() + INTERVAL '29 days', NOW() + INTERVAL '29 days', 29.99, 'USD', 'USDC', true, NOW() - INTERVAL '1 day'),
('990e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440011', '660e8400-e29b-41d4-a716-446655440000', '880e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440001', 'active', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day', NOW() + INTERVAL '29 days', NOW() + INTERVAL '29 days', 99.99, 'USD', 'USDC', true, NOW() - INTERVAL '1 day'),
('990e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440012', '660e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440006', '770e8400-e29b-41d4-a716-446655440003', 'active', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day', NOW() + INTERVAL '29 days', NOW() + INTERVAL '29 days', 19.99, 'USD', 'USDC', true, NOW() - INTERVAL '1 day'),
('990e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440013', '660e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440013', '770e8400-e29b-41d4-a716-446655440007', 'active', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day', NOW() + INTERVAL '29 days', NOW() + INTERVAL '29 days', 49.99, 'USD', 'USDC', true, NOW() - INTERVAL '1 day'),
('990e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440014', '660e8400-e29b-41d4-a716-446655440000', '880e8400-e29b-41d4-a716-446655440004', '770e8400-e29b-41d4-a716-446655440002', 'active', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day', NOW() + INTERVAL '29 days', NOW() + INTERVAL '29 days', 99.99, 'USD', 'USDC', true, NOW() - INTERVAL '1 day');

-- Update table statistics for optimal query planning
ANALYZE customers;
ANALYZE merchants;
ANALYZE subscription_tiers;
ANALYZE subscription_plans;
ANALYZE subscriptions;
ANALYZE subscription_events;
ANALYZE billing_events;
ANALYZE subscription_metrics;
