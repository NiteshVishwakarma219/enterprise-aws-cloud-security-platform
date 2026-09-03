# NexOps Enterprise AWS Cloud Security Platform — Architecture

## 1. High-Level Architecture

```text
                              ┌──────────────────────────────┐
                              │          AWS Account          │
                              │        us-east-1 Region      │
                              └──────────────┬───────────────┘
                                             │
                                             ▼
                         ┌─────────────────────────────────────┐
                         │       VPC: 10.60.0.0/16             │
                         │   NexOps Cloud Security Platform   │
                         └─────────────────┬───────────────────┘
                                           │
                  ┌────────────────────────┼────────────────────────┐
                  │                        │                        │
                  ▼                        ▼                        ▼
        ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
        │   Public Subnet  │    │  Private Subnet  │    │  Private Subnet  │
        │      AZ-1        │    │      AZ-1        │    │      AZ-2        │
        └────────┬─────────┘    └────────┬─────────┘    └────────┬─────────┘
                 │                       │                       │
                 │                       │                       │
                 └───────────────┬───────┴───────────────────────┘
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │     VPC Flow Logs       │
                    │       ALL Traffic       │
                    └────────────┬────────────┘
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │      CloudWatch Logs     │
                    │  /aws/vpc/.../flow-logs │
                    └─────────────────────────┘


       AWS API / Management Events
                    │
                    ▼
          ┌─────────────────────┐
          │      CloudTrail      │
          │  Multi-Region Trail  │
          │  Log File Validation │
          └──────────┬──────────┘
                     │
             ┌───────┴────────┐
             ▼                ▼
     ┌──────────────┐  ┌──────────────────┐
     │ S3 Bucket    │  │ CloudWatch Logs  │
     │ CloudTrail   │  │ Security Logs    │
     └──────┬───────┘  └────────┬─────────┘
            │                   │
            │                   ▼
            │          ┌────────────────────┐
            │          │ CloudWatch Events  │
            │          │ / EventBridge       │
            │          └─────────┬──────────┘
            │                    │
            │                    ▼
            │          ┌────────────────────┐
            │          │    SNS Topic       │
            │          │ Security Alerts    │
            │          └────────────────────┘
            │
            ▼
      ┌──────────────┐
      │ KMS Customer │
      │ Managed Key  │
      └──────────────┘


                 AWS Config
                     │
                     ▼
          ┌─────────────────────┐
          │ Configuration       │
          │ Recorder            │
          │ Continuous / ALL    │
          │ Supported Resources │
          └──────────┬──────────┘
                     │
                     ▼
             ┌───────────────┐
             │ Config S3     │
             │ Storage       │
             └───────────────┘
```

---

## 2. Security Monitoring Flow

```text
AWS Resources
     │
     ├──────────────► AWS CloudTrail
     │                     │
     │                     ├──► S3
     │                     │
     │                     └──► CloudWatch Logs
     │
     ├──────────────► AWS Config
     │                     │
     │                     └──► Configuration history
     │
     └──────────────► VPC Flow Logs
                           │
                           └──► CloudWatch Logs

CloudWatch / EventBridge
          │
          ▼
    Security Events
          │
          ▼
      SNS Topic
          │
          ▼
   Security Notification
```

---

## 3. Core Components

| Component         | Purpose                                           |
| ----------------- | ------------------------------------------------- |
| VPC               | Isolated AWS network boundary                     |
| Public Subnets    | Internet-facing/network infrastructure            |
| Private Subnets   | Internal resources and security isolation         |
| Internet Gateway  | Internet connectivity for public networking       |
| Route Tables      | Control subnet traffic routing                    |
| VPC Flow Logs     | Capture network traffic metadata                  |
| CloudTrail        | Record AWS API activity                           |
| AWS Config        | Track AWS resource configuration                  |
| CloudWatch Logs   | Centralized security and network logs             |
| CloudWatch Alarms | Detect configured security/operational conditions |
| EventBridge       | Route security events                             |
| SNS               | Security alert notification channel               |
| S3                | Durable security-log/configuration storage        |
| KMS               | Encryption key management                         |
| IAM Roles         | Controlled service permissions                    |
| Security Groups   | Network-level access control                      |

---

## 4. Network Layout

The platform uses the `10.60.0.0/16` VPC CIDR.

```text
VPC
10.60.0.0/16
│
├── Availability Zone 1
│   ├── Public Subnet
│   └── Private Subnet
│
└── Availability Zone 2
    ├── Public Subnet
    └── Private Subnet
```

