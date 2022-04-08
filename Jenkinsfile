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
        currentBrunch = sh(returnStdout: true, script: "git branch --show-current")
    }
    stages {  
        stage("Docker build and push") {
            steps {     
                echo '========Building docker image ========='                
                sh 'docker build -t olegsys/diploma:$BRANCH_NAME-$shortCommit -t olegsys/diploma:latest .'
                echo '========Login to docker hub========='
                withCredentials([usernamePassword(credentialsId: 'dockerhub_olegsys', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]){
                    sh 'docker login -u $USERNAME -p $PASSWORD'
                } 
                echo "=========PUSH Image to Registry========"
                sh 'docker push olegsys/diploma:$BRANCH_NAME-$shortCommit'
                sh 'docker push olegsys/diploma:latest'
            }
        }  
        // stage("Test by SonarQube"){
        //     steps {
                
        //     }
        // }  
    }
}