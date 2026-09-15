#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

extern char **environ;

int main(int argc, char *argv[], char *envp[]) {
    // Lire le flag
    FILE *f = fopen("/flag.txt", "r");
    if (!f) {
        perror("flag");
        return 1;
    }

    char flag[256];
    if (!fgets(flag, sizeof(flag), f)) {
        return 1;
    }
    fclose(f);

    // Supprimer le newline
    for (int i = 0; flag[i]; i++) {
        if (flag[i] == '\n') { flag[i] = '\0'; break; }
    }

    // Mettre le flag dans l'environnement
    setenv("FLAG", flag, 1);

    // Élever les privilèges puis appeler le script
    setuid(0);
    setgid(0);

    // Passer les arguments à wrapper.sh
    char *args[argc + 2];
    args[0] = "/bin/bash";
    args[1] = "/challenge/wrapper.sh";
    for (int i = 1; i < argc; i++) args[i + 1] = argv[i];
    args[argc + 1] = NULL;

    execve("/bin/bash", args, environ);
    perror("execve");
    return 1;
}
