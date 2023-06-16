# export aws access key and secret key
#!/bin/bash
read -s -p "Please Enter Your AWS Access key: " access_key_id
printf "\n"
read -s -p "Please Enter Your AWS Secret key: " secret_key_id
printf "\n"
export AWS_ACCESS_KEY_ID="$access_key_id"
export AWS_SECRET_ACCESS_KEY="$secret_key_id"
echo "***********************************************************************************************************"
echo "Successfully authenticated to AWS"
echo "***********************************************************************************************************"
echo "provisioning kubernetes servers using terraform starting"
echo "***********************************************************************************************************"
terraform -chdir=terraform init
terraform -chdir=terraform fmt
terraform -chdir=terraform validate
terraform -chdir=terraform apply -auto-approve
if [ $? -eq 0 ]; then
    echo "***********************************************************************************************************"
    echo "provisioning kubernetes servers successfully completed"
    echo "***********************************************************************************************************"
    sleep 20s
    echo "configuring kubernetes servers using ansible"
    echo "***********************************************************************************************************"
    ansible-playbook -i ansible/aws_ec2.yaml ansible/playbook.yaml  -u ubuntu --private-key=/home/ubuntu/.ssh/tera-ans.pem --ssh-common-args='-o StrictHostKeyChecking=no'
    if [ $? -eq 0 ]; then
       echo "***********************************************************************************************************"
       echo "Configuration of kubernetes servers completed successfully"
       echo "***********************************************************************************************************"
    else
        echo "***********************************************************************************************************"
        echo "Configuration of kubernetes servers failed"
        echo "***********************************************************************************************************"
    fi
else
    echo "***********************************************************************************************************"
    echo "Provisioning kubernetes servers failed"
    echo "***********************************************************************************************************"
fi
# Prompt the user to confirm destruction
read -p "Do you want to destroy the infrastructure? (yes/no): " destroy_input
read -p "Please enter 'yes' again to confirm destruction: " confirm_input
if [[ $destroy_input == "yes" && $confirm_input == "yes" ]]; then
    echo "***********************************************************************************************************"
    echo "Destroying kubernetes servers using terraform"
    echo "***********************************************************************************************************"
    terraform -chdir=terraform destroy -auto-approve
    if [ $? -eq 0 ]; then
        echo "***********************************************************************************************************"
        echo "Destruction of kubernetes servers completed successfully"
        echo "***********************************************************************************************************"
    else
        echo "***********************************************************************************************************"
        echo "Destruction of kubernetes servers failed"
        echo "***********************************************************************************************************"
    fi
else
    echo "***********************************************************************************************************"
    echo "Skipping destruction of kubernetes servers"
    echo "***********************************************************************************************************"
fi