FROM debian:trixie
# Env vars
ENV APPIMAGE_EXTRACT_AND_RUN=1
ENV BUILT_IN_DOCKER=1

# Install and prep
RUN apt-get update \ 
&& DEBIAN_FRONTEND=noninteractive \
apt-get install -yqq --no-install-recommends \
  file build-essential sudo curl p7zip-full wget \
  libfuse-dev icoutils imagemagick nodejs npm dpkg-dev \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* \
&& useradd -m -d /github/workspace -u 1001 -s /bin/bash builder \
&& echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
&& chmod 0440 /etc/sudoers

WORKDIR /github/workspace
USER builder

# NVM installation
# Use bash for the shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# Create a script file sourced by both interactive and non-interactive bash shells
ENV BASH_ENV=/github/workspace/.bash_env
RUN touch "${BASH_ENV}"
RUN echo '. "${BASH_ENV}"' >> ~/.bashrc
RUN echo 'export APPIMAGE_EXTRACT_AND_RUN=1' >> ~/.bashrc
# Download and install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | PROFILE="${BASH_ENV}" bash
RUN echo node > .nvmrc
RUN nvm install lts/jod
#RUN npm i -g pnpm
#RUN pnpm install && pnpm install --no-save electron @electron/asar
RUN npm install --no-save electron @electron/asar

# Final entrypoint to let the other flags work by overriding CMD
CMD [ "--build", "appimage", "--clean", "yes" ]
ENTRYPOINT [ "/github/workspace/build.sh" ]

USER root
# Add the build scripts
ADD ./build.sh /github/workspace/build.sh
ADD ./scripts /github/workspace/scripts
RUN chown -R builder: /github/workspace
USER builder
