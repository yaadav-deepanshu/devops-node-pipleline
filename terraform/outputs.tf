# Output the Jenkins public IP
output "jenkins_public_ip" {
  value = aws_instance.jenkins_server.public_ip
}

# Output the ALB DNS name
output "alb_dns_name" {
  value = aws_lb.nodejs_logo_alb.dns_name
}

# Output the ECR repository URL
output "ecr_repository_url" {
  value = aws_ecr_repository.nodejs_logo_server.repository_url
}