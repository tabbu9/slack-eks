pipeline {
    agent any
 
    environment {
        DOCKER_CREDENTIALS_ID = 'project04'  
        GIT_REPO_URL = 'https://github.com/tabbu9/slack-eks.git'  
        DOCKER_IMAGE_NAME = 'tabbu93/project04'
        SLACK_CHANNEL = '#ci-cd-buildstatus'
        GIT_BRANCH = 'main'
        AWS_REGION = 'us-east-1'
        SLACK_CREDENTIALS_ID = 'slack'
        EKS_CLUSTER_NAME = 'batch071-eks'
    }
 
    stages {
        stage('Clone GitHub Repository') {
            steps {
                git url: "${GIT_REPO_URL}", branch: 'project04'
            }
        }
 
        stage('Build and Prepare Docker Image') {
            steps {
                script {
                    def latestTag = sh(
                        script: 'curl -s https://hub.docker.com/v2/repositories/harishgorla5/project4/tags | jq -r \'.results | map(select(.name | test("^v[0-9]+\\\\.[0-9]+$"))) | sort_by(.name) | last | .name\' || echo "v4.0"',
                        returnStdout: true
                    ).trim()
 
                    if (latestTag == "null" || !latestTag.startsWith("v")) {
                        latestTag = "v4.0"
                    }
 
                    def versionParts = latestTag.substring(1).split('\\.')
                    def major = versionParts[0].toInteger()
                    def minor = versionParts[1].toInteger() + 1
                    env.IMAGE_VERSION = "v${major}.${minor}"
 
                    echo "New Docker Image Version: ${env.IMAGE_VERSION}"
 
                    withCredentials([string(credentialsId: DOCKER_CREDENTIALS_ID, variable: 'DOCKER_TOKEN')]) {
                        sh 'echo "$DOCKER_TOKEN" | docker login -u "tabbu93" --password-stdin'
                    }
 
                    sh 'docker pull nginx:latest'
 
                    if (fileExists('index.html')) {
                        writeFile file: 'Dockerfile', text: '''
                        FROM nginx:latest
                        COPY index.html /usr/share/nginx/html/index.html
                        '''
                    } else {
                        error "index.html file is missing!"
                    }
 
                    sh """
                        docker build -t ${DOCKER_IMAGE_NAME}:${IMAGE_VERSION} -t ${DOCKER_IMAGE_NAME}:latest .
                    """
                }
            }
        }
 
        stage('Push Updated Image to Docker Hub') {
            steps {
                script {
                    sh "docker push ${DOCKER_IMAGE_NAME}:${IMAGE_VERSION}"
                    sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                }
            }
        }
        
        stage('Deploy to EKS') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                        export AWS_DEFAULT_REGION=${AWS_REGION}
                        aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER_NAME}
                        kubectl apply -f deployment.yaml
                        kubectl rollout status deployment/project04-deployment --timeout=60s
                    '''
                }
            }
        }
    }
 
    post {
        success {
            script {
                slackSend(
                    channel: "${SLACK_CHANNEL}",
                    color: "good",
                    credentialsId: "${SLACK_CREDENTIALS_ID}",
                    message: "✅ *SUCCESS*: Jenkins Build Completed! 🎉\n*Project:* Project04\n*Version:* ${IMAGE_VERSION}\n*Docker Image:* ${DOCKER_IMAGE_NAME}:latest"
                )
            }
        }
        failure {
            script {
                slackSend(
                    channel: "${SLACK_CHANNEL}",
                    color: "danger",
                    credentialsId: "${SLACK_CREDENTIALS_ID}",
                    message: "❌ *FAILED*: Jenkins Build Failed! 🚨\n*Project:* Project04\n*Check Jenkins logs for errors.*"
                )
            }
        }
        always {
            script {
                echo "🧹 Removing all local Docker images..."
                sh 'docker rmi -f $(docker images -aq) || echo "No images to remove."'
                sh 'docker system prune -f'
            }
        }
    }
}
