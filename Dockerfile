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
                                                build-essential zlib1g-dev libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev \
                                                libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev && \
                                                ruby && \
    apt-get clean && rm -rf /var/lib/apt/lists/*;

RUN gem install bundler

# create a new user, and set up environment
RUN useradd -ms /bin/bash flutter && \
    echo progress-bar >> ~/.curlrc
WORKDIR $USER_HOME
USER $USER

# switch shell to bash
SHELL ["/bin/bash", "-c"]

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