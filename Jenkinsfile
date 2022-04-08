#!groovy
// Check runner properties
properties([disableConcurrentBuilds()])

pipeline {
    agent {
        label 'docker'
    }
    triggers { pollSCM('* * * * *') }
    options {
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
        timestamps()
    }

    stages {  
        stage('Login to Dockerhub'){
            steps {
                echo '========Login to docker hub========='
                withCredentials([usernamePassword(credentialsId: 'dockerhub_olegsys', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]){
                    sh 'docker login -u $USERNAME -p $PASSWORD'
                }
            }
        } 
        stage("Docker build and push") {
            shortCommit = sh(returnStdout: true, script: "git log -n 1 --pretty=format:'%h'").trim()
            steps {                
                echo "${scmInfo.GIT_COMMIT}"
                echo '========WE are building docker image ========='
                sh 'docker build -t olegsys/diploma:${GIT_REVISION:0:7} .' 
                echo "=========PUSH Image to Registry========"
                sh 'docker push olegsys/diploma:${GIT_REVISION:0:7}'               
            }
        }  
        // stage("Test by SonarQube"){
        //     steps {
                
        //     }
        // }  
    }
}