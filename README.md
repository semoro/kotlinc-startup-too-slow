Using the Excelsior JET AOT compiled Kotlin compiler from:
https://github.com/JetBrains/kotlin/releases/download/v1.3.30/experimental-kotlin-compiler-linux-x64.zip

Outside of a sandboxed enviornment, it can compile and run a simple hello world example program in under one second.

When run in a sandbox, the execution time is inexplicably increased to over five seconds.

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

real	0m0.882s
user	0m0.726s
sys	0m0.187s

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

real	0m5.901s
user	0m6.275s
sys	0m0.187s

bash-5.1# run-kotlin --version
Kotlin version 1.3.30-release-170 (JRE 11.0.12+7)
```
