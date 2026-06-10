#include "types.h"

typedef struct {
    u64 total_bytes;
    u64 total_time;
    u64 max_time;
    u64 min_time;
} test_results;

typedef struct {
    u64 bytes_processed;
    u64 expected_bytes;
    u64 test_for;

    u64 accumulated_bytes;
    u64 accumulated_time;

    test_results results;
} Tester;
