#---------------------
#     AWS CodeDeploy 
#---------------------
locals {
  name_prefix = lower("${var.custom_tags["Project"] != "" ? var.custom_tags["Project"] : "default-project"}-${var.custom_tags["Environment"] != "" ? var.custom_tags["Environment"] : "default-env"}-${var.name}")
}

# App defintion
resource "aws_codedeploy_app" "this" {
  count            = var.create ? 1 : 0
  name             = local.name_prefix
  compute_platform = var.compute_platform
  tags = merge(
    { Name = "${local.name_prefix}" },
    var.custom_tags
  )
}

# CodeDeploy Deployment Group
resource "aws_codedeploy_deployment_group" "this" {
  count                  = var.create ? 1 : 0
  app_name               = aws_codedeploy_app.this[0].name
  deployment_config_name = var.deployment_config_name
  deployment_group_name  = "${local.name_prefix}-dg"
  service_role_arn       = aws_iam_role.codedeploy_role[0].arn

  ecs_service {
    cluster_name = var.ecs_cluster
    service_name = var.ecs_service
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [
          var.alb_listener_arn
        ]
      }

      target_group {
        name = var.target_group_blue
      }

      target_group {
        name = var.target_group_green
      }
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }


  #   trigger_configuration {
  #     trigger_events = [
  #       "DeploymentSuccess",
  #       "DeploymentFailure",
  #     ]

  #     trigger_name       = var.trigger_name
  #     trigger_target_arn = var.sns_topic_arn
  #   }

  lifecycle {
    ignore_changes = [blue_green_deployment_config]
  }

  tags = merge(
    { Name = "${local.name_prefix}-dg" },
    var.custom_tags
  )
}
