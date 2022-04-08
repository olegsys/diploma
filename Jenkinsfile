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
    environment {
        shortCommit = sh(returnStdout: true, script: "git log -n 1 --pretty=format:'%h'").trim()
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
            steps {                
                echo '========WE are building docker image ========='
                sh 'docker build -t olegsys/diploma:$shortCommit .' 
                echo "=========PUSH Image to Registry========"
                sh 'docker push olegsys/diploma:$shortCommit'               
            }
        }  
        // stage("Test by SonarQube"){
        //     steps {
                
        //     }
        // }  
    }
}