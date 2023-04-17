pipeline {
  agent any/*{
    docker {
      image 'docker:latest'
      args '-v /var/run/docker.sock:/var/run/docker.sock'
    }
  }*/
  
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
    
    stage('Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'harbor-registry-credentials', usernameVariable: 'HARBOR_USERNAME', passwordVariable: 'HARBOR_PASSWORD')]) {
          sh "docker login -u ${HARBOR_USERNAME} -p ${HARBOR_PASSWORD} ${registry}"
          sh "docker tag ${imageName}:${tag} ${imageName}:${tag}"
          sh "docker push ${imageName}:${tag}"
        }
      }
    }
  }  
}
