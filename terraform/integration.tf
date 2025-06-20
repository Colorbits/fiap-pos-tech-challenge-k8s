resource "aws_security_group" "vpc_link" {
  name   = "vpc_link"
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_apigatewayv2_vpc_link" "eks" {
  name               = "eks"
  security_group_ids = [aws_security_group.vpc_link.id]
  subnet_ids = [
    aws_subnet.private_zone1.id,
    aws_subnet.private_zone2.id
  ]
}

resource "aws_apigatewayv2_integration" "eks" {
  api_id = aws_apigatewayv2_api.main.id
  integration_uri = "arn:aws:elasticloadbalancing:us-east-2:324037286877:listener/net/k8s-fiap-svcapire-5755988920/7028aefb8d6e7c35/4bcb34a4308ca442"  
  integration_type = "HTTP_PROXY"
  integration_method = "ANY"
  connection_type = "VPC_LINK"
  connection_id = aws_apigatewayv2_vpc_link.eks.id
}

resource "aws_apigatewayv2_route" "get_echo" {
  api_id = aws_apigatewayv2_api.main.id

  route_key = "ANY /{proxy+}"
  target = "integrations/${aws_apigatewayv2_integration.eks.id}"
}

output "hello_base_url" {
  value = "${aws_apigatewayv2_stage.dev.invoke_url}"
}