# https://github.com/jboss-developer/jboss-eap-quickstarts/tree/main/helloworld


```bash
git clone https://github.com/kparent/jboss-helloworld.git




```bash
# https://github.com/jboss-developer/jboss-eap-quickstarts/tree/main/helloworld

git clone https://github.com/kparent/jboss-helloworld.git
cd dotcom-jboss-helloworld

mvn clean install

mvn clean package -DskipTests
ls -la /opt/wildfly/standalone/deployments/
---
-rw-r--r--. 1 501 games 8888 Dec  5  2023 README.txt
---


# target 디렉토리에 생성된 WAR 파일을 배포
sudo cp target/jboss-helloworld.war /opt/wildfly/standalone/deployments/


ls -la /opt/wildfly/standalone/deployments/
---
-rw-r--r--. 1  501 games 8888 Dec  5  2023 README.txt
-rw-r--r--. 1 root root  6642 Aug  6 00:54 jboss-helloworld.war
---




sudo /opt/wildfly/bin/standalone.sh -Djboss.http.port=8090
# 백그라운드로 실행하려면
sudo /opt/wildfly/bin/standalone.sh -Djboss.http.port=8090 &



curl -v http://localhost:8090/jboss-helloworld
http://54.148.19.101:8090/jboss-helloworld

http://kusjen.duckdns.org:8090/jboss-helloworld
```


## 재배포
```bash
# 1. 빌드
cd dotcom-jboss-helloworld
mvn clean package -DskipTests
# 2. 기존 WAR 파일 교체 (WildFly 실행 상태 유지)
sudo cp target/jboss-helloworld.war /opt/wildfly/standalone/deployments/








```

helloworld: Helloworld Example
===============================
Author: Pete Muir  
Level: Beginner  
Technologies: CDI, Servlet  
Summary: Basic example that can be used to verify that the server is configured and running correctly  
Target Product: EAP  
Product Versions: EAP 6.1, EAP 6.2, EAP 6.3  
Source: <https://github.com/jboss-developer/jboss-eap-quickstarts/>  

What is it?
-----------

This example demonstrates the use of *CDI 1.0* and *Servlet 3* in Red Hat JBoss Enterprise Application Platform.


System requirements
-------------------

The application this project produces is designed to be run on Red Hat JBoss Enterprise Application Platform 6.1 or later. 

All you need to build this project is Java 6.0 (Java SDK 1.6) or later, Maven 3.0 or later.
 
Configure Maven
---------------

If you have not yet done so, you must [Configure Maven](https://github.com/jboss-developer/jboss-developer-shared-resources/blob/master/guides/CONFIGURE_MAVEN.md#configure-maven-to-build-and-deploy-the-quickstarts) before testing the quickstarts.


Start the JBoss EAP Server
-------------------------

1. Open a command prompt and navigate to the root of the JBoss EAP directory.
2. The following shows the command line to start the server:

        For Linux:   EAP_HOME/bin/standalone.sh
        For Windows: EAP_HOME\bin\standalone.bat

 
Build and Deploy the Quickstart
-------------------------

_NOTE: The following build command assumes you have configured your Maven user settings. If you have not, you must include Maven setting arguments on the command line. See [Build and Deploy the Quickstarts](../README.md#build-and-deploy-the-quickstarts) for complete instructions and additional options._

1. Make sure you have started the JBoss EAP server as described above.
2. Open a command prompt and navigate to the root directory of this quickstart.
3. Type this command to build and deploy the archive:

        mvn clean install jboss-as:deploy

4. This will deploy `target/jboss-helloworld.war` to the running instance of the server.


Access the application 
---------------------

The application will be running at the following URL: <http://localhost:8080/jboss-helloworld>. 


Undeploy the Archive
--------------------

1. Make sure you have started the JBoss EAP server as described above.
2. Open a command prompt and navigate to the root directory of this quickstart.
3. When you are finished testing, type this command to undeploy the archive:

        mvn jboss-as:undeploy


Run the Quickstart in JBoss Developer Studio or Eclipse
-------------------------------------
You can also start the server and deploy the quickstarts from Eclipse using JBoss tools. For more information, see [Use JBoss Developer Studio or Eclipse to Run the Quickstarts](https://github.com/jboss-developer/jboss-developer-shared-resources/blob/master/guides/USE_JDBS.md#use-jboss-developer-studio-or-eclipse-to-run-the-quickstarts) 


Debug the Application
------------------------------------

If you want to debug the source code or look at the Javadocs of any library in the project, run either of the following commands to pull them into your local repository. The IDE should then detect them.

        mvn dependency:sources
        mvn dependency:resolve -Dclassifier=javadoc
