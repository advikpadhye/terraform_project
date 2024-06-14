provider "aws"  {

 region = "us-east-1"
 access_key = "AKIA5IHBEWUG4TEZ3BDC"
 secret_key = "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"
}

#create the VPC resource

resource "aws_vpc" "my_vpc" {

 cidr_block = "10.0.0.0/16"
 enable_dns_support = true
 enable_dns_hostnames = true

 tags = {
   Name = "my_vpc"
   }
}




#CREATE PUBLIC SUBNET FOR THE EC2 INSTANCE

resource "aws_subnet" "my_subnet" {
 vpc_id = aws_vpc.my_vpc.id
 cidr_block = "10.0.10.0/24"
 availability_zone = "us-east-1a"
 map_public_ip_on_launch = "true"

 tags = {
   name = "prod_subnet"

  }

}

#CREATE AN INTERNET GATEWAY FOR THE EC2 INSTANCE

resource "aws_internet_gateway" "prod_igw" {
 vpc_id = aws_vpc.my_vpc.id

 tags = {
    Name =  "prod_igw_tag"
  }

}


#CREATE ROUTE TABLE FOR THE EC2 INSTANCE

resource "aws_route_table" "prod_rt" {
 vpc_id = aws_vpc.my_vpc.id

 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod_igw.id
  }

 tags = {
     Name = "prod_route_table"

  }
}




#ASSOCIATE SUBNET TO THE ROUTE TABLE:

resource "aws_route_table_association" "prod_rt_association" {
 subnet_id = aws_subnet.my_subnet.id
 route_table_id = aws_route_table.prod_rt.id

}


#CREATE A SECURITY GROUP  FOR THE EC2 INSTANCE:

resource "aws_security_group" "prod_sg" {
 vpc_id = aws_vpc.my_vpc.id

 ingress {

   from_port = 80
   to_port = 80
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
   from_port = 22
   to_port = 22
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
   from_port = 443
   to_port = 443
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
   from_port = 8080
   to_port = 8080
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]

   }

 ingress {
   from_port = 9000
   to_port = 9000
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
  }

 egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "prod_sg"
  }
}


#CREATING THE NETWORK INTERFACE FIR THE EC2 INSTANCE:

resource "aws_network_interface" "prod_interface" {
 subnet_id = aws_subnet.my_subnet.id
 private_ips = ["10.0.10.100"]

 tags = {
    Name = "prod_network_interface"
  }
}






#CREATE AN EC2 INSTANCE:

resource "aws_instance" "web_instance" {
 ami = "ami-0c55b159cbfafe1f0"
 instance_type = "t2.small"
 availability_zone = "us-east-1a"
 subnet_id = aws_subnet.my_subnet.id
 vpc_security_group_ids = [aws_security_group.prod_sg.id]

 network_interface {
   network_interface_id = aws_network_interface.prod_interface.id
   device_index = 0
  }

 credit_specification {
    cpu_credits = "unlimited"
  }

}


