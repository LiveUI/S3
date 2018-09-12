pipeline {
  agent none
  options {
    timeout(time: 15, unit: 'MINUTES')
  }

  stages {
    stage('Builds') {
        parallel {
            stage('Build Linux') {
              agent any
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

