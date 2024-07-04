pipeline {
    agent any
    environment {
        DOCKERHUB_REPO = "mcieciora/responsible_dugong"
        SCOUT_VERSION = "1.10.0"
    }
    stages {
        stage ("Build Jenkins image") {
            steps {
                script {
                    sh "docker build -t test_image ."
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
                        if (env.BRANCH_NAME == "develop") {
                            sh "docker tag -t test_image $DOCKERHUB_REPO:develop"
                            sh "docker push $DOCKERHUB_REPO:develop"
                        }
                        else if (env.BRANCH_NAME == "master") {
                            sh "docker tag -t test_image $DOCKERHUB_REPO:latest"
                            sh "docker push $DOCKERHUB_REPO:latest"
                        }
                        else {
                            def curDate = new Date().format("yyMMdd-HHmm", TimeZone.getTimeZone("UTC"))
                            sh "docker tag -t test_image $DOCKERHUB_REPO:test-${curDate}"
                            sh "docker push $DOCKERHUB_REPO:test-${curDate}"
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
            sh "docker rmi ${DOCKERHUB_REPO}"
            cleanWs()
        }
    }
}