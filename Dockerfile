FROM openjdk:8-jdk-slim

LABEL maintainer "Michael K. Essandoh <mexcon.mike@gmail.com>"

ARG GRADLE_VERSION=5.5.1
ARG ANDROID_SDK_VERSION=4333796
ARG FLUTTER_VERSION=v1.7.8+hotfix.3-stable

ENV ANDROID_HOME /opt/android-sdk
ENV GRADLE_HOME /opt/gradle
ENV FLUTTER /opt/flutter
ENV PATH ${PATH}:${GRADLE_HOME}/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin:${FLUTTER}/bin
ENV _JAVA_OPTIONS -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap
ENV LD_LIBRARY_PATH ${ANDROID_HOME}/emulator/lib64:${ANDROID_HOME}/emulator/lib64/qt/lib

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends libncurses5:i386 libc6:i386 libstdc++6:i386 lib32gcc1 lib32z1 zlib1g:i386 \
                                               gnupg2 dirmngr git wget curl unzip xz-utils procps rubygems && \
    apt-get clean && rm -rf /var/lib/apt/lists/*;

WORKDIR /opt

# Gradle
# https://services.gradle.org/distributions/
RUN wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip gradle*.zip && \
    ls -d */ | sed 's/\/*$//g' | xargs -I{} mv {} gradle && \
    rm gradle*.zip

# Android SDK
# https://developer.android.com/studio/#downloads
RUN mkdir -p ${ANDROID_HOME} && cd ${ANDROID_HOME} && \
    wget -q https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip && \
    unzip *tools*linux*.zip && \
    rm *tools*linux*.zip

# Flutter
# https://flutter.dev/docs/get-started/install/linux
RUN wget https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}.tar.xz && \
    tar xf /opt/flutter*.xz && \
    rm -rf /opt/flutter_linux_*.tar.xz

# switch shell to bash
SHELL ["/bin/bash", "-c"]

# Ruby
RUN mkdir ~/.gnupg && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf && \
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
    curl -sSL https://get.rvm.io | bash -s stable --ruby && \
    source /usr/local/rvm/scripts/rvm && \
    rvm version && \
    rvm get stable --autolibs=enable && \
    usermod -a -G rvm root && \
    rvm install ruby-2.6.3 && \
    rvm --default use ruby-2.6.3 && \
    gem install bundler

# set up sdk (android pie)
RUN yes | sdkmanager --licenses && \
    sdkmanager --update && \
    sdkmanager "platform-tools" "platforms;android-29" "build-tools;29.0.1"

# set up flutter
RUN flutter config --no-analytics
RUN flutter doctor