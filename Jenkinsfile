pipeline {
    agent any
    environment {
        ECR_REGISTRY = '982081074169.dkr.ecr.us-east-1.amazonaws.com/nodejs-logo-server'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        AWS_REGION = 'us-east-1'
        ECS_CLUSTER = 'nodejs-logo-server-cluster'
        ECS_SERVICE = 'nodejs-logo-prod'
    }
    triggers {
        githubPush()
    }
    stages {
        stage('Build') {
            steps {
                sh 'npm install && npm test'
            }
        }
        stage('Dockerize') {
            steps {
                sh "docker build -t ${ECR_REGISTRY}:${IMAGE_TAG} ."
            }
        }
        stage('Push to ECR') {
            steps {
                sh '''
                  aws ecr get-login-password --region ${AWS_REGION} \
                  | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                  docker push ${ECR_REGISTRY}:${IMAGE_TAG}
                '''
            }
        }
        stage('Deploy to ECS') {
            steps {
                sh '''
                  aws ecs update-service \
                  --cluster ${ECS_CLUSTER} \
                  --service ${ECS_SERVICE} \
                  --force-new-deployment \
                  --region ${AWS_REGION}
                '''
            }
        }
    }
}
