FROM harbor.189ip.cn:18000/gysk_basis/openjdk:8-latest

ADD apache-tomcat-9.0.98.tar.gz /usr/local/
RUN ln -s /usr/local/apache-tomcat-9.0.98 /usr/local/tomcat

ENTRYPOINT ["/usr/local/tomcat/bin/catalina.sh", "run"]