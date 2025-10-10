pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Cloning repository...'
                checkout scm
            }
        }

        stage('Terraform Operations') {
            steps {
                // Use AWS Credentials Plugin to inject credentials for all Terraform steps
                withAWS(credentials: 'aws-jenkins', region: 'eu-west-1') {
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