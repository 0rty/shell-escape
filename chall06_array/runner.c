#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
 * Challenge 06 - Array Interpolation
 * Ce programme C appelle le script bash wrapper.sh
 * avec les arguments de l'utilisateur.
 * 
 * Pas de filtre côté C — la "sécurité" est dans le script bash.
 * Cherchez la faille dans wrapper.sh !
 */

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: %s <username>\n", argv[0]);
        return 1;
    }

    char cmd[512];
    // Appelle le script bash avec l'argument utilisateur
    snprintf(cmd, sizeof(cmd), "/challenge/wrapper.sh '%s'", argv[1]);
    
    printf("[*] Vérification du score pour : %s\n\n", argv[1]);
    system(cmd);
    return 0;
}
