package metrics

import (
	"fmt"
	"time"
)

var MetricsChan = make(chan Metric)

func NewMetrics() chan bool {
	metrics_done := make(chan bool)

	go func() {
		start := time.Now()
		var metrics Metrics

		for metric := range MetricsChan {
			if metric.Start {

				continue
			}

			metrics[metric.Label].Duration += metric.Duration
			metrics[metric.Label].Hits++
			metrics[metric.Label].Label = metric.Label
		}

		total_elapsed := time.Since(start)
		print_metrics(metrics, total_elapsed)
		metrics_done <- true
	}()

	return metrics_done
}

func Start(label Label) time.Time {
	MetricsChan <- Metric{
		Start: true,
		Label: label,
	}
	return time.Now()
}

func ReportMetrics(start time.Time, label Label) {
	MetricsChan <- Metric{
		Label:    label,
		Duration: time.Since(start),
	}
}

func print_metrics(metrics Metrics, total_elapsed time.Duration) {
	fmt.Printf("Total Time: %d\n", total_elapsed)

	for i, metric := range metrics {
		if i == 0 {
			continue
		}

		fmt.Printf("\t%s[%d]: Time: %d (%.2f%%)\n", metric.Label, metric.Hits, metric.Duration, asPercent(metric.Duration, total_elapsed))
	}
}

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

func asPercent(num, den time.Duration) f64 {
	return (f64(num) / f64(den)) * 100
}
