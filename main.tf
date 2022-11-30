locals {


  common_tags = {
    Environment = var.environment
    owner       = "meraj_terr_nc_01"
    Application = "RTapp-nc-01"
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    local.common_tags, {
      Name = "RTapp-nc-01-${var.environment}-vpc"
    }

  )
}


resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags, {
      Name = "RTapp-nc-01-${var.environment}-vpc"
    }

  )

}



##Public subnet 1
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.1.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-1a"

  tags = merge(
    local.common_tags, {
      Name = "RTapp-nc-01-${var.environment}-vpc"
    }

  )
}

##Public subnet 2
resource "aws_subnet" "name2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-1b"

  tags = merge(
    local.common_tags, {
      Name = "RTapp-nc-01-${var.environment}-vpc"
    }

  )
}


###########route table attaching to vpc
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags, {
      Name = "RTapp-nc-01-${var.environment}-vpc"
    }

  )
}



###########creating/defining routes for public subnet route table
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.public.id
}


##########route table association to public subnet1
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


##########route table association to public subnet2
resource "aws_route_table_association" "name2" {
  subnet_id      = aws_subnet.name2.id
  route_table_id = aws_route_table.public.id
}


##############creating elastic ip for nat gateway
resource "aws_eip" "public" {
  vpc = true

  tags = merge(
    local.common_tags, {
      Name = "RTapp-nc-01-${var.environment}-nat-eip"
    }

  )

}




#######################creating nat gateway
resource "aws_nat_gateway" "public" {
  allocation_id = aws_eip.public.id
  subnet_id     = aws_subnet.public.id

  tags = merge(
    local.common_tags, {
      Name = "RTapp-nc-01-${var.environment}-nat-gateway"
    }

  )

}


##############creating private subnet1
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "us-west-1a"

  tags = merge(
    local.common_tags, {
      Name = "RTapp-nc-01-private_subnet1-${var.environment}-vpc"
    }

  )
}

###########route table attaching to vpc
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags, {
      Name = "RTapp-nc-01-private_subnet-${var.environment}-vpc"
    }

  )
}



###########creating/defining routes for private subnet route table
resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public.id
}


##########route table association to private subnet1
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}






##############creating private subnet2
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.1.3.0/24"
  availability_zone = "us-west-1b"

  tags = merge(
    local.common_tags, {
      Name = "RTapp-nc-01-private2_subnet-${var.environment}-vpc"
    }

  )
}








##########route table association to private subnet2
resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}



###################creatin ec2 instance in public subnet(2)

resource "aws_instance" "inst1" {
  ami           = "ami-03f6d497fceb40069"
  instance_type = "t2.micro"
  ebs_block_device {

    volume_size = "20"
    device_name = "/dev/sda1"



  }

  subnet_id = aws_subnet.name2.id
  tags = merge(
    local.common_tags, {
      Name = "RTapp-nc-01-inst1_subnet2-${var.environment}-inst1"
    }
  )

}











####################################creating application load balancer



resource "aws_lb" "loadbalancer" {
  name               = "loadbalancer"
  internal           = false
  load_balancer_type = "application"
  subnet_mapping {
    subnet_id = aws_subnet.private1.id
  }
  subnet_mapping {
    subnet_id = aws_subnet.private2.id
  }
}







##########################################creating launch template

resource "aws_launch_template" "foobar" {
  name_prefix   = "foobar"
  image_id      = "ami-029465c1f346dd34f"
  instance_type = "t2.micro"




}


##############################################creating target group for alb

resource "aws_lb_target_group" "lb-target" {

  name     = "lb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id


}



####################################creating autoscaling group
resource "aws_autoscaling_group" "asg" {
  max_size = 6
  min_size = 2


  vpc_zone_identifier = [aws_subnet.private1.id, aws_subnet.private2.id]
  target_group_arns   = [aws_lb_target_group.lb-target.arn]

  launch_template {
    id      = aws_launch_template.foobar.id
    version = "$Latest"
  }



}













##############################################CREATING S3 BUCKET and lifecycle policies









resource "aws_s3_bucket" "mei-nc-s3-bucket" {
  bucket = "mei-nc-s3-bucket"
  acl    = "private"

  lifecycle_rule {
    id      = "images"
    prefix  = "images"
    enabled = true



    tags = {
      rule = "images"

    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }


  }

  lifecycle_rule {
    id      = "Logs"
    prefix  = "logs"
    enabled = true

    expiration {
      days = 90
    }
  }
}

