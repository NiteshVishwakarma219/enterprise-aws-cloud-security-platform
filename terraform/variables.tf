variable "project_name" {
  description = "Project name"
  type        = string
  default     = "nexops-cloud-security"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "security"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the security VPC"
  type        = string
  default     = "10.60.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones used by the VPC"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "security_alert_email" {
  description = "Optional email address for security alerts"
  type        = string
  default     = ""
}

variable "enable_guardduty" {
  description = "Enable GuardDuty"
  type        = bool
  default     = false
}

variable "enable_securityhub" {
  description = "Enable Security Hub"
  type        = bool
  default     = false
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "cloudtrail_retention_days" {
  description = "CloudTrail CloudWatch log retention"
  type        = number
  default     = 30
}

variable "security_log_retention_days" {
  description = "Security log retention"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional project tags"
  type        = map(string)
  default     = {}
}