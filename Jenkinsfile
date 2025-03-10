pipeline {
    agent {
        label 'executor'
    }
    environment {
        DOCKERHUB_REPO = "mcieciora/responsible_dugong"
        DOCKERHUB_TAG = "no_tag"
        SCOUT_VERSION = "1.14.0"
    }
    stages {
        stage ("Build Jenkins image") {
            steps {
                script {
                    sh "docker build --no-cache -t jenkins_test_image ."
                }
            }
        }
        stage ("Analyze image") {
            parallel {
                stage ("Analyze Jenkins image") {
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
                stage ("Lint Docker files") {
                    steps {
                        script {
                            sh "chmod +x scripts/lint_docker_files.sh"
                            sh "scripts/lint_docker_files.sh"
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
        stage ("Run app & health check") {
            steps {
                script {
                    sh "chmod +x scripts/app_health_check.sh"
                    sh "scripts/app_health_check.sh 30 4"
                }
            }
            post {
                always {
                    sh "docker compose down --rmi all -v"
                }
            }
        }
        stage ("Push image") {
            steps {
                script {
                    docker.withRegistry("", "dockerhub_id") {
                        if (env.BRANCH_NAME == "develop") {
                            DOCKERHUB_TAG = "develop"
                        }
                        else if (env.BRANCH_NAME == "master") {
                            DOCKERHUB_TAG = "latest"
                        }
                        else {
                            def curDate = new Date().format("yyMMdd-HHmm", TimeZone.getTimeZone("UTC"))
                            DOCKERHUB_TAG = "test-${curDate}"
                        }
                        sh "docker tag jenkins_test_image ${DOCKERHUB_REPO}:${DOCKERHUB_TAG}"
                        sh "docker push ${DOCKERHUB_REPO}:${DOCKERHUB_TAG}"
                    }
                }
            }
        }
    }
    post {
        always {
            sh "docker compose down --rmi all -v"
            cleanWs()
        }
    }
}