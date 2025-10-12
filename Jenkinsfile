pipeline {
    agent any

    environment {
        // Inject AWS credentials as environment variables
        AWS_ACCESS_KEY_ID     = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_key_id')
        AWS_DEFAULT_REGION     = 'eu-west-1'
    }

    parameters {
    booleanParam(name: 'APPLY_CHANGES', defaultValue: false, description: 'Apply Terraform changes') 
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

      echo "Installing TFLint..."
      curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | sudo bash

      echo "Installing Trivy..."
      curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin

      echo "Verifying tools..."
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
        echo "Running tflint..."
        sh 'tflint --init'
        // Run tflint but don't fail the pipeline on warnings
        sh(script: 'tflint || true', label: 'Run TFLint')
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
            when {
                expression { return params.APPLY_CHANGES }
    }
            steps {
                input message: 'Destroy Terraform resources?', ok: 'Destroy'
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
