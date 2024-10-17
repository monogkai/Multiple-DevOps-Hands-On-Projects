# Deploy EKS Cluster Using Terraform and Jenkins

Steps:
1) Create EC2 instance with "Monogkai-EKS" name in AWS account
    - Select Ubuntu AMI
    - Select Instance type t2.medium
    - Create a new Key Pair named monogkai and the download of monogkai.pem is done
    - Select Create security group, allowing SSH traffic, HTTPS traffic from the internet and HTTP traffic from the internet, anywhere 0.0.0.0/0
    - Add installer.sh file content in user data field
    - Launch instance

    ![Alt text](images/ec2-instance-created.png)