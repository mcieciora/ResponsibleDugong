pipeline {
    agent any
    stages {
        stage ("Checkout branch") {
            steps {
                script {
                    git branch: "feature/move_casc_from_careless_vaquita", url: "https://github.com/mcieciora/ResponsibleDugong.git"
                }
            }
        }
        stage ("Build Jenkins image") {
            steps {
                script {
                    sh "docker build -t jenkins_image ."
                }
            }
        }
        stage ("Analyze image") {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "dockerhub_id", usernameVariable: "USERNAME", passwordVariable: "PASSWORD")]) {
                        sh "docker login --username $USERNAME --password $PASSWORD"
                    }
                    sh "docker scout cves jenkins_image --exit-code --only-severity critical,high"
                }
            }
        }
        stage ("Launch Jenkins instance") {
            steps {
                script {
                    load("script/launch_jenkins.groovy")
                }
            }
        }
        stage ("Push image") {
            steps {
                script {
                    def customImage = docker.build("app_image")
                    customImage.push("mcieciora/responsible_dugong:${env.BUILD_ID}")
                }
            }
        }
    }
    post {
        always {
            sh "docker rmi app_image"
            sh "docker logout"
            dir("${WORKSPACE}") {
                deleteDir()
            }
        }
    }
}