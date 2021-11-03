pipeline {
  agent { label "${AGENT_LABEL}" }
      stages {
        stage('Build image') {
          steps {
            container('docker') {
              echo POD_CONTAINER
              sh '''
                  docker --version
                  ls
                  docker build --tag vhrysh/hit-count:$VERSION .
                  docker images
              '''
            }
          }
        }
        stage('Push image') {
            docker.withRegistry('', 'docker-hub-credentials') {
            dockerImage.push()
            }
        }
      }
}
