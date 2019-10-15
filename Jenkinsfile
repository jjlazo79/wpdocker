@Library('sngular') _

pipeline {
    agent any
    environment {
        PROJECT_NAME = 'roots-website'
        IMAGE_NAME = ecrCommons.getImageName(PROJECT_NAME)
        GITLAB_TOKEN = gitlabCommons.getToken()
    }
    options {
        gitLabConnection('gitlab')
        buildDiscarder(logRotator(numToKeepStr: '5'))
        timeout(time: 5, unit: 'MINUTES')
    }
    triggers {
        gitlab(
            triggerOnPush: true,
            triggerOnMergeRequest: true,
            branchFilterType: 'All',
            skipWorkInProgressMergeRequest: true,
            acceptMergeRequestOnSuccess: false,
            secretToken: "${env.GITLAB_TOKEN}"
        )
    }
    stages {
        stage('build') {
            steps {
                script {
                    gitlabCommons.updateCommitState('running')
                }
                sh "docker image build -t ${IMAGE_NAME} ."
            }
        }
        stage('release') {
            stages {
                stage('ecr login') {
                    steps {
                        script {
                            ecrCommons.login()
                        }
                    }
                }
                stage('build') {
                    steps {
                        sh "docker image push ${IMAGE_NAME}"
                    }
                }
                stage('tag') {
                    when { tag "v*" }
                    steps {
                        script {
                            IMAGE_TAG_NAME = ecrCommons.getImageTagName(PROJECT_NAME)
                        }
                        sh "docker image tag ${IMAGE_NAME} ${IMAGE_TAG_NAME}"
                        sh "docker image push ${IMAGE_TAG_NAME}"
                    }
                }
            }
        }
        stage('trigger deployment') {
            when { branch 'master' }
            steps {
                script {
                    def (imageName, imageTag) = IMAGE_NAME.tokenize( ':' )
                    build job: 'ROOTS/roots-deployment/integration',
                        wait: false,
                        parameters: [
                            string(name: 'IMAGE_TAG', value: imageTag )
                        ]
                }
			}
        }
    }
    post {
		failure {
            script {
                gitlabCommons.updateCommitState('failed')
            }
		}
		success {
            script {
                gitlabCommons.updateCommitState('success')
            }
		}
    }
}