terraform {
  backend "s3" {
    bucket = "terraformb11"
    key = "terraform.tfstate"
    region = "ap-south-1"
  }
}
provider "aws" {
    region = var.region
  
}
 # Create vpc
resource "aws_vpc" "myvpc" {
    cidr_block = var.vpc_block
    tags = {
      Name = "${var.project_name}-VPC"
    }
}

# create a public subnet (web tier)
resource "aws_subnet" "public_subnet" {
    vpc_id =aws_vpc.myvpc.id
    cidr_block = var.public_webcidr
    availability_zone = var.az1
    map_public_ip_on_launch = true
    tags = {
      Name = "${var.project_name}-public-subnet"
    }
    }

    # create a private subnet (App tier)

    resource "aws_subnet" "private_subnet" {
    vpc_id =aws_vpc.myvpc.id
    cidr_block = var.private_appcidr
    availability_zone = var.az1
    tags = {
      Name = "${var.project_name}-private-subnet"
    }
    }

    # create a private subnet (DB tier)

    resource "aws_subnet" "private_subnet1" {
    vpc_id =aws_vpc.myvpc.id
    cidr_block = var.private_dbcidr
    availability_zone = var.az2
    tags = {
      Name = "${var.project_name}-private-subnet1"
    }
    }

    
    # create a IGW 
    resource "aws_internet_gateway" "my-igw" {
        vpc_id = aws_vpc.myvpc.id
        tags = {
          Name = "${var.project_name}-IGW"
        }
      
    }

    /*# create a default route table
    resource "aws_default_route_table" "main-RT" {
        default_route_table_id = aws_vpc.myvpc.default_route_table_id
      tags = {
        Name = "${var.project_name}-main-RT"
      }
    }

    # add a route in main route table
    resource "aws_route" "aws-route" {
        route_table_id = aws_default_route_table.main-RT.id
        destination_cidr_block = var.igw_cidr
        gateway_id = aws_internet_gateway.my-igw.id
      
    }*/
    # Public Route Table (IGW)
      resource "aws_route_table" "public_rt" {
     vpc_id = aws_vpc.myvpc.id

    route {
    cidr_block = var.igw_cidr
    gateway_id = aws_internet_gateway.my-igw.id
    }

    tags = {
    Name = "${var.project_name}-public-rt"
   }
   }

    # association Public Subnet   
       resource "aws_route_table_association" "public_assoc" {
      subnet_id      = aws_subnet.public_subnet.id
      route_table_id = aws_route_table.public_rt.id
     } 
     
     # Private Route Table (NAT)
     resource "aws_route_table" "private_rt" {
     vpc_id = aws_vpc.myvpc.id

    route {
    cidr_block     = var.nat_cidr
    nat_gateway_id = aws_nat_gateway.natgw.id
   }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

   # association Public Subnet   
   resource "aws_route_table_association" "private_app_assoc" {
    subnet_id      = aws_subnet.private_subnet.id
   route_table_id = aws_route_table.private_rt.id
   }

  resource "aws_route_table_association" "private_db_assoc" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_rt.id
 }


    # create a web server sg
    resource "aws_security_group" "web_sg" {
      vpc_id = aws_vpc.myvpc.id
        name = "${var.project_name}-sg"
        description = "allow ssh, http, mysql traffic"

        ingress {
            protocol = "tcp"
            to_port = 22
            from_port = 22
            cidr_blocks = ["0.0.0.0/0"]
        }

        ingress  {
            protocol = "tcp"
            to_port = 80
            from_port = 80
            cidr_blocks = ["0.0.0.0/0"]
        }

        egress {
            protocol = -1
            to_port = 0
            from_port = 0
            cidr_blocks= ["0.0.0.0/0"]
        }
        depends_on = [ aws_vpc.myvpc ]
        }


        # create a app server sg
        
        resource "aws_security_group" "app_sg" {
        name   = "${var.project_name}-app-sg"
         vpc_id = aws_vpc.myvpc.id

     ingress {
      from_port       = 8080
        to_port         = 8080
       protocol        = "tcp"
        security_groups = [aws_security_group.web_sg.id]
       }

      egress {
        from_port   = 0
       to_port     = 0
       protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
     }
     }
   # create a Db server sg
         resource "aws_security_group" "db_sg" {
          name   = "${var.project_name}-db-sg"
           vpc_id = aws_vpc.myvpc.id

         ingress {
        from_port       = 3306
         to_port         = 3306
         protocol        = "tcp"
       security_groups = [aws_security_group.app_sg.id]
       }

          egress {
           from_port   = 0
          to_port     = 0
         protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
       }
         }

         # create eip
         resource "aws_eip" "eip1" {
         domain   = "vpc"
              tags = {
         Name = "${var.project_name}-eip"
         }
         }

        # Create nat gw
        resource "aws_nat_gateway" "natgw" {
         allocation_id = aws_eip.eip1.id
         subnet_id     = aws_subnet.public_subnet.id

         tags = {
           Name ="${var.project_name}-NAT"
         }
        depends_on = [aws_internet_gateway.my-igw]
         }

        # create a public server
        resource "aws_instance" "public-server" {
            subnet_id = aws_subnet.public_subnet.id
            ami = var.ami
            instance_type = var.instance_type
            key_name = var.key
            vpc_security_group_ids = [aws_security_group.web_sg.id]
            tags = {
              Name = "${var.project_name}-web-server"
            }
          depends_on = [ aws_security_group.web_sg ]

        }

            # create a private server
        resource "aws_instance" "private-server" {
            subnet_id = aws_subnet.private_subnet.id
            ami = var.ami
            instance_type = var.instance_type
            key_name = var.key
            vpc_security_group_ids = [aws_security_group.app_sg.id]
            tags = {
              Name = "${var.project_name}-app-server"
            }
          depends_on = [ aws_security_group.app_sg ]

        }

        # create a private server
        resource "aws_instance" "private-server1" {
            subnet_id = aws_subnet.private_subnet1.id
            ami = var.ami
            instance_type = var.instance_type
            key_name = var.key
            vpc_security_group_ids = [aws_security_group.db_sg.id]
            tags = {
              Name = "${var.project_name}-db-server"
            }
          depends_on = [ aws_security_group.db_sg ]
          
        }
        

      
    