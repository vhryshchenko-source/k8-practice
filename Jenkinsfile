pipeline {
  agent { label "${AGENT_LABEL}" }

  environment {
    DOCKERHUB_CREDENTIAL = credentials('docker-hub-credentials')
    ///COMMIT_ID = """${sh(
    ///            returnStdout: true,
    ///            script: 'git rev-parse --verify HEAD"'
    ///        )}"""
    ///COMMIT_ID = "${sh(script:'git rev-parse --verify HEAD', returnStdout: true).trim()}"
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

      string (  name: 'COMMIT_ID', 
                description: 'Enter git commit')
          
      // string (  name: 'BRANCH', 
      //          description: 'Enter git commit')
            
      choice (  name: 'BUILD_RELEASE', 
                choices: ['FALSE', 'TRUE'], 
                description: 'Choose TRUE if you want build and deploy image with release tag')
  }


    stages {
        stage('Checkout branch') {
            steps{
                // Checkout branch
                git branch: "${params.BRANCH}", credentialsId: 'github-credentials', url: 'git@github.com:vhryshchenko-source/k8-practice.git'
            }
        }
        stage('Checkout git commit') {
            when {
              expression {
                params.COMMIT_ID != ''
              }
            }
            steps{
                // Checkout commit
                checkout(
                    [$class: 'GitSCM', 
                    branches: [[name: "${params.COMMIT_ID}"]],
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
                    echo $BUILD_RELEASE
                    echo $GIT_COMMIT
                    echo $COMMIT_ID
                    echo $GIT_BRANCH
                '''
            }
        }
        stage('Build image') {
          when {
            expression {
              BRANCH == 'develop' || BUILD_RELEASE == 'TRUE'
            }
          }
          steps {
            script {
                if ("${params.COMMIT_ID}" == '') {
                    container('docker') {
                    echo POD_CONTAINER
                    echo GIT_BRANCH
                    echo BRANCH
                    echo BUILD_RELEASE
                    sh '''
                        docker build --tag $DOCKER_REPO:$GIT_COMMIT --build-arg PYTHON_VERSION .
                        docker images
                    '''
                    }
                } else {
                    container('docker') {
                    sh '''
                        docker build --tag $DOCKER_REPO:$RELEASE_TAG --build-arg PYTHON_VERSION .
                        docker images
                    '''
                    }
                }
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
              BRANCH != 'develop' && BUILD_RELEASE == 'FALSE'
            }
          }
          environment {
              GIT_COMMIT = "${sh(script:'git rev-parse --verify HEAD', returnStdout: true).trim()}"
          }
          steps{
              script {
                  if (params.COMMIT_ID != '' ) {
                    container('docker') {
                        sh 'docker pull $DOCKER_REPO:$COMMIT_ID'
                    }
                  }
                  else {
                    container('docker') {
                      sh 'docker pull $DOCKER_REPO:$GIT_COMMIT'
                    }
                  }
              }
          }
        }
        stage('Push image from develop branch') {
          when {
            expression { 
              BRANCH == 'develop' && params.COMMIT_ID == ''
            }
          }  
          steps{
            container('docker') {
                sh 'docker push $DOCKER_REPO:$GIT_COMMIT'
            }
          }
        }
        stage('Push image from release branch') {
          when {
            expression { 
              BRANCH != 'develop'
            }
          }
          environment {
              GIT_COMMIT = "${sh(script:'git rev-parse --verify HEAD', returnStdout: true).trim()}"
          } 
            steps {
                script {
                  if (BUILD_RELEASE == 'TRUE' && params.COMMIT_ID != '' ) {
                    container('docker') {
                        sh 'echo Hi Realise'
                        sh 'docker push $DOCKER_REPO:$RELEASE_TAG'
                    }
                  }
                  if (BUILD_RELEASE == 'FALSE' && params.COMMIT_ID != '' ) {
                    container('docker') {
                        sh 'echo PUSH by secific commit without build'
                        sh 'docker tag $DOCKER_REPO:$COMMIT_ID $DOCKER_REPO:$RELEASE_TAG'
                        sh 'docker push $DOCKER_REPO:$RELEASE_TAG'
                    }
                  }
                  if (BUILD_RELEASE == 'FALSE' && params.COMMIT_ID == '' ) {
                    container('docker') {
                      sh 'echo push with build in release branch'
                      sh 'docker tag $DOCKER_REPO:$GIT_COMMIT $DOCKER_REPO:$RELEASE_TAG'
                      sh 'docker push $DOCKER_REPO:$RELEASE_TAG'
                    }
                  }
                }
            }
        }
    }
}
