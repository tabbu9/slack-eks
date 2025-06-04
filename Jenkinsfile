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
        stage('Clone GitHub Repo') {
            steps {
                git url: 'https://github.com/tabbu9/slack-eks.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def fullImageName = "${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${TAG}"
                    echo "Building image: ${fullImageName}"
                    sh "docker build -t ${fullImageName} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    def fullImageName = "${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${TAG}"
                    sh """
                        echo "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin
                        docker push ${fullImageName}
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Docker image pushed: ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${TAG}"
        }
        failure {
            echo "❌ Build failed. Check logs for more info."
        }
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
