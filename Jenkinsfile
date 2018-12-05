pipeline {
  agent any
  options {
    timeout(time: 15, unit: 'MINUTES')
  }

  stages {
    stage('Builds') {
        parallel {
            stage('Test') {
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

