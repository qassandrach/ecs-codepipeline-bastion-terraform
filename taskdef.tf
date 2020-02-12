resource "aws_ecs_task_definition" "taskdef" {
    family = var.service_name
    execution_role_arn = aws_iam_role.execution-role.arn
    task_role_arn = aws_iam_role.task-role.arn
    network_mode = "awsvpc"
    requires_compatibilities = ["EC2"]
    container_definitions = <<DEFINITION
    [
        {
            "portMappings":[
                {
                    "hostPort":${var.container_port} ,
                    "protocol":"tcp",
                    "containerPort":${var.container_port}
                }
            ],
            "environment":[
                {
                    "name":"PORT",
                    "value":"${var.container_port}"
                },
                {
                    "name":"APP_NAME",
                    "value":"${var.service_name}"
                }
            ],
            "memoryReservation" : ${var.memory_reservation},
            "image":"${data.aws_ecr_repository.ecr-repo.repository_url}:latest",
            "name": "${var.service_name}"
        }
    ]
    DEFINITION
}
