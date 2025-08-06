pipeline {
    agent any

    
    tools {
        jdk    'Java11'
        maven  'Maven3'
    }

    stages {
        stage('Checkout') {
            steps {
                // GitHub에서 소스 체크아웃
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/oebinu/kus_dotcom_jboss_demo.git'
                    ]]
                ])
            }
        }

        stage('Build WAR') {
            steps {
                // 현재 디렉토리 구조 확인
                sh 'pwd && ls -la'
                
                script {
                    // 디렉토리 존재 여부 확인
                    def dirExists = sh(script: "test -d dotcom-jboss-helloworld && echo 'exists' || echo 'not_exists'", returnStdout: true).trim()
                    echo ">>> dotcom-jboss-helloworld 디렉토리 존재 여부: ${dirExists}"
                    
                    if (dirExists == 'exists') {
                        // 디렉토리가 존재하는 경우
                        sh '''
                            cd dotcom-jboss-helloworld
                            mvn -U -s jboss-settings.xml \
                            -Dversion.war.plugin=3.2.3 \
                            -Dmaven.compiler.source=1.8 \
                            -Dmaven.compiler.target=1.8 \
                            clean install -DskipTests
                        '''
                    } else {
                        // 디렉토리가 존재하지 않는 경우 - 루트에서 실행
                        sh '''
                            mvn -U -s jboss-settings.xml \
                            -Dversion.war.plugin=3.2.3 \
                            -Dmaven.compiler.source=1.8 \
                            -Dmaven.compiler.target=1.8 \
                            clean install -DskipTests
                        '''
                    }
                }
                
                script {
                    def rev = sh(script: "git rev-parse --short=7 HEAD", returnStdout: true).trim()
                    
                    // WAR 파일 위치 확인
                    def warExists = sh(script: "test -f dotcom-jboss-helloworld/target/jboss-helloworld.war && echo 'subdir' || test -f target/jboss-helloworld.war && echo 'root' || echo 'none'", returnStdout: true).trim()
                    echo ">>> WAR 파일 위치: ${warExists}"
                    
                    if (warExists == 'subdir') {
                        env.WAR_FILE = "dotcom-jboss-helloworld/target/jboss-helloworld_${rev}.war"
                        sh "mv dotcom-jboss-helloworld/target/jboss-helloworld.war ${env.WAR_FILE}"
                    } else if (warExists == 'root') {
                        env.WAR_FILE = "target/jboss-helloworld_${rev}.war"
                        sh "mv target/jboss-helloworld.war ${env.WAR_FILE}"
                    } else {
                        error "WAR 파일을 찾을 수 없습니다!"
                    }
                    
                    env.IMG_TAG = "${rev}"
                    
                    // 빌드 정보 출력
                    echo ">>> WAR 파일: ${env.WAR_FILE}"
                    echo ">>> 이미지 태그: ${env.IMG_TAG}"
                    echo ">>> Git 커밋: ${rev}"
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

# JBoss/WildFly 실행
ENTRYPOINT ["sh","-c","/opt/jboss/wildfly/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0"]
'''
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    def repo = "443102424924.dkr.ecr.us-west-2.amazonaws.com/aws-kia-dotcom-eks"
                    def tag  = "jboss-runtime_${env.IMG_TAG}"

                    echo ">>> Docker 이미지 빌드 시작: ${repo}:${tag}"

                    // ECR 로그인
                    sh """
                      aws ecr get-login-password --region us-west-2 \
                        | docker login --username AWS --password-stdin ${repo}
                    """

                    // Docker 빌드 & 푸시
                    sh "docker build --build-arg WAR_FILE=${env.WAR_FILE} -t ${repo}:${tag} ."
                    sh "docker push ${repo}:${tag}"
                    
                    echo ">>> Docker 이미지 푸시 완료: ${repo}:${tag}"
                }
            }
        }
    }

    post {
        success {
            echo "✅ SUCCESS: JBoss 런타임 이미지 빌드·푸시 완료!"
            // Slack 알림이나 이메일 알림을 추가할 수 있습니다
        }
        failure {
            echo "❌ FAILURE: 빌드 실패. 로그를 확인하세요."
            // 실패 시 알림 설정 가능
        }
    }
}
