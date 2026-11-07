package main

import "../../metrics"
import "core:fmt"
import "core:mem/virtual"
import "core:os"

main :: proc() {
	kb := 1024

	page_size := 16 * kb
	page_count := 1024
	total_size := page_count * page_size

	fmt.printf("Page Count, Touch Count, Fault Count, Extra Faults\n")
	for touch_count in 0 ..< page_count {
		touch_size := touch_count * page_size
		data, err := virtual.reserve_and_commit(uint(total_size))
		if err != nil {
			fmt.fprintln(os.stderr, "ERROR: Unable to allocate memory")
		}

		start_fault_count := metrics.read_page_faults()
		for i in 0 ..< touch_size {
			data[i] = byte(i)
		}
		end_fault_count := metrics.read_page_faults()

		faults := end_fault_count - start_fault_count

		fmt.printf(
			"%d, %d, %d, %d\n",
			page_count,
			touch_count,
			faults,
			(faults - i64(touch_count)),
		)

		virtual.release(raw_data(data), uint(len(data)))
	}
}
