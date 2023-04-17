pipeline {
    agent any
    environment {
        imageName = 'harbor.skyered-devops.de/pacman/pacman-app'
        registry = 'harbor.skyered-devops.de'
        dockerfilePath = './Dockerfile'
        tag = '0.4'
    }

    
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    docker.withRegistry(registry, HARBOR_USERNAME, HARBOR_PASSWORD) {
                        def image = docker.build(imageName, "-f ${dockerfilePath} .")
                        image.tag("${registry}/${imageName}:${tag}")
                    }
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry(registry, HARBOR_USERNAME, HARBOR_PASSWORD) {
                        docker.image("${registry}/${imageName}:${tag}").push()
                    }
                }
            }
        }
    }
}
