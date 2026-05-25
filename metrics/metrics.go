package metrics

import (
	"fmt"
	"time"
)

const MB = 1 << 20
const GB = 1 << 30

var MetricsChan = make(chan Pace)

func NewMetrics(on bool) chan bool {
	metrics_done := make(chan bool)

	go func() {
		start := time.Now()
		var global_parent Label

		var metrics Metrics
		for metric := range MetricsChan {
			if metric.Start {
				metrics[metric.Label].Parent = global_parent
				global_parent = metric.Label
				metrics[metric.Label].RootDuration = metrics[metric.Label].InclusiveDuration
				continue
			}

			metrics[metrics[metric.Label].Parent].ExclusiveDuration -= metric.Elapsed

			metrics[metric.Label].ExclusiveDuration += metric.Elapsed
			metrics[metric.Label].InclusiveDuration = metrics[metric.Label].RootDuration + metric.Elapsed
			metrics[metric.Label].Hits++
			metrics[metric.Label].Label = metric.Label
			metrics[metric.Label].BytesProcessed += metric.ByteCount

			global_parent = metrics[metric.Label].Parent
		}

		total_elapsed := time.Since(start)
		print_metrics(metrics, total_elapsed)
		metrics_done <- true
	}()

	return metrics_done
}

func Start(label Label) time.Time {
	MetricsChan <- Pace{
		Start: true,
		Label: label,
	}
	return time.Now()
}

func End(start time.Time, bytes uint64, label Label) {
	MetricsChan <- Pace{
		Label:     label,
		Elapsed:   time.Since(start),
		ByteCount: bytes,
	}
}

func print_metrics(metrics Metrics, total_elapsed time.Duration) {
	fmt.Printf("Total Time: %dms\n", total_elapsed.Milliseconds())

	for _, metric := range metrics {
		if metric.Label == 0 {
			continue
		}

		if metric.Label == metric.Parent {
			metric.ExclusiveDuration = metric.InclusiveDuration
		}

		block := fmt.Sprintf("%s[%d]:", metric.Label, metric.Hits)
		fmt.Printf("\t%-24sTime: %dms ", block, metric.ExclusiveDuration.Milliseconds())

		fmt.Printf("(%.2f%%", asPercent(metric.ExclusiveDuration, total_elapsed))
		if metric.ExclusiveDuration.Milliseconds() != metric.InclusiveDuration.Milliseconds() {
			fmt.Printf(", %.2f%% w/children", asPercent(metric.InclusiveDuration, total_elapsed))
		}
		fmt.Print(")")

		if metric.BytesProcessed > 0 {
			megabytes := f64(metric.BytesProcessed) / f64(MB)
			bytes_per_second := f64(metric.BytesProcessed) / metric.InclusiveDuration.Seconds()
			gigabytes_per_second := bytes_per_second / f64(GB)
			fmt.Printf("\t%.3fmb at %.2fgb/s", megabytes, gigabytes_per_second)
		}

		fmt.Println()
	}

	fmt.Println()
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
