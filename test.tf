provider "aws" {
    region = "${var.AWS_REGION}"
}

terraform {
  backend "s3" {
   bucket = "terraform-backupstate"
   key = "naren/key"
  }
}
variable "AWS_REGION" {
	default = "ap-south-1"
}

variable "AMIS" {
    type = "map"
	default = {
	  ap-south-1 = "ami-00da2ccc1da7c5139" 
	 }
}

variable "PATH_TO_PUBLIC_KEY" {
   default ="mynewkey.pub"
}

variable "PATH_TO_PRIVATE_KEY" {
   default = "mynewkey"
}

variable "INSTANCE_USERNAME" {
   default = "centos"
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"	
	instance_tenancy = "default"
	enable_dns_support = "true" 
	enable_dns_hostnames = "true"
        enable_classiclink = "false"
	tags = {
	    Name = "main"
	}
}

resource "aws_subnet" "main-public-1" {
    vpc_id = "${aws_vpc.main.id}"
	cidr_block = "10.0.1.0/24" 
	map_public_ip_on_launch = "true" 
	availability_zone = "ap-south-1a"
	
	tags = {
	   Name = "main-public-1"
	}
}

resource "aws_subnet" "main-public-2" {
	vpc_id = "${aws_vpc.main.id}"
	cidr_block = "10.0.2.0/24"
	map_public_ip_on_launch = "true"
	availability_zone = "ap-south-1b"
	
	tags = {
	   Name = "main-public-2"
	}
}

resource "aws_subnet" "main-public-3" {
	vpc_id = "${aws_vpc.main.id}"
	cidr_block = "10.0.3.0/24"
	map_public_ip_on_launch = "true"
	availability_zone = "ap-south-1c"
	
	tags = {
	   Name = "main-public-3"
	}
}
	
resource "aws_subnet" "main-private-1" {
        vpc_id = "${aws_vpc.main.id}"
	cidr_block = "10.0.4.0/24" 
	map_public_ip_on_launch = "false" 
	availability_zone = "ap-south-1a"
	
	tags = {
	   Name = "main-private-1"
	}
}

resource "aws_subnet" "main-private-2" {
	vpc_id = "${aws_vpc.main.id}"
	cidr_block = "10.0.5.0/24"
	map_public_ip_on_launch = "false"
	availability_zone = "ap-south-1b"
	
	tags = {
	   Name = "main-private-2"
	}
}

resource "aws_subnet" "main-private-3" {
	vpc_id = "${aws_vpc.main.id}"
	cidr_block = "10.0.6.0/24"
	map_public_ip_on_launch = "false"
	availability_zone = "ap-south-1c"
	
	tags = {
	   Name = "main-private-3"
	}
}

resource "aws_internet_gateway" "main-gw" {
    vpc_id = "${aws_vpc.main.id}"
	
	tags = {
	    Name = "main"
	}
}

resource "aws_eip" "nat" {
  vpc      = true
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id = "${aws_subnet.main-public-1.id}"
  depends_on = ["aws_internet_gateway.main-gw"]
}

resource "aws_route_table" "main-public"  {
    vpc_id = "${aws_vpc.main.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.main-gw.id}"
    }
    tags = {
        Name = "main-public"
    }
}

resource "aws_route_table" "main-private" {
    vpc_id = "${aws_vpc.main.id}"
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.nat-gw.id}"
    }

    tags = {
        Name = "main-private-1"
    }
}

resource "aws_route_table_association" "main-public-1-a" {
        subnet_id = "${aws_subnet.main-public-1.id}"
        route_table_id = "${aws_route_table.main-public.id}"
}

resource "aws_route_table_association" "main-public-2-a" {
        subnet_id = "${aws_subnet.main-public-2.id}"
        route_table_id = "${aws_route_table.main-public.id}"
}

resource "aws_route_table_association" "main-public-3-c" {
        subnet_id = "${aws_subnet.main-public-3.id}"
        route_table_id = "${aws_route_table.main-public.id}"
}

resource "aws_route_table_association" "main-private-1-a" {
    subnet_id = "${aws_subnet.main-private-1.id}"
    route_table_id = "${aws_route_table.main-private.id}"
}

resource "aws_route_table_association" "main-private-2-a" {
    subnet_id = "${aws_subnet.main-private-2.id}"
    route_table_id = "${aws_route_table.main-private.id}"
}

resource "aws_route_table_association" "main-private-3-a" {
    subnet_id = "${aws_subnet.main-private-3.id}"
    route_table_id = "${aws_route_table.main-private.id}"
}

resource "aws_security_group" "allow_traffic" {
   vpc_id = "${aws_vpc.main.id}"
   name = "allow_traffic"
   description = "To allow the all the traffic" 
   egress { 
      from_port = "0"
      to_port = "0"
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"] 
   }
   ingress {
      from_port = "443" 
      to_port = "443" 
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }
   
   ingress {
      from_port = "22"
      to_port = "22"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
      from_port = "80"
      to_port = "80"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }


   tags = {
       Name = "allow_traffic"
   }
}

resource "aws_key_pair" "mynewkey" {
  key_name = "mynewkey"
  public_key = "${file("${var.PATH_TO_PUBLIC_KEY}")}"
}

resource "aws_instance" "example" {
     ami = "${lookup(var.AMIS,var.AWS_REGION)}"
     instance_type = "t2.micro"
     subnet_id = "${aws_subnet.main-public-1.id}"
     vpc_security_group_ids =["${aws_security_group.allow_traffic.id}"]
     key_name = "${aws_key_pair.mynewkey.key_name}"

 provisioner "file" {
     source = "install.sh"
     destination = "/tmp/install.sh"
 }
 provisioner "remote-exec" {
     inline = [
       "chmod +x /tmp/install.sh",
       "sudo /tmp/install.sh",
     ]
 }
 
 provisioner "local-exec" {
     command = "echo ${aws_instance.example.private_ip} >> private_ips.txt"
  }

 connection {
    host = "${self.public_ip}"
    user = "${var.INSTANCE_USERNAME}"
    private_key = "${file("${var.PATH_TO_PRIVATE_KEY}")}"
 }
 tags = {
    Name = "example"
 }

}

output "ip" {
   value = "${aws_instance.example.public_ip}"
}
