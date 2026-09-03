# Cost Control — Enterprise AWS Cloud Security Platform

## 1. Purpose

AWS security and observability services are powerful, but several services can generate charges.

This project therefore follows a **deploy → verify → document → destroy** lifecycle.

```text
Terraform Apply
      |
      v
Verification
      |
      v
Screenshots / Evidence
      |
      v
Documentation
      |
      v
Terraform Destroy
```

---

# 2. Cost-Aware Design

The project is intended primarily for:

* Learning
* Portfolio demonstration
* Cloud Security practice
* Terraform practice
* AWS architecture interviews

It is not intended to run continuously as a production SOC.

---

# 3. Potential Cost Sources

Depending on configuration and AWS pricing, monitor:

### AWS Config

Configuration recording and configuration items may generate charges.

### CloudWatch

Potential charges include:

* Log ingestion
* Log storage
* Metrics
* Alarms
* API usage

### CloudTrail

Management events and especially additional event types/data events can affect cost.

### VPC Flow Logs

Flow logs generate CloudWatch log ingestion/storage costs.

### S3

Potential charges include:

* Storage
* Requests
* Data retrieval
* Data transfer

### KMS

KMS keys and usage can have associated charges depending on usage.

### SNS

Notifications are generally inexpensive, but message volume and delivery type can affect cost.

### NAT Gateway

If included in an AWS architecture, NAT Gateway is a major cost consideration because it has hourly and data-processing charges.

---

# 4. CloudWatch Log Retention

The project used:

```text
30 days
```

for relevant CloudWatch log groups.

This prevents unlimited accumulation of log storage.

Verified groups:

```text
/aws/vpc/nexops-cloud-security-security/flow-logs
/nexops/nexops-cloud-security-security/cloudtrail
/nexops/nexops-cloud-security-security/security
```

---

# 5. Cost Explorer

AWS Cost Explorer can be queried through the CLI.

Example:

```powershell
aws ce get-cost-and-usage `
  --time-period Start=2026-09-01,End=2026-09-04 `
  --granularity DAILY `
  --metrics UnblendedCost `
  --region us-east-1
```

To group costs by service:

```powershell
aws ce get-cost-and-usage `
  --time-period Start=2026-09-01,End=2026-09-04 `
  --granularity DAILY `
  --metrics UnblendedCost `
  --group-by Type=DIMENSION,Key=SERVICE `
  --region us-east-1
```

---

# 6. Why the First Cost Query Failed

The initial query attempted:

```text
Type=SERVICE
```

AWS Cost Explorer requires both:

```text
Type
Key
```

for a dimension grouping.

The corrected form is:

```text
Type=DIMENSION,Key=SERVICE
```

---

# 7. Billing Verification

Before destroying the environment, review:

* AWS Billing
* Cost Explorer
* Service-level usage
* S3 storage
* CloudWatch Logs
* AWS Config
* VPC Flow Logs
* KMS
* CloudTrail

This confirms that no unexpected service remains active.

---

# 8. Destroy After Testing

When the project is no longer needed:

```powershell
terraform destroy
```

Review the resources and confirm:

```text
yes
```

Terraform then removes the infrastructure under its management.

---

# 9. Verify Destruction

Run:

```powershell
terraform state list
```

The state should no longer contain the destroyed infrastructure resources.

Also verify AWS resources where appropriate.

Example:

```powershell
aws ec2 describe-vpcs `
  --region us-east-1 `
  --filters "Name=tag:Project,Values=nexops-cloud-security"
```

---

# 10. Git Repository Does Not Contain AWS Infrastructure State

The GitHub repository stores:

* Terraform source code
* Documentation
* Screenshots
* Architecture
* Policies

It does not store:

```text
.terraform/
*.tfstate
AWS credentials
private keys
```

This prevents unnecessary repository bloat and reduces security risk.

---

# 11. Recommended Portfolio Workflow

For a portfolio project:

```text
1. terraform init
2. terraform validate
3. terraform plan
4. terraform apply
5. Verify AWS services
6. Capture screenshots
7. Update documentation
8. Check Cost Explorer
9. terraform destroy
10. Push source + evidence to GitHub
```

This demonstrates both technical capability and responsible cloud-cost management.

---

# 12. Cost-Control Principle

The most important rule is:

> **Do not leave cloud infrastructure running merely because it looks good in a portfolio.**

Screenshots and documentation preserve the evidence while Terraform preserves the reproducibility.

The AWS resources themselves do not need to remain active indefinitely.

---

# 13. Final Project State

The project was deployed and verified, evidence was captured, and the infrastructure was subsequently destroyed to avoid unnecessary ongoing AWS charges.

The GitHub repository therefore acts as the permanent portfolio artifact.
