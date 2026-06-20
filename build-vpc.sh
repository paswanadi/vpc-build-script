#!/bin/bash
VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text)
aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=AdiVPC
PUBLIC_SUBNET_1=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.0.0/26 --availability-zone ap-southeast-2a --query 'Subnet.SubnetId' --output text)
aws ec2 create-tags --resources $PUBLIC_SUBNET_1 --tags Key=Name,Value=X-Public-1 
PUBLIC_SUBNET_2=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.0.64/26 --availability-zone ap-southeast-2b --query 'Subnet.SubnetId' --output text)
aws ec2 create-tags --resources $PUBLIC_SUBNET_2 --tags Key=Name,Value=X-Public-2
PRIVATE_SUBNET_1=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.0.128/26 --availability-zone ap-southeast-2a --query 'Subnet.SubnetId' --output text)
aws ec2 create-tags --resources $PRIVATE_SUBNET_1 --tags Key=Name,Value=X-Private-1
PRIVATE_SUBNET_2=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.0.192/26 --availability-zone ap-southeast-2b --query 'Subnet.SubnetId' --output text)
aws ec2 create-tags --resources $PRIVATE_SUBNET_2 --tags Key=Name,Value=X-Private-2
IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
aws ec2 create-tags --resources $IGW_ID --tags Key=Name,Value=X-IGW
PUBLIC_RW=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-tags --resources $PUBLIC_RW --tags Key=Name,Value=X-Public-RW
aws ec2 create-route --route-table-id $PUBLIC_RW --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID 
PRIVATE_RW=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-tags --resources $PRIVATE_RW --tags Key=Name,Value=X-Private-RW
aws ec2 associate-route-table --route-table-id $PUBLIC_RW --subnet-id $PUBLIC_SUBNET_1
aws ec2 associate-route-table --route-table-id $PUBLIC_RW --subnet-id $PUBLIC_SUBNET_2
aws ec2 associate-route-table --route-table-id $PRIVATE_RW --subnet-id $PRIVATE_SUBNET_1
aws ec2 associate-route-table --route-table-id $PRIVATE_RW --subnet-id $PRIVATE_SUBNET_2
echo "Build complete. VPC: $VPC_ID"
