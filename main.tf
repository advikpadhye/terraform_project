provider "aws"  {

 region = "us-east-1"


resource "aws_instance" "web_instance" {
 ami = "ami-005e54dee72cc1d00"
 instance_type = "t2.micro"
 availability_zone = "us-east-1a"

 network_interface {
   network_interface_id = aws_netwrok_interface.test_interface.id
   device_index = 0
 tags = {
    Name = "rod_tag"
   }
}



resource "aws_vpc" "my_vpc" {

 cidr_block = "10.0.0.0/16"
 availability_zone = "us-east-1a"
 tags = {
   Name = "my_vpc"
   }
}



resource "aws_subnet" "my_subnet"{

 vpc.id = aws_vpc.my_vpc.id
 cidr_block = "10.0.10.0/24"
 availability_zone = "us-east-1a"

 tags = {
   Name = prod_subnet
  }
}

resource "aws_network_interface" "test_interface"
 subnet.id = aws_subnet.my_subnet.id
 private_ip = ["10.0.10.100"]


 tags = {
   Name = "network_interface"
  }

}

