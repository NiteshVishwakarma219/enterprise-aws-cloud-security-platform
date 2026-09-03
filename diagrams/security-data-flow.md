# Security Data Flow

## 1. Overview

This document describes how security, audit and network telemetry flows through the NexOps Enterprise AWS Cloud Security Platform.

The platform collects AWS API activity, network flow information and AWS resource configuration data and routes this information into centralized AWS logging and monitoring services.

---

## 2. Complete Security Data Flow

```text
                         ┌──────────────────────┐
                         │    AWS Resources     │
                         │                      │
                         │ VPC / IAM / S3 /     │
                         │ EC2 / Other Services │
                         └──────────┬───────────┘
                                    │
                  ┌─────────────────┼─────────────────┐
                  │                 │                 │
                  ▼                 ▼                 ▼
            ┌───────────┐    ┌──────────────┐   ┌──────────────┐
            │ CloudTrail│    │ VPC Flow     │   │ AWS Config   │
            │           │    │ Logs         │   │              │
            └─────┬─────┘    └──────┬───────┘   └──────┬───────┘
                  │                  │                  │
                  ▼                  ▼                  ▼
            ┌───────────┐    ┌──────────────┐   ┌──────────────┐
            │ CloudTrail│    │ CloudWatch   │   │ Config       │
            │ S3 Bucket │    │ Logs         │   │ Storage      │
            └─────┬─────┘    └──────┬───────┘   └──────────────┘
                  │                  │
                  │                  ▼
                  │          ┌──────────────┐
                  │          │ CloudWatch / │
                  │          │ EventBridge  │
                  │          └──────┬───────┘
                  │                 │
                  │                 ▼
                  │          ┌──────────────┐
                  │          │ SNS Security │
                  │          │ Alerts       │
                  │          └──────┬───────┘
                  │                 │
                  │                 ▼
                  │             Subscriber
                  │
                  ▼
             KMS Encryption
```

---

## 3. CloudTrail Data Flow

CloudTrail records AWS API activity.

```text
AWS API Request
      │
      ▼
CloudTrail
      │
      ├──────────────► CloudTrail S3 Bucket
      │
      └──────────────► CloudWatch Log Group
                              │
                              ▼
                         Monitoring
```

The deployed CloudTrail configuration includes:

* Multi-region trail
* Global service events
* Log file validation
* S3-based long-term storage
* CloudWatch integration

---

## 4. VPC Flow Log Data Flow

Network traffic metadata is collected at the VPC level.

```text
Network Traffic
      │
      ▼
VPC Flow Logs
      │
      │ ALL traffic
      ▼
CloudWatch Logs
      │
      ▼
Security Monitoring
```

The verified Flow Log status was:

```text
FlowLogStatus : ACTIVE
TrafficType   : ALL
```

Log destination:

```text
/aws/vpc/nexops-cloud-security-security/flow-logs
```

---

## 5. AWS Config Data Flow

AWS Config provides configuration visibility into supported resources.

```text
AWS Resources
      │
      ▼
AWS Config Recorder
      │
      ▼
Configuration Data
      │
      ├────────► Configuration History
      │
      └────────► S3 Storage
```

The deployed recorder was verified as:

```text
Recording: true
Status: SUCCESS
Frequency: CONTINUOUS
Scope: PAID
```

---

## 6. CloudWatch Monitoring Flow

CloudWatch provides centralized log storage and monitoring.

```text
CloudTrail ────────────┐
                       │
VPC Flow Logs ─────────┼──► CloudWatch Logs
                       │
Security Events ───────┘
                              │
                              ▼
                       Metric Filters
                              │
                              ▼
                       CloudWatch Alarms
                              │
                              ▼
                             SNS
```

Security log group:

```text
/nexops/nexops-cloud-security-security/security
```

CloudTrail log group:

```text
/nexops/nexops-cloud-security-security/cloudtrail
```

VPC Flow Log group:

```text
/aws/vpc/nexops-cloud-security-security/flow-logs
```

---

## 7. EventBridge Security Event Flow

The event-driven monitoring path is:

```text
AWS Event
    │
    ▼
EventBridge
    │
    ▼
Security Event Rule
    │
    ▼
SNS Topic
    │
    ▼
Notification Subscriber
```

The SNS topic created by the platform is:

