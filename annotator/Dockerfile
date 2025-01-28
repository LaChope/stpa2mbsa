FROM httpd

# Install pre-reqs
RUN apt-get update
RUN apt-get install -y curl vim sudo wget rsync
RUN apt-get install -y apache2
RUN apt-get install -y supervisor
RUN apt-get install -y default-jre
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install dependencies for building Python 2
RUN apt-get update && apt-get install -y \
    curl vim sudo wget rsync \
    build-essential \
    libssl-dev zlib1g-dev libncurses5-dev \
    libsqlite3-dev libbz2-dev libreadline-dev \
    libffi-dev && \
    apt-get clean

# Download and compile Python 2.7.18
RUN curl -O https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz && \
    tar xzf Python-2.7.18.tgz && \
    cd Python-2.7.18 && \
    ./configure && make && make install && \
    cd .. && rm -rf Python-2.7.18*

# Fetch  brat
RUN mkdir /var/www/brat

COPY ./config/brat-v1.3_Crunchy_Frog.tar.gz /usr/local/apache2/htdocs/brat-v1.3_Crunchy_Frog.tar.gz
RUN cd /usr/local/apache2/htdocs && tar -xvzf brat-v1.3_Crunchy_Frog.tar.gz && mv brat-v1.3_Crunchy_Frog brat
COPY cgi-bin /usr/local/apache2/htdocs/brat
RUN chmod +x /usr/local/apache2/htdocs/brat/*.sh

RUN #apt-get update && apt-get install -y python
ADD ./config/httpd.conf /usr/local/apache2/conf/
ADD ./config/install.sh /usr/local/apache2/htdocs/brat/
RUN mkdir -p /usr/local/apache2/htdocs/brat/bin
ADD ./config/process-annotations.sh /usr/local/apache2/htdocs/brat/bin/

# create a symlink so users can mount their data volume at /brat-data rather than the full path
RUN mkdir -p /brat-data
RUN ln -s /brat-data /usr/local/apache2/htdocs/brat/data

ENV BRAT_USERNAME brat
ENV BRAT_PASSWORD brat
ENV BRAT_ADMIN_EMAIL blcham@gmail.com

VOLUME /brat-data

# Install gate-tools
COPY ./config/gate-tools.jar /opt/java-libs/gate-tools.jar
COPY ./config/gate-tools.sh /opt/java-libs/gate-tools.sh

CMD /usr/local/apache2/htdocs/brat/install.sh $BRAT_USERNAME $BRAT_PASSWORD $BRAT_ADMIN_EMAIL && httpd-foreground
