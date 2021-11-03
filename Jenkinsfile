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
                  docker build --tag test-image .
                  docker images
              '''
            }
          }
        }
      }
}
