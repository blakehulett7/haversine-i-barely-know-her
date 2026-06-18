#pragma once
#include "types.h"
#include <arm_acle.h>
#include <mach/mach_time.h>
#include <sys/time.h>

static u64 get_os_timer_frequency(void) {
    return 24000000;
}

static u64 read_os_timer(void) {
    return mach_absolute_time();
}

static u64 read_cpu_timer(void) {
    return __arm_rsr64("CNTVCT_EL0");
}

static u64 m4_frequency(void) {
    return 4510000000;
}
