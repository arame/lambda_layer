# As of this writing, Lambda can support Python 3.9, but amazonlinux comes with Python 3.7.
# This makes it difficult to create a Layer using amazonlinux image.
# This Dockerfile will install Python 3.9 and automatically prepare the Layer file.

# Important note: The key is to build the Layer file with the right file STRUCTURE !!!

# How to use:
# 1. Make sure the latest Docker is installed.
# 2. mkdir layer
# 3. cd layer
# Copy this file into this folder and replace MY_LIBRARY with the library (can be multiple) you need for the layer

# 4. docker build -t my-layer .
# 5. docker run --name my-container my-layer
# 6. docker cp my-container:/opt/python-3.9.6/aws-layer/my-layer.zip .
# Your Layer is ready.

FROM amazonlinux:latest
RUN yum install gcc openssl-devel bzip2-devel libffi-devel gzip make -y
RUN yum install wget tar zip -y
WORKDIR /opt
RUN wget https://www.python.org/ftp/python/3.9.6/Python-3.9.6.tgz
RUN tar xzf Python-3.9.6.tgz
COPY requirements.txt /opt/Python-3.9.6/requirements.txt
WORKDIR /opt/Python-3.9.6
RUN ./configure --enable-optimizations
RUN make altinstall
RUN rm -f /opt/Python-3.9.6.tgz
RUN mkdir -p aws-layer/python/lib/python3.9/site-packages
RUN pip3.9 install -r requirements.txt -t aws-layer/python/lib/python3.9/site-packages
RUN cd aws-layer && zip -r9 my-layer.zip .