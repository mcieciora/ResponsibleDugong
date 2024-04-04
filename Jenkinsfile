def jenkinsImage

pipeline {
    agent any
    environment {
        DOCKERHUB_REPO = "mcieciora/responsible_dugong"
    }
    stages {
        stage ("Build Jenkins image") {
            steps {
                script {
                    jenkinsImage = docker.build("${DOCKERHUB_REPO}:jenkins_image")
                }
            }
        }
        stage ("Analyze image") {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "dockerhub_id", usernameVariable: "USERNAME", passwordVariable: "PASSWORD")]) {
                        sh "docker login --username $USERNAME --password $PASSWORD"
                    }
                    sh "docker scout cves ${DOCKERHUB_REPO}:jenkins_image"
                }
            }
        }
        stage ("Run Jenkins instance tests") {
            steps {
                script {
                    sh "chmod +x scripts/test_jenkins_setup.sh"
                    sh "scripts/test_jenkins_setup.sh"
                }
            }
        }
        stage ("Push image") {
            steps {
                script {
                    docker.withRegistry("", "dockerhub_id") {
                        def curDate = new Date().format("yyMMdd-HHmm", TimeZone.getTimeZone("UTC"))
                        jenkinsImage.push("test-${curDate}")
                        if (env.BRANCH_NAME == "master") {
                            jenkinsImage.push("latest")
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            sh "docker stop test_jenkins_instance"
            sh "docker container rm test_jenkins_instance"
            sh "docker rmi ${DOCKERHUB_REPO}:jenkins_image"
            sh "docker logout"
            dir("${WORKSPACE}") {
                deleteDir()
            }
        }
    }
}