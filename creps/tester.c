#include "brix.c"
#include "h_tester.h"
#include <stdlib.h>

typedef u64 func(void);

void begin(Tester *t) {
    if (!t) {
        return;
    }

    t->accumulated_time -= read_cpu_timer();
}

void end(Tester *t, u64 bytes_processed) {
    if (!t) {
        return;
    }

    t->accumulated_time += read_cpu_timer();
    t->accumulated_bytes += bytes_processed;

    test_results *results = &t->results;

    if (results->max_time < t->accumulated_time) {
        results->max_time = t->accumulated_time;
    }

    if (results->min_time > t->accumulated_time) {
        results->min_time = t->accumulated_time;
    }

    results->total_bytes += t->accumulated_bytes;
    results->total_time += t->accumulated_time;
}

void run_reps(func test, char *label) {
    Tester t = {};

    begin(&t);
    u64 bytes = test();
    end(&t, bytes);
}
