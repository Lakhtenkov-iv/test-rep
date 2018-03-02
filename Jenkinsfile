def awsCredentials = 'lakhtenkov_aws'
def bucketPath = "https://s3.amazonaws.com/ilakhtenkov-jenkins-backup/"
def bucketName = 'ilakhtenkov-jenkins-backup'
def timestamp = new Date().format( 'dd-MM-yyyy_HH-mm' )
def state = 'SUCCESS'
def current_stage = null

node{
	try {
		stage('PREPARATION') {
			current_stage = 'PREPARATION'
			try {
				step([$class: 'WsCleanup'])
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
					tar --exclude='./plugins/*' --exclude='./caches' --exclude='./backup' --exclude='./war' --exclude='./workspace' -czf ${env.WORKSPACE}/jenkins_backup_${timestamp}.tar.gz ./* 
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
				def files = findFiles(glob: '*.tar.gz')
				//echo """${files[0].name} ${files[0].path} ${files[0].directory} ${files[0].length} ${files[0].lastModified}""" 
				echo """${awsCredentials} ${files[0].name} ${bucketName}"""
				withAWS(credentials = "${awsCredentials}"){
					s3Upload(file: "${files[0].name}", bucket: "${bucketName}")
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
	}
}

