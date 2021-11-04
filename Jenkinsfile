pipeline {
  agent { label "${AGENT_LABEL}" }
      environment {
        DOCKERHUB_CREDENTIAL = credentials('docker-hub-credentials')
        RELEASE_NOTES = sh (script: """git log --format="medium" -1 ${GIT_COMMIT}""", returnStdout:true)
      }
      stages {
        stage('Build image') {
          steps {
            container('docker') {
              echo POD_CONTAINER
              sh '''
                  docker build --tag vhrysh/hit-count:$VERSION --build-arg PYTHON_VERSION .
                  echo $RELEASE_NOTES
                  docker images
              '''
            }
          }
        }
        stage('Docker hub login') {
          steps{
            container('docker') {
              sh 'echo $DOCKERHUB_CREDENTIAL_PSW | docker login -u $DOCKERHUB_CREDENTIAL_USR --password-stdin'
            }   
          }
        }
        stage('Push image') {
            steps{
              container('docker') {
              sh 'docker push vhrysh/hit-count:$VERSION'
              }
            }
        }
      }
}
