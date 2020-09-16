FROM tomcat:8.5.50
COPY ./target/*.war /usr/local/tomcat/webapps/
RUN apt-get update && apt-get install vim -y

