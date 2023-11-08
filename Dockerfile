FROM tomcat:9.0.82
COPY ./target/*.war /usr/local/tomcat/webapps/

