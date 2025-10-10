pipeline {
    agent any

    environment {
        // Inject AWS credentials as environment variables
        AWS_ACCESS_KEY_ID = credentials('aws-jenkins')
        AWS_SECRET_ACCESS_KEY = credentials('aws-jenkinss')
        AWS_DEFAULT_REGION = 'eu-west-1'
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

        stage('Terraforom Destroy') {
            steps {
                echo 'Destroying configuration from AWS...'
                sh 'terraform destroy -auto-approve'
            }
        }

        stage('Cleanup') {
            steps {
                echo 'Cleaning up temporary files...'
                sh 'rm -f tfplan'
                sh 'rm -rf .terraform .terraform.lock.hcl'
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed.'
        }
        failure {
            echo 'Pipeline failed! Check Terraform or AWS credentials.'
        }
        success {
            echo 'Pipeline succeeded! Resources created.'
        }
    }
}