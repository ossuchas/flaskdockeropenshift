# mssql-python3.6-pyodbc
# Python runtime with pyodbc to connect to SQL Server
#FROM python:3
FROM ubuntu:18.04

# apt-get and system utilities
RUN apt-get update && apt-get install -y \
    curl apt-utils apt-transport-https debconf-utils gcc build-essential g++-5\
    && rm -rf /var/lib/apt/lists/*

# adding custom MS repository
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

# install libssl - required for sqlcmd to work on Ubuntu 18.04
RUN apt-get update && apt-get install -y libssl1.0.0 libssl-dev

# install SQL Server drivers
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql17 unixodbc-dev

# install SQL Server tools
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y mssql-tools
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"

# python libraries
RUN apt-get update && apt-get install -y \
    python3-pip python3-dev python3-setuptools \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# install necessary locales
RUN apt-get update && apt-get install -y locales \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen
RUN pip3 install --upgrade pip

# install SQL Server Python SQL Server connector module - pyodbc
RUN pip3 install pyodbc

# install additional utilities
RUN apt-get update && apt-get install gettext nano vim -y

# add sample code
#RUN mkdir /sample
#ADD . /sample
#WORKDIR /sample

#CMD /bin/bash ./entrypoint.sh
WORKDIR /home/ubuntu/src/app
COPY requirements.txt .

RUN pip install python-dotenv
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
#ENV PYTHONPATH "${PYTONPATH}:."
CMD ["python3", "app.py"]
