output "hosted_zone" {
    value = {
        id = aws_route53_zone.app_zone.id
        name = aws_route53_zone.app_zone.name
        name_servers = aws_route53_zone.app_zone.name_servers
    }
}
