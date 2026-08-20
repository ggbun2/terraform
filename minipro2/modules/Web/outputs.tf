output "alb_dns_name" {
  value       = aws_lb.alb.dns_name
  description = "ALB DNS name to access the web service"
}