This provides subnet-level isolation and availability across multiple Availability Zones.

---

## 5. Logging Architecture

### CloudTrail

CloudTrail records AWS API activity and sends security audit logs to the dedicated CloudTrail S3 bucket and CloudWatch Logs.

```text
AWS API Activity
       │
       ▼
   CloudTrail
       │
       ├────────► S3
       │
       └────────► CloudWatch Logs
```

The deployed trail is configured as a **multi-region trail** with **log file validation enabled**.

---

### VPC Flow Logs

The VPC Flow Log captures **ALL traffic** for the security VPC.

```text
VPC
 │
 ▼
VPC Flow Logs
 │
 ▼
CloudWatch Log Group
/aws/vpc/nexops-cloud-security-security/flow-logs
```

---

### AWS Config

AWS Config continuously records supported AWS resource configuration information.

```text
AWS Resources
      │
      ▼
AWS Config Recorder
      │
      ▼
Configuration History
      │
      ▼
S3
```

---

## 6. Encryption

The platform provisions a customer-managed AWS KMS key.

```text
Security Data
     │
     ├── CloudTrail
     ├── AWS Config
     ├── S3
     └── Security Logs
             │
             ▼
        AWS KMS Key
```

KMS alias:

```text
alias/nexops-cloud-security-security
```

---

## 7. Alerting Architecture

Security-related events can be routed through EventBridge/CloudWatch to SNS.

```text
AWS Security / Monitoring Event
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
       Email / Subscriber
```

The deployed SNS topic is:

```text
nexops-cloud-security-security-alerts
```

At the time of verification, the topic had **0 confirmed subscriptions**, so email delivery should not be represented as an active verified notification channel.

---

## 8. Security Services Status

| Service             | Project Status                              |
| ------------------- | ------------------------------------------- |
| CloudTrail          | Enabled                                     |
| VPC Flow Logs       | Active                                      |
| AWS Config          | Recording                                   |
| CloudWatch Logs     | Configured                                  |
| KMS                 | Enabled / Key created                       |
| S3 Security Storage | Configured                                  |
| SNS                 | Topic created                               |
| EventBridge         | Configured                                  |
| Security Hub        | Disabled — account subscription unavailable |
| GuardDuty           | Disabled — account subscription unavailable |

Security Hub and GuardDuty are intentionally documented according to the actual AWS account behavior rather than being falsely presented as enabled.

---

## 9. Infrastructure as Code

The entire infrastructure is provisioned and managed using Terraform.

```text
Terraform
    │
    ├── VPC
    ├── Subnets
    ├── Route Tables
    ├── Internet Gateway
    ├── Security Groups
    ├── IAM Roles / Policies
    ├── CloudTrail
    ├── AWS Config
    ├── VPC Flow Logs
    ├── CloudWatch
    ├── EventBridge
    ├── SNS
    ├── S3
    └── KMS
```

The project follows Infrastructure-as-Code principles so infrastructure can be reproduced, reviewed, modified and destroyed using Terraform.

---

## 10. Security Design Principles

* Defense in depth
* Network segmentation
* Centralized logging
* Continuous configuration monitoring
* Encryption at rest
* Least-privilege IAM
* Private resource isolation
* Multi-AZ network design
* Infrastructure as Code
* Reproducible deployment
* Auditable infrastructure changes
* Cost-aware resource lifecycle management

---

## 11. Deployment Lifecycle

```text
Terraform Init
      │
      ▼
Terraform Validate
      │
      ▼
Terraform Plan
      │
      ▼
Terraform Apply
      │
      ▼
AWS Security Infrastructure
      │
      ▼
Verification
      │
      ├── CloudTrail
      ├── VPC Flow Logs
      ├── AWS Config
      ├── CloudWatch
      ├── KMS
      ├── S3
      └── SNS
      │
      ▼
Evidence Screenshots
      │
      ▼
Terraform Destroy
```

---

## 12. Evidence

The `screenshots/` directory contains terminal and AWS Console evidence collected during deployment and verification.

These screenshots demonstrate that the infrastructure was actually provisioned and verified rather than being only theoretical Terraform configuration.

---

**Project:** NexOps Enterprise AWS Cloud Security Platform
**Infrastructure:** Terraform + AWS
**Region:** `us-east-1`
**VPC:** `10.60.0.0/16`
