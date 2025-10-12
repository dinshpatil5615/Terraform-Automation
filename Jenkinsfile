pipeline {
    agent any

    environment {
        DYNAMODB_TABLE = "my-dynamodb-table"
        STATE_KEY = "mydev-project-terraform-sample-batch-29/main"
        GIT_REPO = "https://github.com/dinshpatil5615/Terraform-Automation.git"
        GIT_BRANCH = "main"
    }

    stages {
        stage('Checkout from GitHub') {
            steps {
                echo "Cloning GitHub repository..."
                git branch: "${GIT_BRANCH}", url: "${GIT_REPO}"
            }
        }

        stage('Check & Remove Terraform Lock') {
            steps {
                script {
                    echo "Checking for existing Terraform lock in DynamoDB..."

                    def lock = sh(
                        script: """
                            aws dynamodb get-item --table-name $DYNAMODB_TABLE \
                            --key '{ "LockID": { "S": "$STATE_KEY" } }' \
                            --query "Item" --output json
                        """,
                        returnStdout: true
                    ).trim()

                    if (lock != "null") {
                        echo "Stale lock detected. Deleting lock..."
                        sh """
                            aws dynamodb delete-item --table-name $DYNAMODB_TABLE \
                            --key '{ "LockID": { "S": "$STATE_KEY" } }'
                        """
                        echo "Lock deleted successfully."
                    } else {
                        echo "No existing lock found. Safe to proceed."
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init -input=false'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -lock-timeout=2m'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve -lock-timeout=2m'
            }
        }
    }

    post {
        failure {
            echo "Terraform run failed. Check logs for details."
        }
        success {
            echo "Terraform applied successfully!"
        }
    }
}
