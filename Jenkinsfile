pipeline {
    agent any

    environment {
        IMAGE_NAME = 'nginx-custom'
        BASE_VERSION_STR = '1.0'
        DOCKERHUB_USERNAME = "tabbu93"
        DOCKERHUB_PASSWORD = "SyedJaheed@9"
        GIT_REPO_URL = 'https://github.com/tabbu9/slack-eks.git'
        GIT_BRANCH = 'main'
        AWS_REGION = 'us-east-1'
        EKS_CLUSTER_NAME = 'eks-slack'
        SLACK_CHANNEL = '#ci-cd-buildstatus'
        SLACK_CRED_ID = 'slack'   // <-- Slack token credential ID here
        KUBECONFIG = "/home/jenkins/.kube/config"
    }

    stages {
        stage('Set version tag') {
            steps {
                script {
                    env.VERSION_TAG = "v${BASE_VERSION_STR}-${env.BUILD_NUMBER}"
                    echo "VERSION_TAG set to: ${env.VERSION_TAG}"
                }
            }
        }

        stage('Checkout') {
            steps {
                git url: "${env.GIT_REPO_URL}", branch: "${env.GIT_BRANCH}"
            }
        }

        stage('Clean old images') {
            steps {
                sh 'docker images -q | xargs -r docker rmi -f || true'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def image = docker.build("${IMAGE_NAME}:${env.VERSION_TAG}")
                    sh "docker tag ${IMAGE_NAME}:${env.VERSION_TAG} ${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([string(credentialsId: DOCKERHUB_CRED, variable: 'DOCKER_PASSWORD')]) {
                    sh 'echo $DOCKER_PASSWORD | docker login -u 1sharathchandra --password-stdin'
                }
                sh """
                    docker push ${IMAGE_NAME}:${env.VERSION_TAG}
                    docker push ${IMAGE_NAME}:latest
                """
                sh 'docker images -q | xargs -r docker rmi -f || true'
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                        export AWS_DEFAULT_REGION=${AWS_REGION}
                        aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER_NAME}
                        kubectl apply -f deployment.yml
                        kubectl rollout status deployment/project04-deployment --timeout=60s
                    '''
                }
            }
        }
    }

    post {
        success {
            withCredentials([string(credentialsId: env.SLACK_CRED_ID, variable: 'SLACK_TOKEN')]) {
                slackSend(
                    channel: "${SLACK_CHANNEL}",
                    color: 'good',
                    message: "✅ *SUCCESS* | Project04 - Build #${env.BUILD_NUMBER} completed successfully.",
                    tokenCredentialId: env.SLACK_CRED_ID
                )
            }
        }

        failure {
            withCredentials([string(credentialsId: env.SLACK_CRED_ID, variable: 'SLACK_TOKEN')]) {
                slackSend(
                    channel: "${SLACK_CHANNEL}",
                    color: 'danger',
                    message: "❌ *FAILURE* | Project04 - Build #${env.BUILD_NUMBER} failed. Check Jenkins for details.",
                    tokenCredentialId: env.SLACK_CRED_ID
                )
            }
        }
    }
}
