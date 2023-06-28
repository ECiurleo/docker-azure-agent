# Base image for x86-64 architecture
FROM --platform=linux/amd64 ubuntu:latest

# Create a non-root user
RUN groupadd -r appuser && useradd -r -g appuser -m appuser

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libunwind8 \
    libssl-dev \
    libicu-dev \
    jq \
    git \
    iputils-ping \
    libcurl4 \
    libcurl3-gnutls \
    libkrb5-3 \
    zlib1g \
    icu-devtools \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Update ca-certificates
RUN update-ca-certificates

# Install Docker
RUN curl -fsSL https://get.docker.com -o get-docker.sh \
    && sh get-docker.sh \
    && rm get-docker.sh

# Set build arguments
ARG AZP_URL
ARG AZP_TOKEN
ARG AZP_POOL
ARG AZP_AGENT_NAME

# Set environment variables
ENV AGENT_VERSION="3.220.5"
ENV AGENT_PACKAGE_URL="https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz"
ENV AGENT_DIR="/azp"
ENV AZP_URL=$AZP_URL
ENV AZP_TOKEN=$AZP_TOKEN
ENV AZP_POOL=$AZP_POOL
ENV AZP_AGENT_NAME=$AZP_AGENT_NAME

# Create agent directory
RUN mkdir ${AGENT_DIR} && chown appuser:appuser ${AGENT_DIR}

# Switch to the non-root user
USER appuser

# Download and extract the agent package
RUN curl -LsS ${AGENT_PACKAGE_URL} | tar -xz -C ${AGENT_DIR}

# Set the working directory
WORKDIR ${AGENT_DIR}

# Configure the Azure DevOps agent
RUN ./config.sh --unattended \
    --url $AZP_URL \
    --auth pat \
    --token $AZP_TOKEN \
    --pool $AZP_POOL \
    --agent $AZP_AGENT_NAME \
    --acceptTeeEula

# Start Docker daemon
USER root
CMD dockerd &

# Start the Azure DevOps agent
USER appuser
CMD ["./run.sh"]
