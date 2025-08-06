pipeline {
    agent any

    
    tools {
        jdk    'Java11'
        maven  'Maven3'
    }

    stages {
        stage('Checkout & Build WAR') {
            steps {
                git url: 'https://github.com/oebinu/kus_dotcom_jboss_demo.git', branch: 'main'
                sh '''
                    mvn -U -s jboss-settings.xml \
                    -Dversion.war.plugin=3.2.3 \
                    -Dmaven.compiler.source=1.8 \
                    -Dmaven.compiler.target=1.8 \
                    clean install -DskipTests
                '''
                script {
                  def ts     = sh(script: "date +%Y%m%d%H%M%S", returnStdout: true).trim()
                  def rev    = sh(script: "git rev-parse --short=7 HEAD", returnStdout: true).trim()
                  env.WAR_FILE = "target/jboss-helloworld_${ts}_${rev}.war"
                  sh "mv target/jboss-helloworld.war ${env.WAR_FILE}"
                  env.IMG_TAG  = "${ts}-${rev}"
                }
            }
        }

        // JBoss/WildFly 기반 이미지 작성
        stage('Write Dockerfile') {
            steps {
                writeFile file: 'Dockerfile', text: '''\
FROM quay.io/wildfly/wildfly:31.0.0.Final-jdk17

EXPOSE 8080
EXPOSE 9990

ARG WAR_FILE
COPY ${WAR_FILE} /opt/jboss/wildfly/standalone/deployments/

# sh -c와 실행 커맨드를 한 줄의 JSON 배열로 작성
ENTRYPOINT ["sh","-c","/opt/jboss/wildfly/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0"]
'''
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    def repo = "443102424924.dkr.ecr.us-west-2.amazonaws.com/aws-kia-dotcom-eks"
                    def tag  = "jboss-runtime_${env.IMG_TAG}"

                    // ECR 로그인
                    sh """
                      aws ecr get-login-password --region us-west-2 \
                        | docker login --username AWS --password-stdin ${repo}
                    """

                    // 빌드 & 푸시
                    sh "docker build --build-arg WAR_FILE=${env.WAR_FILE} -t ${repo}:${tag} ."
                    sh "docker push ${repo}:${tag}"
                }
            }
        }
    }

    post {
        success {
            echo ">>> JBoss 런타임 이미지 빌드·푸시 완료: aws-kia-dotcom-eks:jboss-runtime_${env.IMG_TAG} <<<"
        }
        failure {
            echo '>>> 실패… 로그를 확인하세요. <<<'
        }
    }
}
