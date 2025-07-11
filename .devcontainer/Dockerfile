# Start from the Dev Containers Ubuntu base
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install system tools + Python + pip
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    && apt-get clean

# Install Terraform 1.12.2
RUN curl -fsSL https://releases.hashicorp.com/terraform/1.12.2/terraform_1.12.2_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/terraform \
    && rm terraform.zip

# Set default working directory
WORKDIR /workspace

CMD ["bash"]