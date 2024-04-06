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
                        sh "chmod +x scripts/scan_jenkins_image.sh"
                        sh "scripts/scan_jenkins_image.sh"
                    }
                }
            }
        }
        stage ("Run tests on next Jenkins build") {
            steps {
                script {
                    build job: "/TestOnNextJenkinsBuildPipeline", parameters: [string(name: "BRANCH", value: "${env.BRANCH}")]
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
            sh "docker rmi ${DOCKERHUB_REPO}:jenkins_image"
            cleanWs()
        }
    }
}