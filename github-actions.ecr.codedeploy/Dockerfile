FROM maven:3.8.1-jdk-11 as maven-java-node
ENV MAVEN_CONFIG=~/.m2
RUN mkdir -p /usr/local/content/node
WORKDIR /usr/local/content/node
ADD https://nodejs.org/dist/v12.22.3/node-v12.22.3-linux-x64.tar.gz .
RUN tar -xzf node-v12.22.3-linux-x64.tar.gz \
    && ln -s /usr/local/content/node/node-v12.22.3-linux-x64/bin/node /usr/local/bin/node \
    && ln -s /usr/local/content/node/node-v12.22.3-linux-x64/bin/npm /usr/local/bin/npm \
    && chown -R root:root /usr/local/content/node \
    && rm -fR node-v12.22.3-linux-x64.tar.gz

FROM maven-java-node as webapp-artifact
RUN mkdir -p /usr/local/content/app
ADD ./ /usr/local/content/app
WORKDIR /usr/local/content/app
ARG build_profile_name
ENV profile=${build_profile_name}
RUN  mvn clean install -P${profile}

FROM tomcat:9.0.62
COPY --from=webapp-artifact /usr/local/content/app/target/*.war /usr/local/tomcat/webapps/

