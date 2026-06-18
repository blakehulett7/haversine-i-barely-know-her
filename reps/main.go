package main

import (
	"fmt"
	"haversine-i-barely-know-her/metrics"
	"os"
	"syscall"
	"time"
	"unsafe"
)

const MB = 1 << 20
const GB = 1 << 30

const TestFor = 10 * time.Second

var CPU_FREQ u64

func main() {
	CPU_FREQ = metrics.EstimateCPUFrequency() * 2 * 1000
	// run_reps(func() int { return write_all(1024) }, "write_all")
	// run_reps(func() int { return mov_all(1024) }, "mov_all")
	// run_reps(func() int { return mov_quick(1024) }, "mov_quick")
	// run_reps(func() int { return nop_all(1024) }, "nop_all")
	// run_reps(func() int { return cmp_all(1024) }, "cmp_all")
	// run_reps(func() int { dec_bytes(nil, 1024); return 1024 }, "dec_all")
	// run_reps(func() int { linear_add(); return 100000 }, "linear")
	// run_reps(func() int { non_linear_add(); return 100000 }, "non_linear")

	src := []byte{1, 2, 3, 4, 5, 6, 7, 8}

	run_reps(func() int { store_x1(src, 100000); return 100000 }, "store_x1")
	run_reps(func() int { store_x2(src, 100000); return 100000 }, "store_x2")
	run_reps(func() int { store_x3(src, 100000); return 100000 }, "store_x3")
	run_reps(func() int { store_x4(src, 100000); return 100000 }, "store_x4")

	run_reps(func() int { read_x1(src, 100000); return 100000 }, "read_x1")
	run_reps(func() int { read_x2(src, 100000); return 100000 }, "read_x2")
	run_reps(func() int { read_x3(src, 100000); return 100000 }, "read_x3")
	run_reps(func() int { read_x4(src, 100000); return 100000 }, "read_x4")
}

func ReadingReps() {
	for {
		run_reps(func() int {
			data, err := os.ReadFile("../points_1000000.json")
			if err != nil {
				return 0
			}
			return len(data)
		}, "os.ReadFile")

		t := Tester{
			test_for:  10 * time.Second,
			run_timer: time.Now(),
		}

		data, err := os.ReadFile("../points_1000000.json")
		if err != nil {
			os.Exit(1)
		}
		syscall.Syscall(syscall.SYS_MADVISE, uintptr(unsafe.Pointer(&data[0])), uintptr(len(data)), uintptr(syscall.MADV_DONTNEED))

		fmt.Println("--- os.ReadFile + Malloc ---")
		for {
			begin(&t)
			data, err = os.ReadFile("../points_1000000.json")
			done := end(&t, len(data))

			if err != nil || len(data) == 0 {
				fmt.Printf("failed test run, err: %v\n", err)
				os.Exit(1)
			}

			// NOTE: This forces a minor page fault... allegedly
			syscall.Syscall(syscall.SYS_MADVISE, uintptr(unsafe.Pointer(&data[0])), uintptr(len(data)), uintptr(syscall.MADV_DONTNEED))

			if done {
				break
			}
		}
	}
}

func begin(t *Tester) {
	t.started_at = time.Now()
}

func end(t *Tester, bytes_processed int) bool {
	run_time := time.Since(t.started_at)
	if t.Min == 0 && bytes_processed != 0 {
		t.Min = run_time
		t.min_bytes_processed = u64(bytes_processed)
		fmt.Printf("\rMin: %fms ", f64(t.Min.Nanoseconds())/f64(time.Millisecond))
		return false
	}

	if run_time < t.Min && bytes_processed != 0 {
		t.Min = run_time
		t.started_at = time.Now()
		t.min_bytes_processed = u64(bytes_processed)
		fmt.Printf("\rMin: %fms ", f64(t.Min.Nanoseconds())/f64(time.Millisecond))
	}

	if run_time > t.Max {
		t.Max = run_time
		t.max_bytes_processed = u64(bytes_processed)
	}

	t.test_count++
	t.total_time += run_time
	t.bytes_processed += u64(bytes_processed)

	if time.Since(t.run_timer) < t.test_for {
		return false
	}

	print_results(t)
	return true
}

func print_results(t *Tester) {
	fmt.Printf("\t%fgb/s\n", gb_per_second(t.min_bytes_processed, t.Min))
	fmt.Printf("Max: %-16s\t%fgb/s\n", fmt.Sprintf("%fms", f64(t.Max.Nanoseconds())/f64(time.Millisecond)), gb_per_second(t.max_bytes_processed, t.Max))
	fmt.Printf("Avg: %-16s\t%fgb/s\t%f cycles/byte\n", fmt.Sprintf("%fms", f64(t.total_time.Milliseconds())/f64(t.test_count)), gb_per_second(t.bytes_processed, t.total_time), cycles_per_byte(t.bytes_processed))
	fmt.Println()
}

func cycles_per_byte(bytes_processed u64) f64 {
	return f64(CPU_FREQ) / f64(bytes_processed)
}

func gb_per_second(bytes_processed u64, duration time.Duration) f64 {
	bytes_per_second := f64(bytes_processed) / duration.Seconds()
	return bytes_per_second / f64(GB)
}

func goPanicIndex() {
	panic("runtime error: index out of range")
}
