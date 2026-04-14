#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

#define MAX_OP_LEN 6   // op is at most 5 chars + '\0'

int main() {
    char op[MAX_OP_LEN];
    int a, b;

    // Read until EOF
    while (scanf("%5s %d %d", op, &a, &b) == 3) {
        char libname[32];

        // Using "./" so dlopen looks in the current working directory
        snprintf(libname, sizeof(libname), "./lib%s.so", op);

        // Load shared library
        void *handle = dlopen(libname, RTLD_LAZY);
        if (!handle) {
            fprintf(stderr, "Error loading %s: %s\n", libname, dlerror());
            continue;
        }

        dlerror();

        // Get function pointer. Signature: int func(int, int)
        int (*func)(int, int) = (int (*)(int, int)) dlsym(handle, op);

        char *error = dlerror();
        if (error != NULL) {
            fprintf(stderr, "Error finding symbol %s: %s\n", op, error);
            dlclose(handle);
            continue;
        }

        int result = func(a, b);

        printf("%d\n", result);

        dlclose(handle);
    }

    return 0;
}