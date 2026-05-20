package main

import (
	"fmt"
	"testing"
)

func TestOSAndCPUTimer(t *testing.T) {
	freq := GetOSTimerFrequency()
	fmt.Printf("OS Freq: %d\n", freq)

	var cpu_start u64 = ReadCPUTimer()
	var start u64 = ReadOSTimer()
	var end u64 = 0
	var elapsed u64 = 0

	for elapsed < freq {
		end = ReadOSTimer()
		elapsed = end - start
	}

	var cpu_end u64 = ReadCPUTimer()
	var cpu_elapsed u64 = cpu_end - cpu_start
	cpu_frequency := freq * cpu_elapsed / elapsed

	fmt.Printf("OS Timer: %d -> %d = %d elapsed\n", start, end, elapsed)
	fmt.Printf("OS Seconds: %.4f\n", f64(elapsed)/f64(freq))
	fmt.Printf("CPU Timer: %d -> %d = %d elapsed\n", cpu_start, cpu_end, cpu_elapsed)
	fmt.Printf("CPU Freq: %d\n", cpu_frequency)
}
