FROM debian:latest

# Add a non-root user to prevent files being created with root permissions on host machine.
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}
ARG USER=sklearn
ENV USER ${USER}

RUN apt update && apt install -y sudo wget tini

# Create a group and user
RUN adduser -disabled-login -disabled-password ${USER} && usermod -aG sudo ${USER}

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN apt-get update && apt-get install -y build-essential

USER ${USER}
WORKDIR /home/${USER}/app

RUN sudo chown -R ${USER}:${USER} /home/${USER}/app

RUN mkdir -p ~/miniconda3 && \
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh && \
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3 && \
rm ~/miniconda3/miniconda.sh

ENV PATH=$PATH:/home/${USER}/miniconda3/bin
RUN echo $PATH

# installing jupyter and pandas
RUN conda install -y jupyter pandas 

# installing matplotlib and scikit-learn
RUN conda install -y matplotlib scikit-learn seaborn

# Tini is now available at /usr/bin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]

EXPOSE 8888

CMD ["jupyter", "notebook","--port=8888", "--no-browser","--ip=0.0.0.0"]