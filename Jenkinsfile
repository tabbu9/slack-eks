pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = "your-dockerhub-username"      // 🔸 Change this
        IMAGE_NAME = "nginx-custom"                         // 🔸 Change if desired
        IMAGE_TAG = "v${env.BUILD_NUMBER}"                  // Auto-incremented tag
        CREDENTIALS_ID = "dockerhub-creds"                  // 🔸 Jenkins DockerHub creds
    }

    stages {
        stage('Clone Repo') {
            steps {
                git url: 'https://github.com/your-username/your-nginx-repo.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def fullImageName = "${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"
                    echo "Building image: ${fullImageName}"
                    sh "docker build -t ${fullImageName} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${CREDENTIALS_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        def fullImageName = "${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"
                        sh """
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            docker push ${fullImageName}
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Docker image pushed: ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "❌ Build failed."
        }
    }
}
