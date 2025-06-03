pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = "tabbu93"
        DOCKERHUB_PASSWORD = "SyedJaheed@9"
        IMAGE_NAME = "nginx-custom"
        TAG = "v${env.BUILD_NUMBER}"
        KUBECONFIG = "/home/jenkins/.kube/config" // Adjust as per your Jenkins agent
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

        stage('Deploy to EKS') {
            steps {
                script {
                    def fullImageName = "${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${TAG}"

                    // Optional: Update image in your Kubernetes manifest (if it's in the repo)
                    sh "sed -i 's|image:.*|image: ${fullImageName}|' k8s/deployment.yaml"

                    // Apply updated manifest
                    sh "kubectl apply -f k8s/"
                }
            }
        }
    }

    post {
        success {
            echo "✅ Docker image pushed and deployed to EKS: ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${TAG}"
        }
        failure {
            echo "❌ Build or deployment failed. Check logs."
        }
    }
}
