ARG tomcat_version=7.0.82
ARG jre_version=jre8

FROM tomcat:${tomcat_version}-${jre_version}

ARG ords_install_pkg=ords.current.zip

COPY ${ords_install_pkg} ./ords.current.zip

COPY entrypoint.sh entrypoint.sh

RUN chmod +x entrypoint.sh

RUN mkdir i

VOLUME ["/usr/local/tomcat/webapps/i"]

ENTRYPOINT ["./entrypoint.sh","run"]