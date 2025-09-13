output "alb_url" { value = aws_lb.app_lb.dns_name }
output "ecr_repo_url" { value = aws_ecr_repository.app.repository_url }