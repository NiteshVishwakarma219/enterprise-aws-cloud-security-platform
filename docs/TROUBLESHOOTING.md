# Troubleshooting — Enterprise AWS Cloud Security Platform

## 1. Terraform Initialization

### Problem

```text
terraform init
```

fails while downloading providers.

### Solution

Verify internet connectivity and retry:

```powershell
terraform init
```

If provider installation is corrupted:

```powershell
Remove-Item -Recurse -Force .terraform
terraform init
```

Do not commit `.terraform/`.

---

# 2. Terraform Validation Failure

Run:

```powershell
terraform validate
```

If validation fails:

```powershell
terraform fmt -recursive
terraform validate
```

Read the exact resource and line reported by Terraform.

---

# 3. AWS Credentials

Verify:

```powershell
aws sts get-caller-identity
```

If this fails, configure AWS CLI credentials before running Terraform.

Example:

```powershell
aws configure
```

---

# 4. Wrong AWS Region

The project was deployed in:

```text
us-east-1
```

Explicitly specify the region when troubleshooting:

```powershell
aws ec2 describe-vpcs --region us-east-1
```

---

# 5. Security Hub SubscriptionRequiredException

### Error

```text
SubscriptionRequiredException:
The AWS Access Key Id needs a subscription for the service
```

### Check

```powershell
aws securityhub describe-hub --region us-east-1
```

### Important

Do not repeatedly retry Terraform.

Verify whether Security Hub is available for the account.

For this project, the final status was:

```text
Security Hub: disabled
```

---

# 6. GuardDuty SubscriptionRequiredException

Check:

```powershell
aws guardduty list-detectors --region us-east-1
```

If the same subscription error appears, the account/service access is unavailable.

For this project:

```text
GuardDuty: disabled
```

---

# 7. CloudTrail Is Not Logging

Check:

```powershell
aws cloudtrail get-trail-status `
  --name nexops-cloud-security-security-trail `
  --region us-east-1
```

Look for:

```text
IsLogging: true
```

If false, inspect:

```powershell
aws cloudtrail describe-trails --region us-east-1
```

---

# 8. VPC Flow Logs Not Active

Run:

```powershell
aws ec2 describe-flow-logs `
  --region us-east-1 `
  --filter "Name=resource-id,Values=<VPC_ID>"
```

Expected:

```text
FlowLogStatus: ACTIVE
```

If inactive, inspect the Terraform resource:

```text
aws_flow_log.security
```

and the IAM role/policy used to deliver logs.

---

# 9. AWS Config Not Recording

Check:

```powershell
aws configservice describe-configuration-recorder-status `
  --region us-east-1
```

Expected:

```text
recording: true
lastStatus: SUCCESS
```

If not recording, inspect:

```powershell
aws configservice describe-configuration-recorders `
  --region us-east-1
```

Check the Config IAM role and delivery channel.

---

# 10. CloudWatch Logs Missing

List log groups:

```powershell
aws logs describe-log-groups `
  --region us-east-1
```

Search for:

```text
nexops-cloud-security
```

Expected groups include:

```text
/aws/vpc/nexops-cloud-security-security/flow-logs
/nexops/nexops-cloud-security-security/cloudtrail
/nexops/nexops-cloud-security-security/security
```

---

# 11. SNS Subscription Shows Zero

Check:

```powershell
aws sns get-topic-attributes `
  --topic-arn <TOPIC_ARN>
```

If:

```text
SubscriptionsConfirmed: 0
```

there is no confirmed subscription.

The SNS topic itself may still be healthy.

---

# 12. Cost Explorer GroupBy Error

### Error

```text
Group Definition is invalid.
Both type and key need to be set to a non-empty value.
```

### Incorrect

```text
--group-by Type=SERVICE
```

### Correct

```text
--group-by Type=DIMENSION,Key=SERVICE
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

# 13. Terraform State Lock

If Terraform reports a state lock:

```text
Error acquiring the state lock
```

inspect the lock information first.

Only use:

```powershell
terraform force-unlock <LOCK_ID>
```

when you are certain no Terraform operation is currently running.

Never blindly delete a state lock.

---

# 14. Resource Already Exists

If Terraform reports:

```text
already exists
```

the resource may exist outside Terraform state.

First inspect:

```powershell
terraform state list
```

Then determine whether the existing AWS resource should be imported or removed.

Do not immediately delete resources without understanding their ownership.

---

# 15. Terraform Drift

Check:

```powershell
terraform plan
```

Terraform will compare the configuration with the actual AWS infrastructure.

If the infrastructure was manually modified, Terraform may attempt to restore the declared configuration.

---

# 16. Large File Rejected by GitHub

### Error

```text
GH001: Large files detected
```

Especially:

```text
terraform/.terraform/providers/...
```

### Cause

Terraform provider binaries were committed.

### Solution

`.gitignore` must contain:

```text
.terraform/
```

Also exclude:

```text
*.tfstate
*.tfstate.*
*.tfvars
```

Provider binaries should never be uploaded to GitHub.

---

# 17. Terraform State Accidentally Committed

Never publish:

```text
terraform.tfstate
terraform.tfstate.backup
```

Terraform state can contain sensitive infrastructure metadata.

Remove it from Git and add:

```text
*.tfstate
*.tfstate.*
```

to `.gitignore`.

---

# 18. AWS CLI Authentication Works but a Service Fails

This distinction is important.

If:

```powershell
aws sts get-caller-identity
```

works but:

```powershell
aws securityhub describe-hub
```

fails with:

```text
SubscriptionRequiredException
```

then the credentials are valid.

The issue is specific to service availability/subscription/access.

---

# 19. Destroy Failure

Run:

```powershell
terraform plan -destroy
```

before:

```powershell
terraform destroy
```

If a resource cannot be destroyed, identify dependencies first.

Examples include:

* S3 buckets containing objects
* Security groups still referenced
* IAM roles still attached
* CloudTrail dependencies
* Log groups
* KMS dependencies

---

# 20. Final Verification After Destroy

Run:

```powershell
terraform state list
```

The Terraform-managed resource list should be empty after successful destruction.

Also check important AWS resources manually when appropriate:

```powershell
aws ec2 describe-vpcs --region us-east-1
```

```powershell
aws cloudtrail describe-trails --region us-east-1
```

```powershell
aws logs describe-log-groups --region us-east-1
```

---

# 21. Troubleshooting Philosophy

The recommended workflow is:

```text
1. Read the exact error
        ↓
2. Verify AWS identity
        ↓
3. Verify region
        ↓
4. Check the AWS resource directly
        ↓
5. Compare with Terraform state
        ↓
6. Check Terraform configuration
        ↓
7. Apply the smallest safe fix
        ↓
8. Verify again
        ↓
9. Document the result
```

Avoid repeatedly running `terraform apply` without understanding the error.
