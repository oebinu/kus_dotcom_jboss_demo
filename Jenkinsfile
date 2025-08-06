pipeline {
    agent any

    triggers {
        // GitHub webhook 전용 트리거
        githubPush()
    }
    
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
                
                sh '''
                    mvn -U -s jboss-settings.xml \
                    -Dversion.war.plugin=3.2.3 \
                    -Dmaven.compiler.source=1.8 \
                    -Dmaven.compiler.target=1.8 \
                    clean install -DskipTests
                '''
                script {
                    def rev = sh(script: "git rev-parse --short=7 HEAD", returnStdout: true).trim()
                    env.WAR_FILE = "target/jboss-helloworld_${rev}.war"
                    sh "mv target/jboss-helloworld.war ${env.WAR_FILE}"
                    env.IMG_TAG = "${rev}"
                    
                    // 빌드 정보 출력
                    echo ">>> WAR 파일: ${env.WAR_FILE}"
                    echo ">>> 이미지 태그: ${env.IMG_TAG}"
                    echo ">>> Git 커밋: ${rev}"
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    def repo = "443102424924.dkr.ecr.us-west-2.amazonaws.com/aws-kia-dotcom-eks"
                    def tag  = "jboss-runtime_${env.IMG_TAG}"

                    echo ">>> Docker 이미지 빌드 시작: ${repo}:${tag}"
                    echo ">>> 사용할 Dockerfile: ./Dockerfile"
                    echo ">>> WAR 파일: ${env.WAR_FILE}"

                    // ECR 로그인
                    sh """
                      aws ecr get-login-password --region us-west-2 \
                        | docker login --username AWS --password-stdin ${repo}
                    """

                    // Docker 빌드 & 푸시 (기존 Dockerfile 사용)
                    sh "docker build --build-arg WAR_FILE=${env.WAR_FILE} -t ${repo}:${tag} -f Dockerfile ."
                    sh "docker push ${repo}:${tag}"
                    
                    echo ">>> Docker 이미지 푸시 완료: ${repo}:${tag}"
                }
            }
        }
    }

    post {
        always {
            // 빌드 정보 출력
            script {
                def buildInfo = """
                ================================================
                🚀 JBoss 빌드 완료 정보
                ================================================
                📁 Git 저장소: https://github.com/oebinu/kus_dotcom_jboss_demo.git
                🏷️  Git 커밋: ${env.GIT_COMMIT?.take(7) ?: 'unknown'}
                📦 WAR 파일: ${env.WAR_FILE ?: 'N/A'}
                🐳 Docker 이미지: aws-kia-dotcom-eks:jboss-runtime_${env.IMG_TAG ?: 'N/A'}
                📄 Dockerfile: ./Dockerfile
                ⏰ 빌드 시간: ${new Date()}
                ================================================
                """
                echo buildInfo
            }
        }
        success {
            echo "✅ SUCCESS: JBoss 런타임 이미지 빌드·푸시 완료!"
        }
        failure {
            echo "❌ FAILURE: 빌드 실패. 로그를 확인하세요."
        }
    }
}
