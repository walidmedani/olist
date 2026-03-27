FROM apache/airflow:2.8.1

USER root

# Install Java
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk wget && \
    apt-get clean

# Set Java home
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

# Install Spark
ENV SPARK_VERSION=3.5.0
ENV HADOOP_VERSION=3
RUN wget -q https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    tar -xzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    mv spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} /opt/spark && \
    rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz

ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$SPARK_HOME/bin

# Switch to airflow user for pip installs
USER airflow

# Install Python dependencies
RUN pip install --no-cache-dir --user \
    apache-airflow-providers-google \
    pyspark==3.5.0 \
    kaggle \
    google-cloud-storage \
    google-cloud-bigquery \
    pandas