package main

import "time"

func EstimateCPUFrequency() u64 {
	freq := GetOSTimerFrequency()

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

	return cpu_frequency
}

func GetOSTimerFrequency() uint64 {
	return 1000000
}

func ReadOSTimer() uint64 {
	return uint64(time.Now().UnixMicro())
}

func ReadCPUTimer() uint64
