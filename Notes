pipeline {
  agent {
    docker {
      image 'hashicorp/terraform:1.9.6'
      args '--entrypoint=""'
    }
  }

  environment {
    AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
    AWS_SECRET_ACCESS_KEY = credentials('aws_secret_key_id')
    AWS_DEFAULT_REGION = 'eu-west-1'
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
          apt-get update -y
          apt-get install -y curl
          curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
          curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
          terraform -version
          tflint --version
          trivy --version
        '''
      }
    }

    stage('Terraform Init') {
      steps {
        sh '''
          echo "Initializing Terraform..."
          terraform init -input=false || exit 1
        '''
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

    stage('Validate Terraform Code') {
      steps {
        sh '''
          echo "Validating Terraform configuration..."
          terraform validate
        '''
      }
    }

    stage('Static Security Analysis (Trivy)') {
      steps {
        sh '''
          echo "Running Trivy security scan..."
          trivy terraform --severity HIGH,CRITICAL .
        '''
      }
    }

    stage('Terraform Plan') {
      steps {
        sh '''
          echo "Generating Terraform plan..."
          terraform plan -out=tfplan
        '''
      }
    }

    stage('Terraform Apply') {
      when {
        expression { return params.APPLY_CHANGES }
      }
      steps {
        input message: 'Apply Terraform changes?', ok: 'Apply'
        sh '''
          echo "Applying Terraform changes..."
          terraform apply -auto-approve tfplan
        '''
      }
    }
  }

  post {
    always {
      echo "Pipeline completed."
      cleanWs() // Clean workspace
    }
    failure {
      echo "Pipeline failed. Please check logs."
      slackSend(channel: '#devops', message: "Terraform pipeline failed. Check Jenkins logs.")
    }
  }
}