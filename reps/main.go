package main

import (
	"fmt"
	"os"
	"syscall"
	"time"
	"unsafe"
)

const MB = 1 << 20
const GB = 1 << 30

func main() {
	for {
		t := Tester{
			test_for:  10 * time.Second,
			run_timer: time.Now(),
		}

		fmt.Println()

		fmt.Println("--- os.ReadFile ---")
		for {
			begin(&t)
			data, err := os.ReadFile("../points_1000000.json")
			done := end(&t, len(data))

			if err != nil || len(data) == 0 {
				fmt.Printf("failed test run, err: %v\n", err)
				os.Exit(1)
			}

			if done {
				break
			}
		}

		t = Tester{
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

			// NOTE: This forces a minor page fault
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
	fmt.Printf("Avg: %-16s\t%fgb/s\n", fmt.Sprintf("%fms", f64(t.total_time.Milliseconds())/f64(t.test_count)), gb_per_second(t.bytes_processed, t.total_time))
	fmt.Println()
}

func gb_per_second(bytes_processed u64, duration time.Duration) f64 {
	bytes_per_second := f64(bytes_processed) / duration.Seconds()
	return bytes_per_second / f64(GB)
}
