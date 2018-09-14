pipeline {
  agent none
  options {
    timeout(time: 15, unit: 'MINUTES')
  }

  stages {
    stage('Builds') {
        parallel {
            stage('Test Mac OS') {
              agent any
              steps {
                script {
                  sh './scripts/test.sh'
                }
              }
            }
        }
    }
  }
}

