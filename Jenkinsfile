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
        stage("Build Jenkins image") {
            steps {
                script {
                    sh "docker build -t jenkins_image ."
                }
            }
        }
        stage ("Launch Jenkins instance") {
            steps {
                script {
                    sh "python scripts/launch_jenkins.py"
                }
            }
        }
    }
    post {
        always {
            dir("${WORKSPACE}") {
                deleteDir()
            }
        }
    }
}