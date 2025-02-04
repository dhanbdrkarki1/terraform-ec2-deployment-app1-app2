####################
# AWS CodeBuild
####################

variable "create" {
  default     = false
  type        = bool
  description = "Specify whether to create resource or not"
}

variable "pipeline_type" {
  description = "Type of the pipeline. Possible values are: V1 and V2. Default value is V1."
  type        = string
  default     = "V2"
}

variable "pipeline_execution_mode" {
  description = "The method that the pipeline will use to handle multiple executions. The default mode is SUPERSEDED. "
  default     = "QUEUED"
  type        = string

  validation {
    condition = (
      contains(["SUPERSEDED", "QUEUED", "PARALLEL"], var.pipeline_execution_mode) &&
      (var.pipeline_type == "V1" && var.pipeline_execution_mode == "SUPERSEDED") ||
      (var.pipeline_type == "V2" && contains(["QUEUED", "PARALLEL"], var.pipeline_execution_mode))
    )
    error_message = "The pipeline_execution_mode must be 'SUPERSEDED' for V1 pipelines and can be 'QUEUED' or 'PARALLEL' for V2 pipelines."
  }
}

# Github Code
variable "source_repo_id" {
  description = "Source repo ID of the Github repository"
  type        = string
  default     = null
}

variable "source_repo_branch" {
  description = "Default branch in the Source repo for which CodePipeline needs to be configured"
  type        = string
  default     = null
}

variable "codestarconnection_name" {
  description = "The name of the connection to be created"
  type        = string
  default     = null
}

#CodeBuild
variable "codebuild_project_name" {
  description = "The name of the CodeBuild project"
  type        = string
}

variable "codebuild_arn" {
  description = "The ARN of the CodeBuild project."
  type        = string
}


# Amazon ECS Standalone Deployment
variable "ecs_cluster" {
  description = "The name of the ECS cluster where to deploy"
  type        = string
  default     = null
}

variable "ecs_service" {
  description = "The name of the ECS service to deploy"
  type        = string
  default     = null
}

variable "image_definition_file_name" {
  description = "The name of the ECS service to deploy"
  type        = string
  default     = "imagedefinitions.json"
}

variable "deployment_timeout" {
  description = "The Amazon ECS deployment action timeout in minutes. "
  default     = 15
  type        = number
}

# Tags

variable "custom_tags" {
  description = "Custom tags to set on all the resources."
  type        = map(string)
  default     = {}
}
