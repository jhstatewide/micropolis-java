FROM eclipse-temurin:17-jdk-jammy

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=/opt/java/openjdk/bin:${PATH}
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TZ=UTC
ENV JAVA_TOOL_OPTIONS=-Djava.awt.headless=true

RUN apt-get update \
	&& apt-get install -y --no-install-recommends ant \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
