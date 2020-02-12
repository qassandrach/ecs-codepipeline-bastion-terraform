resource "aws_ecs_service" "service" {
    name = var.service_name
    task_definition = aws_ecs_task_definition.taskdef.id
    cluster         = aws_ecs_cluster.cluster.arn

    load_balancer {
        target_group_arn = "${aws_lb_target_group.lb-target.arn}"
        container_name = "${var.service_name}"
        container_port = "${var.container_port}"
    }

    launch_type = "EC2"
    desired_count = 1

    depends_on = [aws_lb_listener.lb-listener]
    network_configuration {
    subnets         = [aws_subnet.private-sub-1.id,aws_subnet.private-sub-2.id]
    security_groups = [aws_security_group.ecs.id]
    
  }
}
