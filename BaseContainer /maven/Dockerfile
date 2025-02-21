FROM harbor.189ip.cn:18000/gysk_basis/openjdk:8-latest

ADD apache-maven-3.6.3-bin.tar.gz /usr/local/
RUN ln -s /usr/local/apache-maven-3.6.3 /usr/local/maven

ENV MAVEN_HOME="/usr/local/maven"
ENV PATH="/usr/local/maven/bin:${PATH}"