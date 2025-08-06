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
                    
                    // 전체 이미지 태그 저장 (배포용)
                    env.FULL_IMAGE_TAG = "${repo}:${tag}"
                }
            }
        }

        stage('Update Deployment YAML') {
            steps {
                script {
                    echo ">>> 배포 YAML 업데이트 시작"
                    
                    // GitHub Secret text credential을 사용하여 배포 저장소 클론
                    withCredentials([string(credentialsId: 'github-jenkins', variable: 'GITHUB_TOKEN')]) {
                        sh '''
                            rm -rf kus_dotcom_jboss_deploy
                            git clone https://${GITHUB_TOKEN}@github.com/oebinu/kus_dotcom_jboss_deploy.git
                            cd kus_dotcom_jboss_deploy
                            git config user.name "Jenkins CI"
                            git config user.email "jenkins@example.com"
                        '''
                        
                        // YAML 파일에서 이미지 태그 업데이트
                        sh """
                            cd kus_dotcom_jboss_deploy
                            echo ">>> 현재 deployment.yaml 내용:"
                            cat jboss_sample/01_jboss_deployment.yaml | grep -B2 image:
                            
                            sed -i 's|image: .*|image: ${env.FULL_IMAGE_TAG}|g' jboss_sample/01_jboss_deployment.yaml
                            
                            echo ">>> 업데이트된 deployment.yaml 내용:"
                            cat jboss_sample/01_jboss_deployment.yaml | grep -B2 image:
                        """
                        
                        // 변경사항 커밋 및 푸시
                        sh """
                            cd kus_dotcom_jboss_deploy
                            git add jboss_sample/01_jboss_deployment.yaml
                            git commit -m "Update JBoss image tag to ${env.FULL_IMAGE_TAG} - Build ${env.BUILD_NUMBER}"
                            git push https://${GITHUB_TOKEN}@github.com/oebinu/kus_dotcom_jboss_deploy.git main
                        """
                    }
                    
                    echo ">>> 배포 YAML 업데이트 완료: ${env.FULL_IMAGE_TAG}"
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
                🚀 JBoss 빌드 및 배포 완료 정보
                ================================================
                📁 소스 저장소: https://github.com/oebinu/kus_dotcom_jboss_demo.git
                📁 배포 저장소: https://github.com/oebinu/kus_dotcom_jboss_deploy.git
                🏷️  Git 커밋: ${env.GIT_COMMIT?.take(7) ?: 'unknown'}
                📦 WAR 파일: ${env.WAR_FILE ?: 'N/A'}
                🐳 Docker 이미지: ${env.FULL_IMAGE_TAG ?: 'N/A'}
                📄 Dockerfile: ./Dockerfile
                📄 배포 YAML: jboss_sample/01_jboss_deployment.yaml
                ⏰ 빌드 시간: ${new Date()}
                ================================================
                """
                echo buildInfo
            }
        }
        success {
            echo "✅ SUCCESS: JBoss 런타임 이미지 빌드·푸시 및 배포 YAML 업데이트 완료!"
        }
        failure {
            echo "❌ FAILURE: 빌드 또는 배포 업데이트 실패. 로그를 확인하세요."
        }
        cleanup {
            // 임시 디렉토리 정리
            sh 'rm -rf kus_dotcom_jboss_deploy || true'
        }
    }
}
