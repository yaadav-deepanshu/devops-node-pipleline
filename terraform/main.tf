# Creating a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "nodejs-logo-server-vpc"
  }
}

# Creating public subnets
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.subnet_cidr_a
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "nodejs-logo-server-subnet-a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.subnet_cidr_b
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true
  tags = {
    Name = "nodejs-logo-server-subnet-b"
  }
}

# Creating an internet gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "nodejs-logo-server-igw"
  }
}

# Creating a route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }
  tags = {
    Name = "nodejs-logo-server-route-table"
  }
}

# Associating the route table with subnets
resource "aws_route_table_association" "public_subnet_a_association" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_b_association" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

# Creating a security group for Jenkins
resource "aws_security_group" "jenkins_sg" {
  vpc_id = aws_vpc.main_vpc.id
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "nodejs-logo-server-jenkins-sg"
  }
}

# Creating an IAM role for Jenkins EC2 instance
resource "aws_iam_role" "jenkins_role" {
  name = "nodejs-logo-server-jenkins-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Name = "nodejs-logo-server-jenkins-role"
  }
}

# Attaching policies to the Jenkins IAM role
resource "aws_iam_role_policy_attachment" "jenkins_ecr_policy" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "jenkins_ecs_policy" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "nodejs-logo-server-jenkins-profile"
  role = aws_iam_role.jenkins_role.name
}

# Creating an EC2 instance for Jenkins
resource "aws_instance" "jenkins_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet_a.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.jenkins_profile.name
  user_data              = <<EOF
#!/bin/bash
# Redirect output to a log file for debugging
exec > /var/log/user-data.log 2>&1

# Update package list
apt update -y

# Install OpenJDK 17
apt install -y openjdk-17-jdk

# Install unzip
apt install -y unzip

# Install Jenkins with the correct GPG key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | gpg --dearmor -o /usr/share/keyrings/jenkins-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list
apt update -y
apt install -y jenkins

# Configure Jenkins Java options
echo "JAVA_ARGS=\"-Xmx256m -Xms128m\"" >> /etc/default/jenkins

# Start and enable Jenkins
systemctl start jenkins
systemctl enable jenkins

# Install Docker
apt install -y docker.io
usermod -aG docker jenkins
systemctl restart docker

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -f awscliv2.zip

# Restart Jenkins to apply group changes
systemctl restart jenkins

# Log completion
echo "User data script completed" >> /var/log/user-data.log
EOF
  tags = {
    Name = "nodejs-logo-server-jenkins"
  }
}

# Creating an ECR repository
resource "aws_ecr_repository" "nodejs_logo_server" {
  name = "nodejs-logo-server"
  tags = {
    Name = "nodejs-logo-server-ecr"
  }
}

# Creating an ECS cluster
resource "aws_ecs_cluster" "nodejs_logo_cluster" {
  name = "nodejs-logo-server-cluster"
  tags = {
    Name = "nodejs-logo-server-cluster"
  }
}

# Creating a security group for ECS
resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.main_vpc.id
  ingress {
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
  tags = {
    Name = "nodejs-logo-server-ecs-sg"
  }
}

# Creating an ECS task definition
resource "aws_ecs_task_definition" "nodejs_logo_task" {
  family                   = "nodejs-logo-server-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = jsonencode([
    {
      name      = "nodejs-logo-server"
      image     = "${aws_ecr_repository.nodejs_logo_server.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
  tags = {
    Name = "nodejs-logo-server-task"
  }
}

# Creating an ECS service
resource "aws_ecs_service" "nodejs_logo_service" {
  name            = "nodejs-logo-server-service"
  cluster         = aws_ecs_cluster.nodejs_logo_cluster.id
  task_definition = aws_ecs_task_definition.nodejs_logo_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.nodejs_logo_tg.arn
    container_name   = "nodejs-logo-server"
    container_port   = 80
  }
  depends_on = [aws_lb_listener.http]
  tags = {
    Name = "nodejs-logo-server-service"
  }
}

# Creating an IAM role for ECS task execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "nodejs-logo-server-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Name = "nodejs-logo-server-ecs-task-execution-role"
  }
}

# Attaching the ECS task execution policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Creating an Application Load Balancer
resource "aws_lb" "nodejs_logo_alb" {
  name               = "nodejs-logo-server-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_sg.id]
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
  tags = {
    Name = "nodejs-logo-server-alb"
  }
}

# Creating a target group for the ALB
resource "aws_lb_target_group" "nodejs_logo_tg" {
  name        = "nodejs-logo-server-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main_vpc.id
  target_type = "ip"
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = {
    Name = "nodejs-logo-server-tg"
  }
}

# Creating a listener for the ALB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.nodejs_logo_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nodejs_logo_tg.arn
  }
  tags = {
    Name = "nodejs-logo-server-listener"
  }
}