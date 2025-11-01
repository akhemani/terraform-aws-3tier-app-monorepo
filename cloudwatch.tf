resource "aws_cloudwatch_log_group" "todo_app_logs" {
  name              = "/ecs/todo-app"
  retention_in_days = 14

  tags = {
    Name = "todo-app-logs"
  }
}
