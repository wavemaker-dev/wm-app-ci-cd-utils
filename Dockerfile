FROM tomcat:8.5.50
COPY ./target/*.war /usr/local/tomcat/webapps/

