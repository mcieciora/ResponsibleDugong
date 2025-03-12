pipeline {
    agent {
        label 'executor'
    }
    environment {
        DOCKERHUB_REPO = "mcieciora/responsible_dugong"
        DOCKERHUB_TAG = "no_tag"
        SHELLCHECK_VERSION = "v0.10.0"
        SCOUT_VERSION = "1.16.3"
        DIVE_VERSION = "v0.12"
        TRIVY_VERSION = "0.59.0"
    }
    stages {
        stage ("Build Jenkins image") {
            steps {
                script {
                    sh "docker build --no-cache -t jenkins_test_image ."
                }
            }
        }
        stage ("Linters") {
            parallel {
                stage ("Lint Dockerfiles") {
                    steps {
                        script {
                            sh "chmod +x scripts/lint_docker_files.sh"
                            sh "scripts/lint_docker_files.sh"
                        }
                    }
                }
                stage ("Shellcheck") {
                    steps {
                        script {
                            sh "chmod +x scripts/lint_shell_scripts.sh"
                            sh "scripts/lint_shell_scripts.sh"
                        }
                    }
                }
            }
        }
        stage ("Analyze image") {
//             when {
//                 expression {
//                     return env.BRANCH_NAME.contains("release") || env.BRANCH_NAME == "master" || env.BRANCH_NAME == "develop"
//                 }
//             }
            parallel {
                stage ("docker scout") {
                    steps {
                        script {
                            withCredentials([usernamePassword(credentialsId: "dockerhub_id", usernameVariable: "USERNAME", passwordVariable: "PASSWORD")]) {
                                sh "docker login --username $USERNAME --password $PASSWORD"
                                sh "chmod +x scripts/scan_docker_scout.sh"
                                return_value = sh(script: "scripts/scan_docker_scout.sh", returnStdout: true).trim()
                                if (return_value.contains("Script failed, because vulnerabilities were found.")) {
                                    unstable(return_value)
                                }
                            }
                        }
                    }
                }
                stage ("trivy") {
                    steps {
                        script {
                            sh "chmod +x scripts/scan_docker_trivy.sh"
                            return_value = sh(script: "scripts/scan_docker_trivy.sh", returnStdout: true).trim()
                            if (return_value.contains("Script failed, because vulnerabilities were found.")) {
                                unstable(return_value)
                            }
                        }
                    }
                }
                stage ("dive") {
                    steps {
                        script {
                            sh "chmod +x scripts/scan_docker_dive.sh"
                            return_value = sh(script: "scripts/scan_docker_dive.sh", returnStdout: true).trim()
                            if (return_value.contains("Script failed, because vulnerabilities were found.")) {
                                unstable(return_value)
                            }
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
                    sh "scripts/app_health_check.sh 30 6"
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
            sh "docker logout"
            sh "docker compose down --rmi all -v"
            archiveArtifacts artifacts: "scan_*", followSymlinks: false
            cleanWs()
        }
    }
}