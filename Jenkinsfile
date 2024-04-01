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
        stage ("Launch Jenkins instance") {
            steps {
                script {
                    println("Tests to be implemented")
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
            sh "docker rmi ${DOCKERHUB_REPO}:jenkins_image"
            sh "docker logout"
            dir("${WORKSPACE}") {
                deleteDir()
            }
        }
    }
}