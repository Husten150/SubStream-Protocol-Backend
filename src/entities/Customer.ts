import { Entity, PrimaryColumn, Column, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';
import { Subscription } from './Subscription';
import { BillingEvent } from './BillingEvent';

export enum SubscriptionStatus {
  TRIAL = 'trial',
  ACTIVE = 'active',
  PAUSED = 'paused',
  CANCELLED = 'cancelled',
  EXPIRED = 'expired',
  SUSPENDED = 'suspended'
}

@Entity('customers')
export class Customer {
  @PrimaryColumn({ type: 'uuid', default: () => 'uuid_generate_v4()' })
  id: string;

  @Column({ type: 'varchar', length: 56, unique: true })
  stellarPublicKey: string;

  @Column({ type: 'varchar', length: 56, nullable: true })
  stellarAddress?: string;

  @Column({ type: 'varchar', length: 255, unique: true, nullable: true })
  email?: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  displayName?: string;

  @Column({ type: 'text', nullable: true })
  avatarUrl?: string;

  @Column({ type: 'varchar', length: 50, default: 'UTC' })
  timezone: string;

  @Column({ type: 'varchar', length: 10, default: 'en' })
  language: string;

  @Column({ type: 'json', default: () => '{}' })
  metadata: Record<string, any>;

  @Column({ type: 'text', array: true, default: () => '[]' })
  tags: string[];

  @CreateDateColumn({ type: 'timestamptz' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamptz' })
  updatedAt: Date;

  @Column({ type: 'timestamptz', default: () => 'NOW()' })
  lastActiveAt: Date;

  // Relations
  @OneToMany(() => Subscription, subscription => subscription.customer)
  subscriptions: Subscription[];

  @OneToMany(() => BillingEvent, billingEvent => billingEvent.customer)
  billingEvents: BillingEvent[];
}