```text
nexops-cloud-security-security-alerts
```

### Important deployment status

The SNS topic was successfully created, but verification showed:

```text
SubscriptionsConfirmed: 0
```

Therefore, this repository does **not** claim that email notifications were successfully delivered during the deployment.

---

## 8. Encryption Data Flow

Security-related data is protected using AWS KMS and S3 encryption mechanisms.

```text
Security Data
      │
      ▼
Encryption Layer
      │
      ▼
AWS KMS Customer Managed Key
      │
      ▼
Encrypted Storage
```

KMS alias:

```text
alias/nexops-cloud-security-security
```

---

## 9. IAM Permission Flow

AWS services use IAM roles and policies to access required resources.

```text
AWS Service
     │
     ▼
IAM Role
     │
     ▼
IAM Policy
     │
     ▼
Required AWS Resource
```

Examples include:

```text
CloudTrail
    │
    └──► S3 / CloudWatch

AWS Config
    │
    └──► Configuration Storage

VPC Flow Logs
    │
    └──► CloudWatch Logs
```

The architecture follows the principle of granting services only the permissions required for their intended function.

---

## 10. Detection and Response Concept

The platform follows this security-monitoring lifecycle:

```text
                 EVENT
                   │
                   ▼
             COLLECTION
                   │
       ┌───────────┼───────────┐
       ▼           ▼           ▼
  CloudTrail   Flow Logs    AWS Config
       │           │           │
       └───────────┼───────────┘
                   ▼
              CENTRALIZE
                   │
                   ▼
              CloudWatch
                   │
                   ▼
                DETECT
                   │
                   ▼
              EventBridge
                   │
                   ▼
                 ALERT
                   │
                   ▼
                  SNS
                   │
                   ▼
              RESPOND / REVIEW
```

---

## 11. Security Service Availability

Some AWS security services could not be activated in the project account because AWS returned:

```text
SubscriptionRequiredException
```

This affected:

```text
AWS Security Hub
Amazon GuardDuty
```

The platform therefore documents these services as unavailable/disabled instead of representing them as successfully deployed.

This is an important real-world cloud engineering consideration: infrastructure code can be correct while an AWS account, region, subscription entitlement or service availability constraint prevents a managed service from being activated.

---

## 12. Verification Evidence

Evidence collected during deployment is stored in:

```text
screenshots/
```

Relevant evidence includes:

| Evidence          | Screenshot                             |
| ----------------- | -------------------------------------- |
| Terraform Plan    | `01-terraform-plan.png`                |
| Terraform Outputs | `02-terraform-output'.png`             |
| Terraform State   | `03-terraform-state-list.png`          |
| VPC               | `04-vpc.png` / `VPC.png`               |
| CloudTrail        | `05-CloudTrial.png` / `CloudTrial.png` |
| VPC Flow Logs     | `06-vpc-flow-logs.png`                 |
| AWS Config        | `07-aws-config.png`                    |
| CloudWatch        | `08-cloudwatch.png` / `cloudwatch.png` |
| KMS               | `09-kms.png`                           |
| VPC Subnets       | `VPC-subnet.png`                       |
| S3                | `S3.png`                               |
| SNS               | `SNS.png`                              |

---

## 13. Lifecycle

The platform was deployed, verified and subsequently destroyed to control AWS costs.

```text
DESIGN
  │
  ▼
TERRAFORM
  │
  ▼
DEPLOY
  │
  ▼
VERIFY
  │
  ▼
COLLECT EVIDENCE
  │
  ▼
DOCUMENT
  │
  ▼
DESTROY
```

This lifecycle demonstrates not only deployment but also responsible cloud-resource management.

---

## 14. Key Security Principles Demonstrated

* Centralized audit logging
* Network traffic visibility
* Resource configuration monitoring
* IAM-based service authorization
* Encryption with KMS
* Secure S3 storage
* Event-driven alerting
* CloudWatch monitoring
* Multi-AZ network design
* Infrastructure as Code
* Verification using AWS CLI
* Evidence-based documentation
* Cost-conscious teardown

---

**Project:** NexOps Enterprise AWS Cloud Security Platform
**AWS Region:** `us-east-1`
**VPC CIDR:** `10.60.0.0/16`
**Infrastructure Tool:** Terraform
