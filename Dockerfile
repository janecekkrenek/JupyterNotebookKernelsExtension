FROM jupyter/minimal-notebook:latest
LABEL maintainer=janecekkrenek@gmail.com description="Jupyter notebook with Python, .NET Core and Java kernels"

ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

USER root
# Praparation
RUN wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && wget https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip -O ijava-kernel.zip

RUN dpkg -i packages-microsoft-prod.deb

# Install .NET Core 3.1 SDK and Java SDK 11
RUN apt-get update \
    && apt-get install -y apt-utils \
    && apt-get install -y apt-transport-https \
    && apt-get install -y dotnet-sdk-3.1 \
    && apt-get install -y openjdk-11-jdk 
    
# Verification of installed Java SDK
RUN java -version
# Verification of installed .NET Core SDK 
RUN dotnet --version

# Install .NET Core Interactive  
RUN dotnet tool install -g Microsoft.dotnet-interactive

# Unpack and install the JAVA kernel to Jupyter
RUN unzip ijava-kernel.zip -d ijava-kernel \
  && cd ijava-kernel \
  && python3 install.py --sys-prefix

# Change permission for newly added things
RUN chown -R ${NB_UID} ${HOME}

# Cleaning phase
RUN rm -Rf ijava-kernel \
    && rm -f ijava-kernel.zip \
    && rm -f packages-microsoft-prod.deb

USER ${USER}

# Adding .DOT Net tool to path variable
ENV PATH="${PATH}:${HOME}/.dotnet/tools"

# Install .NET Core kernet to Jupyter
RUN dotnet interactive jupyter install --path /opt/conda/share/jupyter/kernels

# Display list of active Jupyter kernels
RUN jupyter kernelspec list