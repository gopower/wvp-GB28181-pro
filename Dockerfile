FROM ubuntu:20.04   as   build

ARG gitUrl="https://github.com/648540858"

RUN export DEBIAN_FRONTEND=noninteractive &&\
        apt-get update && \
        apt-get install -y --no-install-recommends openjdk-11-jre git maven nodejs npm build-essential \
        cmake ca-certificates openssl &&\
        mkdir -p /opt/wvp/config /opt/wvp/heapdump /opt/wvp/config /opt/assist/config /opt/assist/heapdump /opt/media/www/record

RUN cd /home && \
        git clone "${gitUrl}/maven.git" && \
        cp maven/settings.xml /usr/share/maven/conf/

RUN cd /home && \
        git clone "${gitUrl}/wvp-GB28181-pro.git"
RUN cd /home/wvp-GB28181-pro/web_src && \
        npm install && \
        npm run build
RUN cd /home/wvp-GB28181-pro && \
        mvn clean package -Dmaven.test.skip=true && \
        cp /home/wvp-GB28181-pro/target/*.jar /opt/wvp/ && \
        cp /home/wvp-GB28181-pro/src/main/resources/application-docker.yml /opt/wvp/config/application.yml


FROM ubuntu:20.04

EXPOSE 18080/tcp
EXPOSE 5060/tcp
EXPOSE 5060/udp
EXPOSE 6379/tcp


ENV LC_ALL zh_CN.UTF-8

RUN export DEBIAN_FRONTEND=noninteractive &&\
        apt-get update && \
        apt-get install -y --no-install-recommends openjdk-11-jre ca-certificates language-pack-zh-hans && \
        apt-get autoremove -y && \
        apt-get clean -y && \
        rm -rf /var/lib/apt/lists/*dic

COPY --from=build /opt /opt
WORKDIR /opt/wvp
CMD ["sh", "run.sh"]
