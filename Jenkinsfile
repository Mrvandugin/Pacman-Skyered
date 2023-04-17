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
    dockerUser = credentials('docker-registry-user')
    dockerPassword = credentials('docker-registry-password')
  }
  
  stages {
    stage('Docker login') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'docker-registry-login', passwordVariable: 'HARBOR_PASSWORD', usernameVariable: 'HARBOR_USERNAME')]) {
          sh "docker login -u ${HARBOR_USERNAME} -p ${HARBOR_PASSWORD} ${registry}"
        }
      }
    }
    
    stage('Build') {
      steps {
        sh "docker build -t ${imageName}:${tag} -f ${dockerfilePath} ."
      }
    }
    
    stage('Tag') {
      steps {
        sh "docker tag ${imageName}:${tag} ${imageName}:${tag}"
      }
    }
    
    stage('Push') {
      steps {
        sh "docker push ${imageName}:${tag}"
      }
    }
  }
}
