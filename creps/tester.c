#pragma once
#include "brix.c"
#include "h_tester.h"
#include <stdio.h>
#include <stdlib.h>

typedef u64 func(void);

void begin(Tester *t) {
    if (!t) {
        return;
    }

    t->accumulated_time -= read_cpu_timer();
}

static f64 SecondsFromCPUTime(f64 CPUTime, u64 CPUTimerFreq) {
    f64 Result = 0.0;
    if (CPUTimerFreq) {
        Result = (CPUTime / (f64)CPUTimerFreq);
    }
    return Result;
}

void print_time(char const *Label, f64 CPUTime, u64 CPUTimerFreq, u64 ByteCount) {
    printf("%s: %.0f", Label, CPUTime);
    if (CPUTimerFreq) {
        f64 Seconds = SecondsFromCPUTime(CPUTime, CPUTimerFreq);
        printf(" (%fms)", 1000.0f * Seconds);

        if (ByteCount) {
            f64 Gigabyte = (1024.0f * 1024.0f * 1024.0f);
            f64 BestBandwidth = ByteCount / (Gigabyte * Seconds);
            printf(" %fgb/s", BestBandwidth);
        }
    }
}

void print_new_min(Tester *t) {
    printf("new min\r");
}

void print_metrics(Tester *t) {
    test_results results = t->results;

    // printf("Min: %fgb/s");
    // printf("Max: %fgb/s", );
    f64 avg = (f64)(results.total_bytes) / (f64)(results.total_time);
    f64 clock_speed = 4.51;
    printf("Avg: %fgb/s\t%f cycles/byte\n", avg, clock_speed / avg);
}

bool end(Tester *t, u64 bytes_processed) {
    if (!t) {
        return true;
    }

    u64 current_time = read_cpu_timer();

    t->accumulated_time += current_time;
    t->accumulated_bytes += bytes_processed;

    test_results *results = &t->results;

    if (results->max_time < t->accumulated_time) {
        results->max_time = t->accumulated_time;
    }

    if (results->min_time > t->accumulated_time || results->min_time == 0) {
        results->min_time = t->accumulated_time;
        t->started_at = current_time;
        print_new_min(t);
    }

    results->total_bytes += t->accumulated_bytes;
    results->total_time += t->accumulated_time;

    if (current_time - t->started_at > t->test_for) {
        return true;
    }

    return false;
}

void run_reps(func test, char *label) {
    Tester t = {
        .started_at = read_cpu_timer(),
        .test_for = 10 * get_os_timer_frequency(),
    };

    while (true) {
        begin(&t);
        u64 bytes = test();
        bool done = end(&t, bytes);

        if (done) {
            break;
        }
    }

    print_metrics(&t);
}
