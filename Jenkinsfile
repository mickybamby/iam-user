pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                echo 'Cloning repository...'
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                echo 'Initializing Terraform working directory...'
                // Crucial for downloading providers and setting up the backend (e.g., S3 for state locking)
                sh 'terraform init'
            }
        }

        stage('Terraform Validate') {
            steps {
                echo 'Validating Terraform configuration...'
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                echo 'Creating Terraform execution plan...'
                // Saves the plan to a file to ensure consistency between plan and apply
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            steps {
                echo 'Applying Terraform configuration to AWS...'
                // Applies the saved plan file
                sh 'terraform apply -auto-approve tfplan'
            }
        }
        
        stage('Cleanup') {
            steps {
        sh 'rm -f tfplan'
        sh 'rm -rf .terraform .terraform.lock.hcl'
    }
}
    }
}
