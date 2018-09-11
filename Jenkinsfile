pipeline {
  agent none
  options {
    timeout(time: 15, unit: 'MINUTES')
  }

  stages {
    stage('Builds') {
        parallel {
            stage('Build Linux') {
              agent {
                label 'master'
              }
              when {
                anyOf {
                  branch 'master'
                }
              }
              steps {
                script {
                  sh './scripts/docker-shortcuts/test.sh'
                }
              }
            }
        }
    }
  }
}

