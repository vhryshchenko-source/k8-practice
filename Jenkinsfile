pipeline {
  agent { label 'jenkins-slave' }
      stages {
        stage('Run docker') {
          steps {
            container('docker') {
              echo POD_CONTAINER
              sh '''
                  docker --version
                  echo "FROM hello-world" >> Dockerfile
                  docker build --tag test-image .
                  docker images
              '''
            }
          }
        }
      }
}