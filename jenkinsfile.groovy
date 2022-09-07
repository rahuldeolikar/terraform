pipeline {
    agent any

    stages {
        stage('git') {
            steps {
                git 'https://github.com/Pritam-Khergade/student-ui.git'
            }
        }
        stage('build') {
            steps {
                sh 'apt install maven -y'
                sh 'mvn clean package'
            }
        }
        stage('push 2 s3 bucket') {
            steps {
                sh 'apt install awscli -y'
                sh 'mv /var/lib/jenkins/workspace/jenkins-job/target/studentapp-2.2-SNAPSHOT.war /var/lib/jenkins/workspace/jenkins-job/target/student-${BUILD_ID}.war'
                sh 'aws s3 cp /var/lib/jenkins/workspace/jenkins-job/target/student-${BUILD_ID}.war s3://bucket-jenkins'
            }
        }
    }
}
