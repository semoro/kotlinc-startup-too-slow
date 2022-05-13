# FROM eclipse-temurin:18.0.1_10-jdk-alpine as builder
# FROM eclipse-temurin:17.0.1_12-jdk-alpine as builder
# FROM adoptopenjdk/openjdk11:x86_64-alpine-jdk-11.0.13_8-slim as builder
FROM adoptopenjdk/openjdk11:x86_64-alpine-jdk-11.0.12_7-slim as builder

RUN mkdir /empty

# /dev/urandom & /etc/passwd may be needed.
RUN mkdir /mydev /myetc        \
 && mknod -m 444 /mydev/urandom c 1 9 \
 && echo nobody:x:99:99::/: > /myetc/passwd

RUN apk add --no-cache curl unzip bash strace build-base linux-headers

# RUN curl -L https://github.com/JetBrains/kotlin/releases/download/v1.7.0-Beta/kotlin-compiler-1.7.0-Beta.zip > kotlin.zip
RUN curl -L https://github.com/JetBrains/kotlin/releases/download/v1.6.21/kotlin-compiler-1.6.21.zip > kotlin.zip
# RUN curl -L https://github.com/JetBrains/kotlin/releases/download/v1.3.50/kotlin-compiler-1.3.50.zip > kotlin.zip
# RUN curl -L https://github.com/JetBrains/kotlin/releases/download/build-1.0.0/kotlin-compiler-1.0.0.zip > kotlin.zip

RUN unzip kotlin.zip

COPY run-in-sandbox.c /
COPY run-kotlin.c /
RUN gcc -o /usr/bin/run-in-sandbox -s -static run-in-sandbox.c
RUN gcc -o /usr/bin/run-kotlin -s -static run-kotlin.c

ENTRYPOINT ["/bin/bash"]

FROM scratch

COPY --from=0 /kotlinc/build.txt        /rootfs/kotlinc/
COPY --from=0 /kotlinc/bin              /rootfs/kotlinc/bin
COPY --from=0 /kotlinc/lib              /rootfs/kotlinc/lib
COPY --from=0 /lib/ld-musl-x86_64.so.1  /rootfs/lib/
COPY --from=0 /lib/libz.so.1            /rootfs/lib/
COPY --from=0 /opt/java                 /rootfs/opt/jdk
COPY --from=0 /empty                    /rootfs/proc
COPY --from=0 /empty                    /rootfs/tmp
COPY --from=0 /bin                      /rootfs/bin/
COPY --from=0 /usr                      /rootfs/usr/
COPY --from=0 /lib/                     /rootfs/lib/
COPY --from=0 /kotlinc/build.txt        /kotlinc/
COPY --from=0 /kotlinc/bin              /kotlinc/bin
COPY --from=0 /kotlinc/lib              /kotlinc/lib
COPY --from=0 /opt/java                 /opt/jdk
COPY --from=0 /mydev                    /rootfs/dev
COPY --from=0 /myetc                    /rootfs/etc
COPY --from=0 /empty                    /proc
COPY --from=0 /empty                    /tmp
COPY --from=0 /bin                      /bin
COPY --from=0 /usr/                     /usr/
COPY --from=0 /lib                      /lib
COPY --from=0 /usr/bin/strace           /usr/bin/
COPY --from=0 /usr/bin/run-kotlin       /rootfs/usr/bin/
COPY --from=0 /usr/bin/strace           /rootfs/usr/bin/
COPY --from=0 /usr/lib                  /rootfs/usr/lib
COPY --from=0 /lib/ld-musl-x86_64.so.1  /lib
COPY --from=0 /usr/lib/libncursesw.so.6 \
              /usr/lib/libreadline.so.8 /rootfs/usr/lib/

# Remove the following two lines, if using eclipse-temurin.
COPY --from=0 /lib64                    /lib64
COPY --from=0 /lib64                    /rootfs/lib64

COPY run-hello /
COPY run-hello-sandbox /
COPY hello.kt /

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/jdk/openjdk/bin

ENTRYPOINT ["/bin/bash"]
