#
#Load Balancer Security Group
resource "aws_security_group" "lbsg" {
  name        = "techno-sg-lb"
  description = "Allow HTTP & HTTPS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.techno-keefa.id

  tags = {
    Name = "techno-sg-lb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-http" {
  security_group_id = aws_security_group.lbsg.id
  cidr_ipv4         = aws_vpc.techno-keefa.cidr_block
  from_port         = 80
  ip_protocol       = "TCP"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow-https" {
  security_group_id = aws_security_group.lbsg.id
  cidr_ipv4         = aws_vpc.techno-keefa.cidr_block
  from_port         = 443
  ip_protocol       = "TCP"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow-outbound1" {
  security_group_id = aws_security_group.lbsg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#
#APP Security Group
resource "aws_security_group" "appsg" {
  name        = "techno-sg-apps"
  description = "Allow All traffic inbound and all outbound traffic"
  vpc_id      = aws_vpc.techno-keefa.id

  tags = {
    Name = "techno-sg-apps"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-all-traffic" {
  security_group_id = aws_security_group.appsg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 2000
  ip_protocol       = "TCP"
  to_port           = 2000
}

resource "aws_vpc_security_group_egress_rule" "allow-outbound2" {
  security_group_id = aws_security_group.appsg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}