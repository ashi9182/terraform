resource "aws_internet_gateway" "ashish-igw" {
    vpc_id = aws_vpc.vpcashishtf.id
    tags = {
        Name = "ashish-igw"
    }
    depends_on = [aws_vpc.vpcashishtf,]
}

resource "aws_route_table" "ashish-crt1" {
    vpc_id = aws_vpc.vpcashishtf.id
    
    route {
        cidr_block = "0.0.0.0/0" 
        gateway_id = aws_internet_gateway.ashish-igw.id 
    }
    
    tags = {
        Name = "ashish-crt1"
    }
    depends_on = [aws_vpc.vpcashishtf,]
}


resource "aws_route_table_association" "ashish-crt1-public-ashish-tf"{
    subnet_id = aws_subnet.publicashishtf.id
    route_table_id = aws_route_table.ashish-crt1.id
}
