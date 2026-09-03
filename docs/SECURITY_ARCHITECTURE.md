# Security Architecture — Enterprise AWS Cloud Security Platform

## 1. Purpose

The Enterprise AWS Cloud Security Platform provides a security-focused foundation for monitoring and auditing AWS infrastructure.

The architecture follows several core security principles:

* Defense in depth
* Least privilege
* Centralized logging
* Network visibility
* Encryption at rest
* Infrastructure as Code
* Separation of security services
* Automated detection and notification
* Cost-aware operation

---

# 2. High-Level Security Architecture

```text
                         AWS ACCOUNT
                              |
                              v
                    +-------------------+
                    |       IAM         |
                    | Roles + Policies  |
                    +---------+---------+
                              |
                              v
                    +-------------------+
                    |       VPC         |
                    |    10.60.0.0/16   |
                    +---------+---------+
                              |
              +---------------+---------------+
              |                               |
              v                               v
       Public Subnets                  Private Subnets
       Availability Zone 1             Availability Zone 1
       Availability Zone 2             Availability Zone 2
              |                               |
              +---------------+---------------+
                              |
                              v
                      VPC Flow Logs
                              |
                              v
                       CloudWatch Logs
                              |
        +---------------------+----------------------+
        |                     |                      |
        v                     v                      v
   CloudTrail             AWS Config             CloudWatch
        |                     |                      |
        v                     v                      v
       S3                    S3              Metrics / Alarms
        |                                            |
        +--------------------------+-----------------+
                                   |
                                   v
                              EventBridge
                                   |
                                   v
                                  SNS
                                   |
                                   v
                             Notifications
```

---

# 3. Network Security

The platform creates a dedicated VPC:

```text
CIDR: 10.60.0.0/16
```

The VPC is divided into public and private subnet tiers across multiple Availability Zones.

This provides logical network separation.

## Public Tier

The public subnet tier is designed for resources that require controlled internet-facing connectivity.

## Private Tier

Private subnets are designed for internal resources that should not require direct public exposure.

The separation reduces the attack surface and supports a layered network architecture.

---

# 4. VPC Flow Logs

VPC Flow Logs provide visibility into network traffic.

The verified configuration:

```text
Status: ACTIVE
Traffic: ALL
Destination: CloudWatch Logs
```

Flow Logs help security teams investigate:

* Rejected traffic
* Unexpected connections
* Source/destination IPs
* Network communication patterns
* Potential scanning activity
* Misconfigured security groups

![VPC Flow Logs](../screenshots/06-vpc-flow-logs.png)

---

# 5. AWS CloudTrail

CloudTrail records AWS API activity.

The deployed trail:

```text
nexops-cloud-security-security-trail
```

was verified as:

```text
IsLogging: true
```

It is configured as a multi-region trail.

CloudTrail provides an audit trail for activities such as:

* IAM changes
* EC2 actions
* S3 operations
* Security group changes
* Configuration changes
* API calls

![CloudTrail](../screenshots/05-CloudTrial.png)

---

# 6. AWS Config

AWS Config continuously records supported AWS resource configuration.

The verified recorder status:

```text
recording: true
lastStatus: SUCCESS
```

AWS Config provides configuration visibility and supports compliance-oriented analysis.

Examples of security questions it can help answer:

* Was a security group modified?
* Was encryption disabled?
* Did a resource configuration change?
* Which resources exist in the account?
* What was the configuration at a particular time?

![AWS Config](../screenshots/07-aws-config.png)

---

# 7. Encryption with KMS

The platform creates a customer-managed AWS KMS key.

Alias:

```text
alias/nexops-cloud-security-security
```

KMS can be used to protect sensitive security data and log storage.

The architecture separates encryption key management from the services using the encrypted data.

![KMS](../screenshots/09-kms.png)

---

# 8. Secure S3 Storage

S3 is used as a security-log storage destination.

Security controls include:

* Block Public Access
* Server-side encryption
* Versioning where configured
* IAM-controlled access
* CloudTrail integration

The buckets are not intended to be public application storage.

