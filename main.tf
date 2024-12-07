resource "aws_vpc" "hcab_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "HcabVPC"
  }
}

resource "aws_subnet" "hcab_public_subnet" {
  vpc_id                  = aws_vpc.hcab_vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Name = "Hcab Subnet"
  }
}

resource "aws_internet_gateway" "hcab_internet_gateway" {
  vpc_id = aws_vpc.hcab_vpc.id

  tags = {
    Name = "Hcab IGW"
  }
}

resource "aws_route_table" "hcab_route_table" {
  vpc_id = aws_vpc.hcab_vpc.id

  tags = {
    Name = "Hcab RT"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.hcab_route_table.id
  destination_cidr_block = "0.0.0.0/0" # All IP addresses
  gateway_id             = aws_internet_gateway.hcab_internet_gateway.id

}

resource "aws_route_table_association" "hcab_public_assoc" {
  subnet_id      = aws_subnet.hcab_public_subnet.id
  route_table_id = aws_route_table.hcab_route_table.id

}

resource "aws_security_group" "hcab_sg" {
  name        = "hcab_sg"
  description = "HCab Security Group"
  vpc_id      = aws_vpc.hcab_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["129.0.60.43/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Hcab SG"
  }
}

resource "aws_key_pair" "hcab_key_pair" {
  key_name   = "hcab_key"
  public_key = file("~/.ssh/hcab_key.pub")

  tags = {
    Name = "Hcab Key Pair"
  }
}

resource "aws_instance" "hcab_vps" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.hcab_key_pair.id
  vpc_security_group_ids = [aws_security_group.hcab_sg.id]
  subnet_id              = aws_subnet.hcab_public_subnet.id
  user_data              = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "Hcab Terraform Server"
  }

    # provisioner "local-exec" {
    #     command = templatefile("${var.host_os}-ssh-config.tpl", {
    #         hostname = self.public_ip,
    #         user = "ubuntu",
    #         identityfile = "~/.ssh/hcab_key"
    #     })
    #     interpreter = ["Powershell", "-Command"]
    # }

}
