FROM jupyter/scipy-notebook

USER root

# Spark dependencies
ENV APACHE_SPARK_VERSION 2.2.0
ENV HADOOP_VERSION 2.8.0

RUN apt-get -y update && \
    apt-get install --no-install-recommends -y openjdk-8-jre-headless ca-certificates-java lzop awscli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Hadoop

RUN cd /tmp && \
    wget -q http://mirrors.gigenet.com/apache/hadoop/common/hadoop-2.8.0/hadoop-2.8.0.tar.gz && \
    tar xzf hadoop-${HADOOP_VERSION}.tar.gz -C /opt/ && \
    rm hadoop-${HADOOP_VERSION}.tar.gz
RUN cd /opt/ && ln -s hadoop-${HADOOP_VERSION} hadoop

# Install Spark
RUN cd /tmp && \
    aws s3 cp s3://q.app/installs/spark-${APACHE_SPARK_VERSION}-without-hadoop-with-hive.tgz . && \
    tar xzf spark-${APACHE_SPARK_VERSION}-without-hadoop-with-hive.tgz -C /opt/ && \
    rm spark-${APACHE_SPARK_VERSION}-without-hadoop-with-hive.tgz
RUN cd /opt/ && ln -s spark-2.2.0-without-hadoop-with-hive spark

COPY spark-defaults.conf /opt/spark/conf/
COPY spark-env.sh /opt/spark/conf/

# Additional Jars
RUN cd /opt/spark/jars && \
    wget -q http://central.maven.org/maven2/org/apache/hadoop/hadoop-aws/2.8.0/hadoop-aws-2.8.0.jar && \
    wget -q http://central.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.128/aws-java-sdk-bundle-1.11.128.jar && \
    aws s3 cp s3://q.app/installs/hadoop-2.8.0-lzo-0.4.21-SNAPSHOT.jar .

# Spark config
ENV SPARK_HOME /opt/spark
ENV HADOOP_HOME /opt/hadoop
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.4-src.zip
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info

RUN SPARK_DIST_CLASSPATH=$(/opt/hadoop/bin/hadoop classpath)

USER $NB_USER
