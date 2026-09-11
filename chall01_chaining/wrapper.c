#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/*
 * Challenge 01 - Command Chaining
 * Ce wrapper permet de "ping" une IP.
 * Il bloque certains caractères... mais pas tous.
 */

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: %s <ip>\n", argv[0]);
        printf("Exemple: %s 8.8.8.8\n", argv[0]);
        return 1;
    }

    char *input = argv[1];

    // Filtre basique : bloque les pipes et esperluettes
    if (strchr(input, '|') || strchr(input, '&')) {
        printf("Caractère interdit détecté !\n");
        return 1;
    }

    char cmd[256];
    snprintf(cmd, sizeof(cmd), "ping -c 1 %s", input);
    printf("[*] Exécution : ping -c 1 %s\n", input);
    system(cmd);
    return 0;
}
