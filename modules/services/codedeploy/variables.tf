variable "create" {
  default     = false
  type        = bool
  description = "Specify whether to create resource or not"
}

# Application
variable "name" {
  description = "The name of the CodeDeploy application"
  type        = string
}

variable "compute_platform" {
  type        = string
  default     = "Server"
  description = "The compute platform can either be ECS, Lambda, or Server."
}

# Deployment Settings
variable "deployment_config_name" {
  type        = string
  default     = "CodeDeployDefault.ECSAllAtOnce"
  description = "The name of the group's deployment config."

}

# Environment
variable "ecs_cluster" {
  description = "The name of the ECS cluster where to deploy"
  type        = string
}

variable "ecs_service" {
  description = "The name of the ECS service to deploy"
  type        = string
}

# Load Balancers
variable "alb_listener_arn" {
  description = "The ARN of the ALB listener for production"
  type        = string
}

variable "target_group_blue" {
  description = "The Target group name for the Blue part"
  type        = string
}

variable "target_group_green" {
  description = "The Target group name for the Green part"
  type        = string
}

# Tags
variable "custom_tags" {
  description = "Custom tags to be applied to the codebuild project"
  type        = map(string)
  default     = {}
}
