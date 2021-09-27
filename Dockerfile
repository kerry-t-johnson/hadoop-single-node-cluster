FROM ubuntu:20.04

ARG HADOOP_VER=3.3.1

RUN apt-get update                                          &&  \
    apt-get install -y  openjdk-11-jdk                          \
                        python-is-python3                       \
                        ssh                                     \
                        sudo                                    \
                        vim                                     \
                        wget

RUN useradd --create-home --user-group hdfs                 &&  \
    usermod -a -G sudo hdfs                                 &&  \
    echo "hdfs  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


ENV HADOOP_HOME=/opt/hadoop

RUN wget -q -O /var/tmp/hadoop-${HADOOP_VER}.tgz https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VER}/hadoop-${HADOOP_VER}.tar.gz && \
    tar -C /var/tmp -xzf /var/tmp/hadoop-${HADOOP_VER}.tgz  &&  \
    mv /var/tmp/hadoop-${HADOOP_VER}  ${HADOOP_HOME}        &&  \
    chown -R hdfs:hdfs  ${HADOOP_HOME}                      &&  \
    rm -f /var/tmp/hadoop-${HADOOP_VER}.tgz


RUN export HADOOP_ETC=${HADOOP_HOME}/etc/hadoop         &&  \
    export HADOOP_ENV=${HADOOP_ETC}/hadoop-env.sh       &&  \
    echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64" >> ${HADOOP_ENV} &&  \
    echo "export HDFS_NAMENODE_USER=hdfs"               >> ${HADOOP_ENV}    &&  \
    echo "export HDFS_DATANODE_USER=hdfs"               >> ${HADOOP_ENV}    &&  \
    echo "export HDFS_SECONDARYNAMENODE_USER=hdfs"      >> ${HADOOP_ENV}    &&  \
    echo "export YARN_RESOURCEMANAGER_USER=hdfs"        >> ${HADOOP_ENV}    &&  \
    echo "export YARN_NODEMANAGER_USER=hdfs"            >> ${HADOOP_ENV}    &&  \
    echo "export PATH=\${PATH}:\${HADOOP_HOME}/bin"     >> /etc/profile.d/01-hadoop.sh  &&  \
    echo "export PATH=\${PATH}:\${HADOOP_HOME}/sbin"    >> /etc/profile.d/01-hadoop.sh  &&  \
    chmod 644 /etc/profile.d/01-hadoop.sh

COPY docker-context/ssh_config                  /etc/ssh/
COPY docker-context/docker-entrypoint.sh        /usr/bin/
COPY --chown=hdfs:hdfs  docker-context/hadoop/* ${HADOOP_HOME}/etc/hadoop/

WORKDIR /home/hdfs
USER hdfs

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa                &&  \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys         &&  \
    chmod 0600 ~/.ssh/authorized_keys

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
