pipeline {
  agent { label "${AGENT_LABEL}" }
      environment {
        DOCKERHUB_CREDENTIAL = credentials('docker-hub-credentials')
        GIT_BRANCH = sh(returnStdout: true, script: 'git rev-parse --abbrev-ref HEAD').trim()
      }
      stages {
        stage('Build image') {

          steps {
            container('docker') {
              echo POD_CONTAINER
              sh '''
                  docker build --tag vhrysh/hit-count:$GIT_COMMIT --build-arg PYTHON_VERSION .
                  docker images
                  echo $GIT_BRANCH
              '''
            }
          }
        }
        stage('Docker hub login') {
          when {
            anyOf {
              branch 'develop'
              branch 'release-0.1'
            }
          }
          steps{
            container('docker') {
              sh 'echo $DOCKERHUB_CREDENTIAL_PSW | docker login -u $DOCKERHUB_CREDENTIAL_USR --password-stdin'
            }   
          }
        }
        stage('Pull image') {
          when {
            branch 'release-0.1'
          }
          steps{
            container('docker') {
              sh 'docker pull vhrysh/hit-count:$GIT_COMMIT'
            }
          }
        }
        stage('Push image') {
          when {
            branch 'develop'
            branch 'release-0.1'
          }
          steps{
            script {
              if ($RELEASE_TAG == '') {
                container('docker') {
                  sh 'docker push vhrysh/hit-count:$GIT_COMMIT'
                }
              } else {
                container('docker') {
                  sh 'docker tag vhrysh/hit-count:$GIT_COMMIT vhrysh/hit-count:$RELEASE_TAG'
                  sh 'docker push vhrysh/hit-count:$RELEASE_TAG'
                }
              }
            }
          }
        }
      }
}
