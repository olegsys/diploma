#!groovy
// Check runner properties
properties([disableConcurrentBuilds()])

pipeline {
    agent none
    triggers { pollSCM('* * * * *') }
    options {
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
        timestamps()
    }
    environment {
        AWS_DEFAULT_REGION='us-east-1'
    }
    stages {  
        // stage("Docker build and push") {
        //     steps {     
        //         echo '========Building docker image ========='                
        //         sh 'docker build -t olegsys/diploma:$GIT_BRANCH-$GIT_COMMIT -t olegsys/diploma:latest .'
        //         echo '========Login to docker hub========='
        //         withCredentials([usernamePassword(credentialsId: 'dockerhub_olegsys', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]){
        //             sh 'docker login -u $USERNAME -p $PASSWORD'
        //         } 
        //         echo "=========PUSH Image to Registry========"
        //         sh 'docker push olegsys/diploma:$GIT_BRANCH-$GIT_COMMIT'
        //         sh 'docker push olegsys/diploma:latest'
        //     }
        // }  
        stage("Deploy dev to k8s"){
            agent {
                docker { image 'alpine/k8s:1.20.7' }
            }
            when {
                branch 'develop'
            }
            steps {
                withCredentials([file(credentialsId: 'jenkins-token', variable: 'jenkins-token')]){
                    sh 'kubectl config set-credentials jenkins --token=$jenkins-token'

                }
            }
        }  
    }
}