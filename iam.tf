# Lookup existing execution role by name
data "aws_iam_role" "existing_exec_role" {
  name = var.existing_execution_role_name
}

# Optionally create a Task Role for the container to assume (if your app needs AWS access)
resource "aws_iam_role" "todo_task_role" {
  name = "todo-ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}
