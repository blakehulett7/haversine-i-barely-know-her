#include "brix.c"
#include "types.h"
#include <stdio.h>

int main(void) {
}

/*
int main(void) {
    u64 OSFreq = get_os_timer_frequency();
    printf("OS Freq: %llu\n", OSFreq);

    u64 CPUStart = read_cpu_timer();
    u64 OSStart = read_os_timer();
    u64 OSEnd = 0;
    u64 OSElapsed = 0;

    while (OSElapsed < OSFreq) {
        OSEnd = read_os_timer();
        OSElapsed = OSEnd - OSStart;
    }

    u64 CPUEnd = read_cpu_timer();
    u64 CPUElapsed = CPUEnd - CPUStart;

    printf("OS Timer: %llu -> %llu = %llu elapsed\n", OSStart, OSEnd, OSElapsed);
    printf("OS Seconds: %.4f\n", (f64)OSElapsed / (f64)OSFreq);

    printf("CPU Timer: %llu -> %llu = %llu elapsed\n", CPUStart, CPUEnd, CPUElapsed);
    printf("Clocks: %llu / %llu = %.4f cycles\n", m4_frequency(), CPUElapsed,
           (f64)m4_frequency() / (f64)CPUElapsed * 1000000000);

    return 0;
}
*/

/*
int main() {
    printf("Jesus is Lord\n");

    int count = 1024;
    u8 buffer[count] = {};

    for (int i = 0; i < count; i++) {
        buffer[i] = (u8)(i);
    }
}
*/
