import { Entity, PrimaryColumn, Column, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';
import { SubscriptionTier } from './SubscriptionTier';
import { SubscriptionPlan } from './SubscriptionPlan';
import { Subscription } from './Subscription';
import { BillingEvent } from './BillingEvent';
import { SubscriptionMetric } from './SubscriptionMetric';

@Entity('merchants')
export class Merchant {
  @PrimaryColumn({ type: 'uuid', default: () => 'uuid_generate_v4()' })
  id: string;

  @Column({ type: 'varchar', length: 56, unique: true })
  stellarPublicKey: string;

  @Column({ type: 'varchar', length: 255 })
  businessName: string;

  @Column({ type: 'varchar', length: 100, unique: true })
  slug: string;

  @Column({ type: 'text', nullable: true })
  logoUrl?: string;

  @Column({ type: 'text', nullable: true })
  websiteUrl?: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  supportEmail?: string;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  businessCategory?: string;

  @Column({ type: 'text', nullable: true })
  webhookEndpoint?: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  webhookSecret?: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  apiKeyHash?: string;

  @Column({ type: 'json', default: () => '[]' })
  apiPermissions: string[];

  @Column({ type: 'varchar', length: 3, default: 'USD' })
  defaultCurrency: string;

  @Column({ type: 'varchar', length: 50, default: 'UTC' })
  timezone: string;

  @Column({ type: 'varchar', length: 50, default: 'UTC' })
  billingTimezone: string;

  @Column({ type: 'boolean', default: false })
  isVerified: boolean;

  @Column({ type: 'boolean', default: true })
  isActive: boolean;

  @Column({ type: 'varchar', length: 20, default: 'pending' })
  verificationStatus: string;

  @Column({ type: 'json', default: () => '{}' })
  metadata: Record<string, any>;

  @Column({ type: 'json', default: () => '{}' })
  settings: Record<string, any>;

  @CreateDateColumn({ type: 'timestamptz' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamptz' })
  updatedAt: Date;

  @Column({ type: 'timestamptz', nullable: true })
  lastSyncAt?: Date;

  // Relations
  @OneToMany(() => SubscriptionTier, tier => tier.merchant)
  subscriptionTiers: SubscriptionTier[];

  @OneToMany(() => SubscriptionPlan, plan => plan.merchant)
  subscriptionPlans: SubscriptionPlan[];

  @OneToMany(() => Subscription, subscription => subscription.merchant)
  subscriptions: Subscription[];

  @OneToMany(() => BillingEvent, billingEvent => billingEvent.merchant)
  billingEvents: BillingEvent[];

  @OneToMany(() => SubscriptionMetric, metric => metric.merchant)
  subscriptionMetrics: SubscriptionMetric[];
}
