locals {
  target_groups = ["primary"]
}
resource "aws_security_group" "alb" {
    name = "${var.service_name}"
    vpc_id = aws_vpc.qassie-vpc.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
 tags = {
    Name = "${var.service_name}-alb"
  }
}
resource "aws_lb" "alb" {
    name               = "${var.service_name}-service-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public-sub-1.id,aws_subnet.public-sub-2.id]

  tags = {
    Name = "${var.service_name}-service-alb"
  }
  
}
resource "aws_lb_target_group" "lb-target" {

    name = "${var.service_name}-tg"
    port        = 8080
    protocol    = "HTTP"
    vpc_id      = aws_vpc.qassie-vpc.id
    target_type = "ip"

    health_check {
        path = "/"
       // port = "traffic port"
        //matcher = "200-300"
    }
}
resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-target.arn
  }
}

resource "aws_lb_listener_rule" "listener" {
  listener_arn = aws_lb_listener.lb-listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-target.arn
  }

  condition {
    field  = "path-pattern"
    values = ["/*"]
  }


}
