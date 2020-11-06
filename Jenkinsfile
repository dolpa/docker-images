pipeline {
    
    agent any

    triggers {
        // cron('H/4 * * * 1-5')
        pollSCM('H/4 0 * * *')
    }
    
    options {
        timestamps()
        ansiColor('xterm')
    }

    stages {
        stage('Build') {
            steps {
                // TODO: Need to ran gradle script with will build all docker images
                echo 'Building Docker Images ... '
                sh "./gradlew buildAllDockerImages"
            }
        }
        // TODO: need to create tests for each one of the images
        // stage('Test') {
        //     steps {
        //         echo 'Testing..'
        //     }
        // }
        stage('Deploy') {
            steps {
                // TODO: need to push all images to Docker Hub
                echo 'Pushing Docker Images to Hub ...'
                sh "./gradlew pushAllDockerImages"
            }
        }
    }
}