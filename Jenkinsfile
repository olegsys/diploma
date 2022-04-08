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
        stage("Deploy to aws"){
            steps {
                withCredentials([aws(accessKeyVariable:'AWS_ACCESS_KEY_ID',credentialsId:'cloud_aws',secretKeyVariable:'AWS_SECRET_ACCESS_KEY')]){
                    sh '''
                      aws ec2 describe-instances
                    '''
                }
            }
        }  
    }
}