pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = "syedquadri2007@gmail.com"
        DOCKERHUB_PASSWORD = "Jaheed9"
        IMAGE_NAME = "nginx-custom"
        TAG = "v${env.BUILD_NUMBER}"
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
