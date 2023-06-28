# Base image for x86-64 architecture
FROM --platform=linux/amd64 docker:dind

# Create a non-root user
RUN addgroup -g 1001 appuser && adduser -u 1001 -G appuser -s /bin/sh -D appuser

# Install dependencies
RUN apk add --no-cache \
    curl \
    jq \
    git \
    iputils \
    nodejs \
    npm \
    ca-certificates \
    openssl

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
ENV NODE_VERSION=16
ENV NODE_PACKAGE=node_16.x

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

# Start the Azure DevOps agent
CMD ["./run.sh"]
