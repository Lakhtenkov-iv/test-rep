
def backupRepository = 'https://github.com/Lakhtenkov-iv/test-rep.git'
def branch = 'master'
def state = 'SUCCESS'

node{
	try {
		stage('PREPARATION') {
			try {
				step([$class: 'WsCleanup'])
				git url: backupRepository, credentialsId: 'github.Lakhtenkov-iv', branch: branch
			}
			catch (Exception error){
				println ("PREPARATION Failed")
				throw error
			}
		}
		stage('BACKUP'){
			try {
				sh """
					cd ${env.JENKINS_HOME}
					touch installed_plugins.txt
					cat /dev/null > installed_plugins.txt
					for i in `ls -d plugins/*/`; do
						echo \"\$(cat \$i/META-INF/MANIFEST.MF | grep Short-Name | cut -d ' ' -f 2 | tr -d '\n\r'):\$(cat \$i/META-INF/MANIFEST.MF | grep Plugin-Version | cut -d ' ' -f 2 | tr -d '\n\r')\" >> installed_plugins.txt
					done
					tar --exclude='./plugins/*' --exclude='./backup' --exclude='./war' --exclude='./workspace' -czf ${env.WORKSPACE}/jenkins_backup_\$(date "+%F--%H-%M").tar.gz ./*
				"""
			}
			catch (Exception e){
				state ='FAILURE'
				println ("BACKUP FAILED")
				throw error
			}
		}
		stage ('PUSH TO REPOSITORY'){
			try {
				//gitPublisher branchesToPush: [[branchName: 'master']], credentialsId: 'cred.master.builder', url: backupRepository
				//gitPublisher branchesToPush: [[branchName: 'master']], credentialsId: 'github.Lakhtenkov-iv', url: backupRepository
				println ("Push stage")
				
			}
			catch (Exception e){
				state ='FAILURE'
				println ("PUSH FAILED")
				throw error
			}
		}
	}
	catch (Exception e){
        state ='FAILURE'
		throw error
	}
	finally {
		println ("Build finished")
        //if (!currentBuild.result){
        //    currentBuild.result=state
        //}
        //mail()
	}
}
