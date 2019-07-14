FROM openjdk:8-jdk-slim

LABEL maintainer "Michael K. Essandoh <mexcon.mike@gmail.com>"

ARG USER=flutter
ARG USER_HOME=/home/flutter
ARG GRADLE_VERSION=5.5.1
ARG ANDROID_SDK_VERSION=4333796
ARG FLUTTER_VERSION=v1.7.8+hotfix.3-stable
ARG RUBY_VERSION=2.6.3

ENV ANDROID_HOME $USER_HOME/android-sdk
ENV GRADLE_HOME $USER_HOME/gradle
ENV FLUTTER $USER_HOME/flutter
ENV PATH ${PATH}:${GRADLE_HOME}/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin:${FLUTTER}/bin
ENV _JAVA_OPTIONS -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap
ENV LD_LIBRARY_PATH ${ANDROID_HOME}/emulator/lib64:${ANDROID_HOME}/emulator/lib64/qt/lib

RUN apt-get update && \
    apt-get install -y --no-install-recommends lib32stdc++6 wget curl unzip xz-utils gnupg2 dirmngr procps ruby-dev rubygems git \
                                                g++ gcc autoconf automake bison patch bzip2 gawk libc6-dev libffi-dev libgdbm-dev libncurses5-dev \
                                                libsqlite3-dev libtool libyaml-dev make pkg-config sqlite3 zlib1g-dev libgmp-dev libreadline-dev libssl-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*;

# create a new user, and set up environment
RUN useradd -ms /bin/bash flutter && \
    echo progress-bar >> ~/.curlrc
WORKDIR $USER_HOME
USER $USER

# switch shell to bash
SHELL ["/bin/bash", "-c"]

# Ruby
RUN mkdir ~/.gnupg && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf && \
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
    curl -sSL https://get.rvm.io | bash -s stable && \
    source ~/.rvm/scripts/rvm && \
    rvm version && \
    rvm get stable --autolibs=read-fail && \
    rvm install ruby-$RUBY_VERSION && \
    rvm --default use ruby-$RUBY_VERSION && \
    gem install bundler

# Gradle
# https://services.gradle.org/distributions/
RUN wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip gradle*.zip && \
    ls -d */ | sed 's/\/*$//g' | xargs -I{} mv {} gradle && \
    rm gradle*.zip && \
    gradle wrapper --gradle-version $GRADLE_VERSION

# Android SDK
# https://developer.android.com/studio/#downloads
RUN mkdir -p ${ANDROID_HOME} && cd ${ANDROID_HOME} && \
    wget -q https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip && \
    unzip *tools*linux*.zip && \
    rm *tools*linux*.zip

# Flutter
# https://flutter.dev/docs/get-started/install/linux
RUN wget -q https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}.tar.xz && \
    tar xf flutter*.xz && \
    rm -rf flutter_linux_*.tar.xz

# set up sdk (android pie)
RUN yes | sdkmanager --licenses && \
    sdkmanager --update && \
    sdkmanager "platform-tools" "platforms;android-29" "build-tools;29.0.1"

# set up flutter
RUN flutter config --no-analytics && \
    flutter doctor