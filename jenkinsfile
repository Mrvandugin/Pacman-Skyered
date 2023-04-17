pipeline {
  agent {
    docker {
      image 'docker:latest'
      args '-v /var/run/docker.sock:/var/run/docker.sock'
    }
  }
  
  environment {
    imageName = 'harbor.skyered-devops.de/pacman/pacman-app'
    registry = 'harbor.skyered-devops.de'
    dockerfilePath = './Dockerfile'
    tag = '0.4'
  }
  
  stages {
    stage('Build') {
      steps {
        sh "docker build -t ${imageName}:${tag} -f ${dockerfilePath} ."
      }
    }
    
    stage('Tag') {
      steps {
        sh "docker tag ${imageName}:${tag} ${registry}/${imageName}:${tag}"
      }
    }
    
    stage('Push') {
      steps {
        sh "docker push ${registry}/${imageName}:${tag}"
      }
    }
  }
}
