pipeline {
  agent { label "${AGENT_LABEL}" }

  environment {
    DOCKERHUB_CREDENTIAL = credentials('docker-hub-credentials')
  }
  parameters {
      gitParameter (  branch: '', 
                      branchFilter: 'origin/(.*)', 
                      defaultValue: 'develop', 
                      description: '', 
                      name: 'BRANCH', 
                      quickFilterEnabled: true, 
                      selectedValue: 'TOP', 
                      sortMode: 'DESCENDING', 
                      tagFilter: '*', 
                      type: 'PT_BRANCH', 
                      useRepository: 'git@github.com:vhryshchenko-source/k8-practice.git')
  }
      stages {
        stage('Checkout') {
            steps{
                // Checkout branch
                git branch: "${params.BRANCH}", credentialsId: 'github-credentials', url: 'git@github.com:vhryshchenko-source/k8-practice.git'
                // Checkout commit
                checkout(
                    [$class: 'GitSCM', 
                    branches: [[name: GIT_COMMIT]],
                    doGenerateSubmoduleConfigurations: false, 
                    extensions: [],
                    submoduleCfg: [], userRemoteConfigs: 
                    [[credentialsId: 'github-credentials', 
                    url: 'git@github.com:vhryshchenko-source/k8-practice.git']]
                    ]
                ) 
            }
        }

        stage('Env print') {
            steps {
                sh '''
                    echo $BRANCH
                    echo $GIT_COMMIT
                '''
            }
        }

        stage('Build image') {
          when {
            expression {
              GIT_BRANCH == 'origin/develop'
              RELEASE_TAG == ''
            }
          }
          steps {
            container('docker') {
              echo POD_CONTAINER
              echo GIT_BRANCH
              sh '''
                  docker build --tag $DOCKER_REPO:$GIT_COMMIT --build-arg PYTHON_VERSION .
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
        stage('Pull image') {
          when {
            expression {
              RELEASE_TAG != ''
            }
          }
          steps{
            container('docker') {
              sh 'docker pull $DOCKER_REPO:$GIT_COMMIT'
            }
          }
        }
        stage('Push image') {
          steps{
            script {
              if (RELEASE_TAG == '') {
                container('docker') {
                  sh 'docker push $DOCKER_REPO:$GIT_COMMIT'
                }
              } else {
                container('docker') {
                  sh 'docker tag $DOCKER_REPO:$GIT_COMMIT $DOCKER_REPO:$RELEASE_TAG'
                  sh 'docker push $DOCKER_REPO:$RELEASE_TAG'
                }
              }
            }
          }
        }
      }
}

