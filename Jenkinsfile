pipeline {
    agent any

    environment {
        IMAGE_NAME = 'nginx-custom'
        BASE_VERSION_STR = '1.0'
        DOCKERHUB_USERNAME = "tabbu93"
        DOCKERHUB_PASSWORD = "SyedJaheed@9"  // ⚠️ Still hardcoded
        GIT_REPO_URL = 'https://github.com/tabbu9/slack-eks.git'
        GIT_BRANCH = 'main'
        AWS_REGION = 'us-east-1'
        EKS_CLUSTER_NAME = 'eks-slack'
        SLACK_CHANNEL = '#ci-cd-buildstatus'
        SLACK_CRED_ID = 'slack'
        KUBECONFIG_PATH = "${WORKSPACE}/.kube/config"  // 🔧 use a local writable path
    }

    stages {
        stage('Set version tag') {
            steps {
                script {
                    env.TAG = "v${BASE_VERSION_STR}-${env.BUILD_NUMBER}"
                    echo "TAG set to: ${env.TAG}"
                }
            }
        }

        stage('Clone GitHub Repo') {
            steps {
                git url: "${GIT_REPO_URL}", branch: "${GIT_BRANCH}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def fullImageName = "${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${env.TAG}"
                    echo "Building image: ${fullImageName}"
                    sh "docker build -t ${fullImageName} ."
                    sh "docker tag ${fullImageName} ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    def fullImageName = "${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${env.TAG}"
                    sh """
                        echo "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin
                        docker push ${fullImageName}
                        docker push ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws_creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    script {
                        sh """
                            export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                            export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                            export AWS_DEFAULT_REGION=${AWS_REGION}
                            mkdir -p $(dirname ${KUBECONFIG_PATH})
                            aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER_NAME} --kubeconfig ${KUBECONFIG_PATH}
                            export KUBECONFIG=${KUBECONFIG_PATH}
                            kubectl apply -f deployment.yml
                            kubectl rollout status deployment/project04-deployment --timeout=60s
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            slackSend(
                channel: "${SLACK_CHANNEL}",
                color: 'good',
                message: "✅ *SUCCESS* | Build #${env.BUILD_NUMBER} pushed and deployed.",
                tokenCredentialId: SLACK_CRED_ID
            )
        }
        failure {
            slackSend(
                channel: "${SLACK_CHANNEL}",
                color: 'danger',
                message: "❌ *FAILURE* | Build #${env.BUILD_NUMBER} failed. Check Jenkins logs.",
                tokenCredentialId: SLACK_CRED_ID
            )
        }
    }
}
