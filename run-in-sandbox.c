#define _GNU_SOURCE
#include <sched.h>
#include <stdlib.h>
#include <sys/mount.h>
#include <sys/mman.h>
#include <sys/syscall.h>
#include <sys/wait.h>

#define STACK_SIZE (1024 * 1024)    /* Stack size for cloned child */

int helper(void *argv);

int main(__attribute__((unused)) int argc, __attribute__((unused)) char *argv[]) {
    char* stack = mmap(NULL, STACK_SIZE, PROT_READ | PROT_WRITE,
                       MAP_PRIVATE | MAP_ANONYMOUS | MAP_STACK, -1, 0);
    if (stack == MAP_FAILED) {
        perror("mmap");
        return 1;
    }

    char* stackTop = stack + STACK_SIZE;

    pid_t pid = clone(helper, stackTop, SIGCHLD | CLONE_NEWIPC | CLONE_NEWNET | CLONE_NEWNS | CLONE_NEWPID | CLONE_NEWUTS, argv);

    if (pid == -1)
    {
        perror("clone");
        return 1;
    }

    if (pid)
    {
        int status;
        waitpid(pid, &status, 0);
        return WEXITSTATUS(status);
    }
}

int helper(void *argv) {
    if (mount(NULL, "/", NULL, MS_PRIVATE|MS_REC, NULL) < 0) {
        perror("mount private");
        return 1;
    }

    if (mount("rootfs", "rootfs", "bind", MS_BIND|MS_REC, NULL) < 0) {
        perror("mount bind");
        return 1;
    }

    if (syscall(SYS_pivot_root, "rootfs", "rootfs") < 0) {
        perror("pivot_root");
        return 1;
    }

    if (chdir("/") < 0) {
        perror("chdir");
        return 1;
    }

    if (umount2("/", MNT_DETACH) < 0) {
        perror("umount2");
        return 1;
    }

    if (mount("proc", "/proc", "proc", MS_NODEV|MS_NOEXEC|MS_NOSUID|MS_RDONLY, NULL) < 0) {
        perror("mount proc");
        return 1;
    }

    if (mount("tmpfs", "/tmp", "tmpfs", MS_NODEV|MS_NOSUID, NULL) < 0) {
        perror("mount tmp");
        return 1;
    }

    char** argv2 = (char**)argv;
    execvp(argv2[1], argv2 + 1);
    perror("execvp");
    return 1;
}
