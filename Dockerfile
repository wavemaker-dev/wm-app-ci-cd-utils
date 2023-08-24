FROM tomcat:9.0.78
COPY ./target/*.war /usr/local/tomcat/webapps/

