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

      choice (  name: 'AGENT_LABEL', 
                choices: ['jenkins-slave-1', 'jenkins-slave-2'], 
                description: 'Choose jenkins worker where job will be run')
        
      choice (  name: 'PYTHON_VERSION', 
                choices: ['3.7', '3.8'], 
                description: 'Choose python version for docker base image')

      string (  name: 'DOCKER_REPO', 
                defaultValue: 'vhrysh/hit-count', 
                description: 'Docker hub repository name')

      string (  name: 'RELEASE_TAG', 
                description: 'Enter release tag if you want to make realese')

      string (  name: 'GIT_COMMIT', 
                description: 'Enter git commit')

            
      choice (  name: 'BUILD_RELEASE', 
                choices: ['FALSE', 'TRUE'], 
                description: 'Choose TRUE if you want build and deploy image with release tag')
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
                    echo $GIT_BRANCH
                '''
            }
        }

        stage('Build image') {
          when {
            expression {
              anyOf {
                GIT_BRANCH == 'origin/develop'
                BUILD_RELEASE == 'TRUE'
              }
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
              params.BRANCH == 'release*'
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
              if (GIT_BRANCH == 'origin/develop') {
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
// test
