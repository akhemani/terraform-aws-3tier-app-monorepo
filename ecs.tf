# resource "aws_ecs_cluster" "todo_app_cluster" {
#   name = "todo-ecs-cluster"
# }

# resource "aws_ecs_task_definition" "todo_app_task" {
#   family                   = "todo-app-task"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   execution_role_arn       = aws_iam_role.ecs_task_execution.arn
#   cpu                      = "256"
#   memory                   = "512"

#   container_definitions = jsonencode([
#     {
#       name      = "todo-app-container"
#       image     = var.app_image
#       portMappings = [
#         {
#           containerPort = 80
#           hostPort      = 80
#           protocol      = "tcp"
#         }
#       ]
#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           awslogs-group         = aws_cloudwatch_log_group.app_logs.name
#           awslogs-region        = var.aws_region
#           awslogs-stream-prefix = "todo"
#         }
#       }
#     }
#   ])
# }

# resource "aws_ecs_service" "todo_app_service" {
#   name            = "todo-app-service"
#   cluster         = aws_ecs_cluster.todo_app_cluster.id
#   task_definition = aws_ecs_task_definition.todo_app_task.arn
#   desired_count   = 2
#   launch_type     = "FARGATE"

#   network_configuration {
#     subnets         = aws_subnet.todo_private_subnet[*].id
#     security_groups = [aws_security_group.app_sg.id]
#     assign_public_ip = false
#   }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.ecs_tg.arn
#     container_name   = "todo-app-container"
#     container_port   = 80
#   }

#   depends_on = [aws_lb_listener.http]
# }

# ECS cluster
resource "aws_ecs_cluster" "app_cluster" {
  name = "todo-ecs-cluster"
}

# Task definition for Fargate
resource "aws_ecs_task_definition" "app_task" {
  family                   = "todo-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.task_cpu)
  memory                   = tostring(var.task_memory)
  execution_role_arn       = data.aws_iam_role.existing_exec_role.arn
  task_role_arn            = data.aws_iam_role.existing_exec_role.arn

  container_definitions = jsonencode([
    {
      name      = "todo-app-container",
      image     = var.app_image,
      essential = true,
      portMappings = [
        {
          containerPort = var.container_port,
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.todo_app_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        {
          name  = "DB_URL"
          value = "jdbc:postgresql://${aws_db_instance.todo_rds.address}:5432/${var.db_name}"
        },
        {
          name  = "DB_USERNAME"
          value = var.db_username
        },
        {
          name  = "DB_PASSWORD"
          value = random_password.rds_password.result
        },
        {
          name  = "SERVER_PORT"
          value = tostring(var.container_port)
        }
      ]
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "app_service" {
  name            = "todo-app-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.todo_private_subnet[*].id
    security_groups  = [aws_security_group.todo_app_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.todo_ecs_tg.arn
    container_name   = "todo-app-container"
    container_port   = var.container_port
  }

  health_check_grace_period_seconds = 120
  depends_on = [aws_lb_listener.http]
}

