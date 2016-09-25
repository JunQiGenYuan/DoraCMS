FROM node:latest

# Update apt-get AND apt-get install git
# RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-utils && rm -rf /var/lib/apt/lists/*

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Clone doraCms from git
# ADD git://github.com/doramart/DoraCMS/archive/master.zip ./
#RUN git clone https://github.com/doramart/DoraCMS.git 
#RUN mv DoraCMS app
#WORKDIR app

# Install guide process
RUN npm install -g forever --registry=https://registry.npm.taobao.org


#Install app dependencies
COPY package.json /usr/src/app
RUN npm install --registry=https://registry.npm.taobao.org

# Copy project files
COPY . /usr/src/app

# Replace db config with the container link name instead of ip
WORKDIR models/db
RUN sed -i "s/mongodb\:\/\/127\.0\.0\.1/mongodb\:\/\/mongo/g" * && \
    sed -i "s/redis_host\:\s*'127\.0\.0\.1'/redis_host\: 'redis'/g" *

WORKDIR ../../

ENV PORT 7878

EXPOSE 81
EXPOSE 22

VOLUME /usr/src/app

CMD [ "forever", "-o", "out.log", "-e", "err.log", "bin/www" ]
