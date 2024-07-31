resource "aws_route53_record" "wc_prod_dns" {
  zone_id = var.zone_id
  name    = var.all_sub_domain_name  # Change this to your desired domain name
  type    = "A"
  alias {
    name                   = aws_lb.prod_lb.dns_name
    zone_id                = aws_lb.prod_lb.zone_id
    evaluate_target_health = true
  }
  
}


resource "aws_route53_record" "www_wc_prod_dns" {
  zone_id = var.zone_id
  name    = "www.therenhub.com"
  type    = "CNAME"
  ttl     = "300"
  records = ["therenhub.com"]
}
