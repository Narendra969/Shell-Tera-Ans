#!/bin/bash

# Check if access key and secret key are already set
if [[ -z $AWS_ACCESS_KEY_ID || -z $AWS_SECRET_ACCESS_KEY ]]; then
    printf "\n"
    read -s -p "Please Enter Your AWS Access key: " access_key_id
    printf "\n"
    read -s -p "Please Enter Your AWS Secret key: " secret_key_id
    printf "\n"
    export AWS_ACCESS_KEY_ID="$access_key_id"
    export AWS_SECRET_ACCESS_KEY="$secret_key_id"
    echo "********************************************************************************************************************"
    echo "Successfully Authenticated to AWS"
    echo "********************************************************************************************************************"
else
    echo "AWS access key and secret key are already set in the current session."
fi

read -p "Do you want to provision or destroy the infrastructure? (provision/destroy): " action

case $action in
    "provision")
        echo "******************************************************************************************************************"
        echo "Provisioning Kubernetes servers using Terraform"
        echo "******************************************************************************************************************"
        terraform -chdir=terraform init
        terraform -chdir=terraform fmt
        terraform -chdir=terraform validate
        terraform -chdir=terraform apply -auto-approve
        if [ $? -eq 0 ]; then
            echo "***************************************************************************************************************"
            echo "Provisioning Kubernetes servers completed successfully"
            echo "*******************************wait 20 seconds for the Kubernetes servers to be up*****************************"
            sleep 20s
            echo "***************************************************************************************************************"
            echo "Configuring Kubernetes servers using Ansible"
            echo "***************************************************************************************************************"
            ansible-playbook \
             -i ansible/aws_ec2.yaml \
             ansible/playbook.yaml \
             -u ubuntu \
            --private-key=/home/ubuntu/.ssh/tera-ans.pem \
            --ssh-common-args='-o StrictHostKeyChecking=no'

            if [ $? -eq 0 ]; then
                echo "***********************************************************************************************************"
                echo "Configuration of Kubernetes servers completed successfully"
                echo "***********************************************************************************************************"
            else
                echo "***********************************************************************************************************"
                echo "Configuration of Kubernetes servers failed"
                echo "***********************************************************************************************************"
            fi
        else
            echo "***************************************************************************************************************"
            echo "Provisioning Kubernetes servers failed"
            echo "***************************************************************************************************************"
        fi
        ;;
    "destroy")
        read -p "Do you want to destroy the infrastructure? (yes/no): " destroy_input
        read -p "Please enter 'yes' again to confirm destruction: " confirm_input
        if [[ $destroy_input == "yes" && $confirm_input == "yes" ]]; then
            echo "**************************************************************************************************************"
            echo "Destroying Kubernetes servers using Terraform"
            echo "**************************************************************************************************************"
            terraform -chdir=terraform destroy -auto-approve
            if [ $? -eq 0 ]; then
                echo "**********************************************************************************************************"
                echo "Destruction of Kubernetes servers completed successfully"
                echo "**********************************************************************************************************"
            else
                echo "**********************************************************************************************************"
                echo "Destruction of Kubernetes servers failed"
                echo "**********************************************************************************************************"
            fi
        else
            echo "**************************************************************************************************************"
            echo "Skipping destruction of Kubernetes servers"
            echo "**************************************************************************************************************"
        fi
        ;;
    *)
        echo "Invalid action selected. Please choose 'provision' or 'destroy'."
        ;;
esac
