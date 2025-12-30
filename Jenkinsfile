pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'votre-user-docker/mon-site-web'
        DOCKER_TAG = "${BUILD_NUMBER}"
        VPS_IP = '192.168.1.155'
        VPS_USER = 'badra' 
    }

    stages {
        stage('Build Image') {
            steps {
                script {
                    echo 'Construction de l\'image Docker...'
                    sh "docker build -t $DOCKER_IMAGE:$DOCKER_TAG ."
                    sh "docker tag $DOCKER_IMAGE:$DOCKER_TAG $DOCKER_IMAGE:latest"
                }
            }
        }

        stage('Push to Registry') {
            steps {
                script {
                    echo 'Envoi vers Docker Hub...'
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        sh "docker login -u $DOCKER_USER -p $DOCKER_PASS"
                        sh "docker push $DOCKER_IMAGE:$DOCKER_TAG"
                        sh "docker push $DOCKER_IMAGE:latest"
                    }
                }
            }
        }

        stage('Deploy to VPS') {
            steps {
                script {
                    echo 'Déploiement sur le VPS...'
                    sshagent(['ssh-vps']) {
                        // Connexion SSH pour pull et restart
                        sh """
                            ssh -o StrictHostKeyChecking=no ${VPS_USER}@${VPS_IP} '
                                docker pull $DOCKER_IMAGE:latest
                                docker stop mon-site-web || true
                                docker rm mon-site-web || true
                                docker run -d --name mon-site-web -p 80:80 $DOCKER_IMAGE:latest
                            '
                        """
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Nettoyage de l'image locale pour économiser de l'espace
            sh "docker rmi $DOCKER_IMAGE:$DOCKER_TAG || true"
        }
    }
}