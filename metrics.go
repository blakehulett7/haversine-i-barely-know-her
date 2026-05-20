package main

import "time"

func estimateCPUFrequency() u64 {
	freq := getOSTimerFrequency()

	var cpu_start u64 = readCPUTimer()
	var start u64 = readOSTimer()
	var end u64 = 0
	var elapsed u64 = 0

	for elapsed < freq {
		end = readOSTimer()
		elapsed = end - start
	}

	var cpu_end u64 = readCPUTimer()
	var cpu_elapsed u64 = cpu_end - cpu_start
	cpu_frequency := freq * cpu_elapsed / elapsed

	return cpu_frequency
}

func getOSTimerFrequency() uint64 {
	return 1000000
}

func readOSTimer() uint64 {
	return uint64(time.Now().UnixMicro())
}

func readCPUTimer() uint64
