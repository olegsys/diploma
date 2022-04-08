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
        stage("Docker build") {
            steps {
                echo '========WE are building docker image ========='
                dir ('docker/toolbox') {
                    sh 'docker build -t olegsys/diploma:latest .'
                }
            }
        }  
        stage("Docker push"){
            steps {
                echo "=========PUSH Image to Registry========"
                sh 'docker push olegsys/diploma:latest'
            }
        }  
    }
}