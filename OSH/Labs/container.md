[toc]

## Some syscall

### chroot() & chdir()

> 需要root权限

`chroot(char PATH[])`: 切换根目录

`chdir(char PATH[])`:  切换工作目录

```c++
#include <sys/wait.h>   // waitpid
#include <sys/mount.h>  // mount
#include <fcntl.h>      // open
#include <unistd.h>     // execv, sethostname, chroot, fchdir
#include <sched.h>      // clone
#include <sys/types.h>
#include <iostream>
#include <cstring>
#include <sys/mman.h>
#include <signal.h>
#define STACK_SIZE (1024*1024)

class container{
private:
    char *hostname;
    char *root_dir;
    char *bashpath;
    char **argv;
    void set_hostname(){
        sethostname(hostname, strlen(hostname));
    }
    void setrootdir(){
        if(chdir(root_dir)==-1){perror("chroot"); exit(1);};
        if(chroot(".")==-1){perror("chroot"); exit(1);};
    }
    void set_filesys(){
        if (mount("none", "/proc", "proc", 0, nullptr)) {perror("proc"); exit(1);}
        if (mount("none", "/sys", "sysfs", O_RDONLY, nullptr)) {perror("sysfs"); exit(1);}
        if (mount("none", "/tmp", "tmpfs", 0, NULL)!=0) {perror("tmp"); exit(1);}
        if (mount("udev", "/dev", "devtmpfs", 0, NULL)!=0) {perror("dev");exit(1);}
        // TODO: cgroup controller
    }
    void boot_bash(){
        execvp(argv[2], argv+2);
    }
public:
    container(char **argv, char *hostname){
        this->argv = argv;
        this->root_dir = argv[1];
        this->hostname = hostname;
        this->bashpath = argv[2];
    }

    static int ct_init(void *args){
        auto THIS = static_cast<container*>(args);
        THIS->set_hostname();
        THIS->setrootdir();
        THIS->set_filesys();
        THIS->boot_bash();
        return 1;
    }
    void ct_boot(){
        void *child_stack = mmap(NULL, STACK_SIZE,
                             PROT_READ | PROT_WRITE,
                             MAP_PRIVATE | MAP_ANONYMOUS | MAP_STACK,
                             -1, 0);
        void *child_stack_start = (void*)((char*)child_stack + STACK_SIZE);

        int child_process=clone(ct_init,child_stack_start,
                                        CLONE_NEWUTS| 
                                        CLONE_NEWNS| 
                                        CLONE_NEWIPC|
                                        CLONE_NEWPID|
                                        CLONE_NEWCGROUP|
                                        SIGCHLD, 
                                        this);
        wait(NULL);
        printf("exit success\n");
    }
};

int main(int argc, char **argv){
    char hostname[] = "myct\0";
    container *ct = new container(argv, hostname);
    ct->ct_boot();
    return 0;
}
```

