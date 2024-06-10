Terraform for AWS

Steps to run:-

1. Install terraform
Link:- https://developer.hashicorp.com/terraform/install

2. Install AWS cli
Link:- https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

3. Login AWS CLI
Command:- "aws configure"
#Get key from IAM on AWS console
#Link:- https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html

4. Start Terraform
Command:- "terraform init"
#It will install all dependecies to run terraform file

5. Check Infra Plan
Command:- "terraform plan"
#It will show what will be created

6. Apply the terraform conf
Command:- "terraform apply"
#It will create all the infrastructure mentioned in terraform conf
#For automatic creation you can also use 
#Command:- "terraform apply --auto-approve"

7. Destroy the create infrastructure
Command:- "terraform destroy"
#It will destroy every single infra created with terraform
#For automatic creation you can also use 
#Command:- "terraform destroy --auto-approve"


