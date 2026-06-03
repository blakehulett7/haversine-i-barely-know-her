#include <stdlib.h>

int main() {
    int count = 1024;

    int *buffer = malloc(count * sizeof(int));
    if (buffer == NULL) return 1;

    for (int i = 0; i < count; i++) {
        buffer[i] = i;
    }

    free(buffer);
}
