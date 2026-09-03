# Incident Postmortem — Enterprise AWS Cloud Security Platform

## 1. Purpose

This document records significant issues encountered during the development and deployment of the Enterprise AWS Cloud Security Platform.

The objective is not to present a perfect deployment.

The objective is to demonstrate the actual engineering process:

```text
Deploy
  ↓
Observe Failure
  ↓
Investigate
  ↓
Identify Root Cause
  ↓
Apply Fix
  ↓
Verify
  ↓
Document
```

---

# 2. Incident: Security Hub Enablement Failed

## Symptom

Terraform failed while creating the Security Hub resource.

Error:

```text
SubscriptionRequiredException:
The AWS Access Key Id needs a subscription for the service
```

The AWS CLI reproduced the same problem:

```powershell
aws securityhub describe-hub --region us-east-1
```

Result:

```text
SubscriptionRequiredException
```

---

## Investigation

AWS identity was verified:

```powershell
aws sts get-caller-identity
```

Result:

```text
Account: 234951664471
Arn: arn:aws:iam::234951664471:user/cloudwithnitesh
```

This confirmed that the AWS credentials themselves were valid.

The failure occurred specifically when accessing Security Hub.

---

## Root Cause

The AWS account/API identity did not have the required service subscription/access state for Security Hub.

This was not caused by:

* Incorrect Terraform syntax
* Incorrect AWS region
* Invalid IAM identity
* Invalid AWS CLI credentials

---

## Resolution

Security Hub was not forced into the final architecture.

Terraform was adjusted so that the project could complete without pretending that Security Hub was active.

Final state:

```text
securityhub_status = disabled
```

---

# 3. Incident: GuardDuty Access Failed

## Symptom

The following command failed:

```powershell
aws guardduty list-detectors
```

Error:

```text
SubscriptionRequiredException
```

---

## Investigation

The AWS identity was verified independently using:

```powershell
aws sts get-caller-identity
```

The same account was successfully able to access services such as:

* EC2
* CloudTrail
* AWS Config
* CloudWatch
* S3
* SNS

Therefore the problem was service-specific.

---

## Root Cause

GuardDuty required service subscription/access that was unavailable for the current account/API identity.

---

## Resolution

GuardDuty was not represented as an active security control.

Final Terraform output:

```text
guardduty_status = disabled
```

---

# 4. Incident: Terraform State and Generated Provider Files

During development, Terraform downloaded the AWS provider into:

```text
terraform/.terraform/
```

The provider executable was approximately 863 MB.

GitHub rejected the repository because GitHub's maximum individual file size is 100 MB.

---

## Root Cause

The generated `.terraform` directory had accidentally entered Git history.

---

## Resolution

The repository was configured with:

```text
.terraform/
*.tfstate
*.tfstate.*
```

and other sensitive/generated files were excluded.

The provider binaries are dependencies downloaded by:

```powershell
terraform init
```

and do not belong in source control.

---

# 5. Incident: Cost Investigation

Because the platform contains AWS security and logging services, cost monitoring was performed before final teardown.

A Cost Explorer query initially used an invalid group definition:

```text
Group Definition is invalid.
Both type and key need to be set to a non-empty value.
```

The corrected query used:

```text
Type=DIMENSION
Key=SERVICE
```

Example:

```powershell
aws ce get-cost-and-usage `
  --time-period Start=2026-09-01,End=2026-09-04 `
  --granularity DAILY `
  --metrics UnblendedCost `
  --group-by Type=DIMENSION,Key=SERVICE `
  --region us-east-1
```

---

# 6. Incident: SNS Subscription Was Not Confirmed

The SNS topic was successfully created.

Verification:

```powershell
aws sns get-topic-attributes `
  --topic-arn <TOPIC_ARN>
```

The result showed:

```text
SubscriptionsConfirmed: 0
```

---

## Root Cause

No subscription had been confirmed for the SNS topic.

---

## Resolution

The final documentation explicitly reports:

```text
SNS Topic: Created
Confirmed subscriptions: 0
```

The project does not claim that email alerting was successfully confirmed.

---

# 7. Incident: Configuration Recorder Verification

AWS Config was checked directly using:

```powershell
aws configservice describe-configuration-recorder-status `
  --region us-east-1
```

The final result showed:

```text
recording: true
lastStatus: SUCCESS
```

Therefore AWS Config was considered successfully operational.

---

# 8. Incident: CloudTrail Verification

CloudTrail was verified with:

```powershell
aws cloudtrail get-trail-status `
  --name nexops-cloud-security-security-trail `
  --region us-east-1
```

The final result showed:

```text
IsLogging: true
```

Therefore CloudTrail was considered operational.

---

# 9. Final Incident Summary

| Component                   | Result      |
| --------------------------- | ----------- |
| Terraform                   | Successful  |
| VPC                         | Successful  |
| CloudTrail                  | Logging     |
| VPC Flow Logs               | ACTIVE      |
| AWS Config                  | Recording   |
| CloudWatch                  | Operational |
| KMS                         | Created     |
| S3                          | Created     |
| SNS                         | Created     |
| SNS confirmed subscriptions | 0           |
| Security Hub                | Disabled    |
| GuardDuty                   | Disabled    |

---

# 10. Lessons Learned

### 1. Verify credentials separately from service availability

`aws sts get-caller-identity` confirms identity, but it does not guarantee access to every AWS service.

### 2. Do not assume every AWS security service is available

Service-specific subscription/access restrictions can exist.

### 3. Generated dependencies do not belong in Git

Terraform providers must remain inside `.terraform/`.

### 4. Cost monitoring must be part of cloud engineering

Security services and logging infrastructure can generate costs even when application compute is not running.

### 5. Evidence matters

The project was verified using AWS CLI commands and AWS Console screenshots rather than relying only on Terraform's `apply complete` message.

### 6. Honest documentation is better than false completeness

Disabled services are explicitly documented rather than presented as active.

---

# 11. Final Status

The infrastructure was successfully deployed, verified, documented and subsequently destroyed to prevent unnecessary AWS charges.

The resulting repository preserves:

* Terraform source
* Documentation
* Architecture
* Policies
* Deployment evidence
* Troubleshooting knowledge
* Incident history

without preserving live AWS resources or generated provider binaries.
