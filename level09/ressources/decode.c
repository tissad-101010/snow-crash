#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <token_file>\n", argv[0]);
        return 1;
    }
    int fd = open(argv[1], O_RDONLY);
    if (fd < 0) {
        perror("Failed to open file");
        return 1;
    }
    char buffer[1024];
    ssize_t bytesRead = read(fd, buffer, sizeof(buffer) - 1);
    if (bytesRead < 0) {
        perror("Failed to read file");
        close(fd);
        return 1;   
    }

    buffer[bytesRead] = '\0';
  
    for (size_t i = 0; i < bytesRead - 1; i++)
    {
        buffer[i] -= i; // Simple XOR decryption
    }
    
    printf("Decoded token: %s", buffer);
    close(fd);
    return 0;
}