
def backupRepository = 'github.com/Lakhtenkov-iv/test-rep.git'
def git_credentials = 'github.Lakhtenkov-iv'
def branch = 'master'
def timestamp = new Date().format( 'dd-MM-yyyy_HH-mm' )
def state = 'SUCCESS'
def current_stage = null


def mail() {
	def body = 
	
    def causes = currentBuild.rawBuild.getCauses()

    if (!causes.isEmpty()) {
        cause = causes[0].getShortDescription()
    }
    
    causes = null
    def log = currentBuild.rawBuild.getLog(40).join('\n')
	/*
    body = """
                    <p>Build $env.BUILD_NUMBER ran on $env.NODE_NAME and ended with $currentBuild.result .
                    </p>
                    <p><b>Build trigger</b>: $cause</p>
                    <p><b> Check response code</b>: $response </p>
                    <p>See: <a href="$env.BUILD_URL">$env.BUILD_URL</a></p>
                """
	*/
    if  (currentBuild.result != 'SUCCESS') {
        /*body = body + """
            <p><b>Failed on stage</b>: $current_stage</p>
            <h2>Last lines of output:</h2>
            <pre>$log</pre>
        """*/
		body = body + """ 
		<p><b>Failed on stage</b>: $current_stage</p>
		"""
    }

    emailext attachLog: true, body: body ,
                    compressLog: true, 
                    subject: "$env.JOB_NAME $env.BUILD_NUMBER: $currentBuild.result",
                    to: emailextrecipients([[$class: 'UpstreamComitterRecipientProvider'],
                                            [$class: 'FailingTestSuspectsRecipientProvider'],
                                            [$class: 'FirstFailingBuildSuspectsRecipientProvider'],
                                            [$class: 'CulpritsRecipientProvider'],
                                            [$class: 'DevelopersRecipientProvider'], 
                                            [$class: 'RequesterRecipientProvider']])
}

node{
	try {
		stage('PREPARATION') {
			current_stage = 'PREPARATION'
			try {
				step([$class: 'WsCleanup'])
				git url: "https://${backupRepository}", credentialsId: 'github.Lakhtenkov-iv', branch: branch
			}
			catch (Exception error){
				println ("PREPARATION Failed")
				throw error
			}
		}
		stage('BACKUP'){
			current_stage = 'BACKUP'
			try {
				sh """
					cd ${env.JENKINS_HOME}
					touch installed_plugins.txt
					cat /dev/null > installed_plugins.txt
					for i in `ls -d plugins/*/`; do
						echo \"\$(cat \$i/META-INF/MANIFEST.MF | grep Short-Name | cut -d ' ' -f 2 | tr -d '\n\r'):\$(cat \$i/META-INF/MANIFEST.MF | grep Plugin-Version | cut -d ' ' -f 2 | tr -d '\n\r')\" >> installed_plugins.txt
					done
					tar --exclude='./plugins/*' --exclude='./caches' --exclude='./war' --exclude='./workspace' -czf ${env.WORKSPACE}/jenkins_backup_${timestamp}.tar.gz ./*
					du -sh ${env.WORKSPACE}/jenkins_backup_${timestamp}.tar.gz
				"""
			}
			catch (Exception error){
				state ='FAILURE'
				println ("BACKUP FAILED")
				throw error
			}
		}
		stage ('PUSH TO REPOSITORY'){
			current_stage = 'PUSH TO REPOSITORY'
			try {
				sh "git add jenkins_backup_${timestamp}.tar.gz; git commit -m 'test'"
				sh "git tag -a ${timestamp} -m 'backup ${timestamp}'"
				withCredentials([[$class: 'UsernamePasswordMultiBinding', 
					credentialsId: git_credentials, 
					usernameVariable: 'GIT_USERNAME', 
					passwordVariable: 'GIT_PASSWORD']]) {    
						sh("git push https://${GIT_USERNAME}:${GIT_PASSWORD}@${backupRepository} --tags")
				}
			}
			catch (Exception error){
				state ='FAILURE'
				println ("PUSH FAILED")
				throw error
			}
		}
	}
	catch (Exception error){
        state ='FAILURE'
		throw error
	}
	finally {
		if (!currentBuild.result){
            currentBuild.result=state
        }
		if  (currentBuild.result != 'SUCCESS') {
			mail()
		}
		mail()
	}
}
