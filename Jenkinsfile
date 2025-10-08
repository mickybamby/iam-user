pipeline {
    agent any
    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        // Use Jenkins credentials (configured under Manage Jenkins → Credentials)
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    }
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
                sh 'terraform plan -out=tfplan'
            }
        }
        stage('Terraform Apply') {
            steps {
                echo 'Applying Terraform configuration to AWS...'
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }
    
}