pipeline {
    agent any

    environment {
        // Inject AWS credentials as environment variables
        AWS_ACCESS_KEY_ID     = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_key_id')
        AWS_DEFAULT_REGION     = 'eu-west-1'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Cloning repository...'
                checkout scm
            }
        }

        stage('Setup Tools') {
            steps {
                sh '''
                  echo "Installing linters..."
                  sudo apt-get update -y
                  sudo apt-get install -y curl unzip

                  # Install TFLint
                  curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

                  # Install Trivy
                  curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

                  terraform -version
                  tflint --version
                  trivy --version
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                echo 'Initializing Terraform working directory...'
                sh 'terraform init'
            }
        }

        stage('Lint Terraform Code') {
            steps {
                sh '''
                  echo "Running tflint..."
                  tflint --init
                  tflint
                '''
            }
        }

        stage('Terraform Validate') {
            steps {
                echo 'Validating Terraform configuration...'
                sh 'terraform validate'
            }
        }

        stage('Static Security Analysis (Trivy)') {
            steps {
                sh '''
                  echo "Running Trivy security scan..."
                  trivy config --severity HIGH,CRITICAL .
                '''
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

        stage('Terraform Destroy') {
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
