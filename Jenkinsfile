pipeline {
  agent { label "${AGENT_LABEL}" }
      stages {
        stage('Run docker') {
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
      }
}
