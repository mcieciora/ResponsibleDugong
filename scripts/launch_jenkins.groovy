import groovy.json.JsonSlurper
import groovyx.net.http.RESTClient
import groovyx.net.http.HttpResponseException
import java.net.URLEncoder

def launchJenkins() {
    def retryCount = 1
    def maxRetries = 12
    println("Launching Jenkins instance...")
    ["docker", "run", "-d", "--name", "test_jenkins_instance", "-p", "8085:8080", "jenkins_image"].execute().text
    def jenkinsRunning = false
    println("Sleeping for 5 seconds before checking boot status...")
    sleep(5000)
    while (!jenkinsRunning) {
        def dockerLogs = ["docker", "logs", "test_jenkins_instance"].execute().text
        if (dockerLogs.contains("Jenkins is fully up and running")) {
            println("Jenkins is ready.")
            jenkinsRunning = true
        } else {
            println("Jenkins is not fully booted yet, waiting 10 seconds...")
            sleep(10000)
            println("Retry: ${retryCount}/${maxRetries}.")
            retryCount++
        }
        if (retryCount > maxRetries) {
            println("Jenkins instance is not running after ${maxRetries*10} seconds. Terminating.")
            throw new Exception("JenkinsNotBooted")
        }
    }
}

def terminateJenkinsInstance() {
    println("Stopping Jenkins instance...")
    ["docker", "stop", "test_jenkins_instance"].execute().waitFor()
    println("Removing Jenkins container...")
    ["docker", "container", "rm", "test_jenkins_instance"].execute().waitFor()
    println("Removing Jenkins image...")
    ["docker", "rmi", "jenkins_image"].execute().waitFor()
}

def generateCrumbAndToken() {
    def client = new RESTClient('http://localhost:8085/')
    client.ignoreSSLIssues()
    println("Sending crumb request...")
    def response = client.get(path: 'crumbIssuer/api/xml?xpath=concat(//crumbRequestField,"%3A",//crumb)', auth: ['admin_user', 'password'])
    println("Got status ${response.status}. ${response.responseMessage}.")
    def crumbValue = response.data.text().split(":")[1]
    println("Crumb is ${crumbValue}.")
    println("Sending token generation request...")
    response = client.post(
        path: 'user/admin_user/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken',
        body: [newTokenName: "jenkins-token"],
        requestContentType: 'application/x-www-form-urlencoded',
        headers: ['Jenkins-Crumb': crumbValue],
        auth: ['admin_user', 'password']
    )
    println("Got status ${response.status}. ${response.responseMessage}.")
    def tokenValue = new JsonSlurper().parseText(response.data.text())['data']['tokenValue']
    println("Token value is ${tokenValue}.")
    def params = [delay: '0sec']
    println("Starting SetupDSLJobs build...")
    response = client.get(
        path: 'job/SetupDSLJobs/buildWithParameters?token=secret',
        query: params,
        auth: ['admin_user', tokenValue]
    )
    println("Got status ${response.status}. ${response.responseMessage}.")
    println("Sleeping for 30 seconds to let SetupDSLJobs finish...")
    sleep(30000)
    return tokenValue
}

def runTests(tokenValue) {
    def expectedJobsAndBranches = ["SetupDSLJobs", "PythonDependenciesVerification_CarelessVaquita",
                                   "MultibranchPipeline_CarelessVaquita", "ParametrizedTestPipeline_CarelessVaquita",
                                   "master", "develop"]
    def client = new RESTClient('http://localhost:8085/')
    client.ignoreSSLIssues()
    println("Getting list of all jobs...")
    def mainPage = client.get(path: 'api/json?pretty=true', auth: ['admin_user', tokenValue])
    println("Got status ${mainPage.status}. ${mainPage.responseMessage}")
    println("Getting list of all branches...")
    def multibranchPage = client.get(path: 'job/MultibranchPipeline_CarelessVaquita/api/json?pretty=true', auth: ['admin_user', tokenValue])
    println("Got status ${multibranchPage.status}. ${multibranchPage.responseMessage}.")
    def actualJobs = mainPage.data.jobs.name
    def actualBranches = multibranchPage.data.jobs.name
    expectedJobsAndBranches.each { job ->
        if (!(actualJobs + actualBranches).contains(job)) {
            println("${job} is not available in Jenkins instance.")
            throw new Exception("MissingJobOrBranch")
        }
    }
    println("Result: positive.")
}

if (this == this.binding.root) {
    launchJenkins()
    def token = generateCrumbAndToken()
    runTests(token)
    terminateJenkinsInstance()
}
