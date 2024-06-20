def jenkinsImage

pipeline {
    agent any
    environment {
        IMAGE_TAG = "test_jenkins_image"
    }
    stages {
        stage ("Build Jenkins image") {
            steps {
                script {
                    jenkinsImage = docker.build("${IMAGE_TAG}")
                }
            }
        }
        stage ("Analyze image") {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "dockerhub_id", usernameVariable: "USERNAME", passwordVariable: "PASSWORD")]) {
                        sh "chmod +x scripts/scan_jenkins_image.sh"
                        return_value = sh(script: "scripts/scan_jenkins_image.sh", returnStdout: true).trim()
                        if (return_value.contains("Script failed, because vulnerabilities were found.")) {
                            unstable(return_value)
                        }
                    }
                }
            }
        }
        stage ("Run tests on next Jenkins build") {
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
                        if (env.BRANCH_NAME == "develop") {
                            jenkinsImage.push("develop")
                        }
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
            sh "docker rmi ${IMAGE_TAG}"
            cleanWs()
        }
    }
}