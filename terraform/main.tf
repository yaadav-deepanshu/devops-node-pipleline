# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "${var.app_name}-alb-sg"
  description = "Allow HTTP inbound to ALB"
  vpc_id      = "vpc-083056b51a6415ac3"  

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Target Security Group (for ECS tasks)
resource "aws_security_group" "app_sg" {
  name        = "${var.app_name}-sg"
  description = "Allow traffic from ALB to app on 3000"
  vpc_id      = "vpc-083056b51a6415ac3"  # Your VPC ID

  ingress {
    description     = "From ALB to app"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # Allow from ALB SG only
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Update ALB to use new SG
resource "aws_lb" "app_lb" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]  
  subnets            = ["subnet-003cae0e4cde74f26", "subnet-048db320bb9d1d065"]
}

# Update ECS service to use new SG
resource "aws_ecs_service" "app_service" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = ["subnet-003cae0e4cde74f26", "subnet-048db320bb9d1d065"]
    security_groups = [aws_security_group.app_sg.id]  
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "${var.app_name}-container"
    container_port   = 3000
  }
}