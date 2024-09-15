FROM ubuntu:24.04

# Create the akatama user and change to akatama's home directory
RUN apt-get update && apt-get install sudo adduser -y \
    && adduser akatama && passwd -d akatama && usermod -aG sudo akatama 
USER akatama
WORKDIR /home/akatama

# Install Ansible, .NET 8.0, neovim, PowerShell
# and prereqs to Azure Cli and OpenTofu
RUN sudo apt-get update && sudo apt-get install -y software-properties-common \
    && sudo apt-add-repository ppa:ansible/ansible \
    && sudo apt-get install -y dotnet-sdk-8.0 aspnetcore-runtime-8.0 ansible \
    neovim apt-transport-https ca-certificates curl gnupg lsb-release git \
    lua5.4 unzip golang-go build-essential \
    && dotnet tool install --global PowerShell

# install OpenTofu
RUN curl --proto '=https' --tlsv1.2 -fsSL \
    https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh \
    && chmod +x install-opentofu.sh \
    && ./install-opentofu.sh --install-method deb \
    && rm -f install-opentofu.sh

# instadll Azure-Cli
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash && az bicep install

# Error installing Azure-Cli after I added the below dependenices
# So I have removed them until after Azure-Cli is done
RUN sudo apt-get install -y gzip nodejs npm python3-pip python3.12-venv

# Download neovim configuration
RUN git clone https://github.com/Akatama/nvim-config.git .config/nvim
RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# Update the PATH environment variable
ENV PATH="~/.dotnet/tools:$PATH"

ENTRYPOINT [ "/bin/bash" ]

