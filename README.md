## Terraform + Ansible Setup
Terraform official doc 
https://registry.terraform.io/providers/hashicorp/aws/latest/docs

### Launch Amazon-Linux instance for Terraform & Ansible Installation (Master Instance)
1. Launch Amazon-Linux instance 
2. install terraform --> https://developer.hashicorp.com/terraform/downloads
3. install ansible ``` yum install ansible```
4. install aws-cli and setup the credentials for IAM user
```
aws --version
aws configure 
aws configure list
```
### Launching slave instance from terraform
1. copy the terraform-AL2-launch folder into the master instance  

```
cd terraform-AL2-launch
```

2. execute below command to get neccessary dependancies for provider to run terraform script

```
terraform init
```

3. check terraform syntax

```
terraform plan
```
4. Create resources present in terraform script
```
terraform apply / terraform apply -auto-approve
```
5. Destroy created resources
```
terraform destroy
```


### Copy slave pem file to master instance
we have manually created secret key to ssh into the slave instance. This needs to be copied to master instance so that master can access slave
1. Enable PasswordbasedAuthentication in master instance
2. command to copy the pem file from local to master instance
```
scp Server-Key-Pair.pem root@15.206.89.99:/root   
```
<!-- https://linuxize.com/post/how-to-use-scp-command-to-securely-transfer-files/ -->

3. connect to master instance & move Server-Key-Pair.pem to .ssh folder
```
mv Server-Key-Pair.pem .ssh
```