![S3](../screenshots/S3.png)

---

# 9. IAM Security

IAM controls access between AWS services.

The Terraform project creates dedicated IAM roles and policies for services such as:

* CloudTrail
* AWS Config
* VPC Flow Logs

The design avoids granting unrestricted administrative permissions to individual services where a narrower service-specific role can be used.

---

# 10. CloudWatch Security Monitoring

CloudWatch provides centralized operational and security telemetry.

Configured log groups include:

```text
/aws/vpc/nexops-cloud-security-security/flow-logs
/nexops/nexops-cloud-security-security/cloudtrail
/nexops/nexops-cloud-security-security/security
```

The verified retention period was:

```text
30 days
```

![CloudWatch](../screenshots/08-cloudwatch.png)

---

# 11. EventBridge

EventBridge provides an event-driven integration layer.

Security-related events can be matched using EventBridge rules and forwarded to downstream targets.

The architecture therefore follows:

```text
AWS Event
     |
     v
EventBridge Rule
     |
     v
Target
     |
     v
SNS Notification
```

---

# 12. SNS Alerting

SNS provides the notification layer for security alerts.

The project creates a dedicated topic:

```text
nexops-cloud-security-security-alerts
```

During final verification:

```text
SubscriptionsConfirmed: 0
```

Therefore the topic infrastructure exists, but an email subscription was not confirmed.

![SNS](../screenshots/SNS.png)

---

# 13. Security Hub and GuardDuty

Security Hub and GuardDuty were intentionally not represented as successfully enabled services.

The AWS account returned:

```text
SubscriptionRequiredException
```

when attempting to access these services.

Therefore:

```text
Security Hub: Disabled
GuardDuty:    Disabled
```

This limitation is documented as part of the project's actual deployment evidence.

---

# 14. Defense in Depth

The project uses multiple independent security controls.

```text
Layer 1 → IAM
Layer 2 → VPC / Subnets
Layer 3 → VPC Flow Logs
Layer 4 → CloudTrail
Layer 5 → AWS Config
Layer 6 → CloudWatch
Layer 7 → KMS / Encryption
Layer 8 → EventBridge
Layer 9 → SNS
Layer 10 → Human investigation / response
```

If one security control misses an event, another layer may still provide useful evidence.

---

# 15. Security Data Flow

```text
AWS Resources
      |
      +------ API activity ------> CloudTrail
      |
      +------ Network traffic ---> VPC Flow Logs
      |
      +------ Configuration -----> AWS Config
      |
      v
CloudWatch / S3
      |
      v
Event Detection
      |
      v
EventBridge
      |
      v
SNS
      |
      v
Security Notification
```

---

# 16. Security Design Principles

### Least Privilege

IAM policies are scoped to the service operations required by the infrastructure.

### Encryption

Security data is protected using AWS encryption mechanisms and KMS.

### Centralized Logging

Security telemetry is collected into centralized AWS services.

### Network Visibility

VPC Flow Logs provide network-level visibility.

### Auditability

CloudTrail records API activity.

### Configuration Visibility

AWS Config records resource configuration.

### Infrastructure as Code

Terraform provides reproducible infrastructure.

### Evidence-Based Verification

AWS CLI and AWS Console screenshots were used to verify deployed resources.

---

# 17. Security Limitations

This project is a cloud-security infrastructure laboratory and portfolio project.

It should not be interpreted as a complete enterprise Security Operations Center.

Additional production capabilities could include:

* Security Hub
* GuardDuty
* SIEM integration
* Threat intelligence
* Automated incident response
* AWS Organizations
* Centralized multi-account logging
* Immutable security log archives
* WAF
* Shield
* Secrets rotation
* Automated compliance remediation

Some of these services were not enabled because of AWS account/service subscription constraints or project cost considerations.

---

# 18. Final Security Position

The project demonstrates how multiple AWS security services can be combined into a layered architecture using Terraform while maintaining:

* Network visibility
* Audit logging
* Configuration monitoring
* Encryption
* Alerting
* IAM controls
* Reproducibility
* Operational verification
