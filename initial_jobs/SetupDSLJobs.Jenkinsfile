pipeline {
    agent any
    parameters {
        string(name: "PROJECT_NAME", defaultValue: "CarelessVaquita", description: "Project name.")
        string(name: "PROJECT_URL", defaultValue: "https://github.com/mcieciora/CarelessVaquita.git", description: "Full github url to repository.")
        string(name: "BRANCH_NAME", "*/master", "Branch name.")
    }
    stages {
        stage ("Checkout branch") {
            steps {
                script {
                    git branch: "${BRANCH_NAME}", url: "${PROJECT_URL}"
                }
            }
        }
        stage("Generate template jobs") {
            steps {
                script {
                    dir("jobs") {
                        sh "sed -i 's~INPUT.PROJECT_NAME~${env.PROJECT_NAME}~g' *"
                        sh "sed -i 's~INPUT.PROJECT_URL~${env.PROJECT_URL}~g' *"
                    }
                    jobDsl targets: 'jobs/*'
                }
            }
        }
    }
}