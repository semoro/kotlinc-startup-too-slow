I have attempted to add the Kotlin language to the website https://code.golf, because it was the most requested language that isn't supported.
I was not able to do this, because it took far too long to compile and run a simple hello world Kotlin program in the sandboxed environment.
It took approximately 11-12 seconds, while the total allowed execution time is 5 seconds.

Even without the sandbox, the amount of time needed to compile and run the hello world Kotlin program is 3-5 seconds, which doesn't leave much of the 5 second execution time for the program to do anything interesting. We could allow extended execution time for Kotlin programs, but the user experience would not be good compared to the majority of languages which can execute hello world programs in well under one second.

Someone might suggest that we run the Kotlin compiler as a service so that we don't have to repeatedly pay the startup cost. This idea has been rejected for other languages, because the website supports a large number of languages (currently 38) and hosting compilers as services would significantly increase the complexity.

This is a simple example showing how to reproduce the problem in a docker container.

```
$ docker build -t kotlinc-startup-too-slow .
$ docker run -it --privileged kotlinc-startup-too-slow
bash-5.1# ./run-hello

COMPILER EXITED
Hello, World!
0
1
2
3
4
5
6
7
8
9
10
foo
bar

real	0m3.672s
user	0m6.959s
sys	0m0.428s
bash-5.1# ./run-hello-sandbox
COMPILER EXITED
Hello, World!
0
1
2
3
4
5
6
7
8
9
10
foo
bar

real	0m11.513s
user	0m17.138s
sys	0m0.459s
bash-5.1# run-kotlin --version
Kotlin version 1.6.10-release-923 (JRE 11.0.12+7)
```

In this example, compiling and running the hello world program without the sandbox took 3.7 seconds. Compiling and running the hello world program in the sandbox took 11.5 seconds. It's not clear why running the same program in the sandbox takes so much longer, but even without the sandbox it's currently too slow.

We could tolerate a maximum of about 2 seconds to compile and run a hello world program, although under one second would be better. If it's not possible to achive this, then we won't be able to support Kotlin. It's possible to compile and run a hello world program in most languages we support in well under one second.

Here are some timings for various Kotlin and JDK versions.

Note that Kotlin 1.3.50 is significantly faster (without the sandbox) than the later versions I tested.

```
Kotlin version 1.7.0-Beta-release-135 (JRE 11.0.12+7): 4.324s (no sandbox), 11.682s (sandbox)
Kotlin version 1.6.21-release-334 (JRE 18.0.1+10):     7.741s (no sandbox), 15.236s (sandbox)
Kotlin version 1.6.21-release-334 (JRE 11.0.12+7):     3.542s (no sandbox), 11.533s (sandbox)
Kotlin version 1.6.10-release-923 (JRE 11.0.12+7):     3.546s (no sandbox), 13.079s (sandbox)
Kotlin version 1.3.50-release-112 (JRE 11.0.12+7):     2.704s (no sandbox), 12.210s (sandbox)

JRE 18.0.1+10 image: eclipse-temurin:18.0.1_10-jdk-alpine
JRE 11.0.12+7 image: adoptopenjdk/openjdk11:x86_64-alpine-jdk-11.0.12_7-slim
```
