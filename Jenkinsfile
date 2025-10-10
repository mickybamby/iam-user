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

        stage('Terraform Plan & Apply') {
            steps {
                // Use the AWS plugin to inject credentials securely
                withAWS(credentials: 'aws-jenkins', region: 'eu-west-1') {
                    echo 'Creating Terraform plan...'
                    sh 'terraform plan -out=tfplan'

                    echo 'Applying Terraform plan...'
                    sh 'terraform apply -auto-approve tfplan'
                }
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
