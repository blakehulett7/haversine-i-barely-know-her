package generator

import "core:encoding/json"
import "core:fmt"
import "core:math/rand"
import "core:os"

min_x :: -90.0
max_x :: 90.0
min_y :: -180.0
max_y :: 180.0

max_x_radius :: 15
max_y_radius :: 30
num_clusters :: 16

input :: proc(seed, num: u64) -> Out {
	result := make([dynamic]Pair, 0, num)

	input_seed := seed
	if seed == 0 {
		input_seed = rand.uint64()
	}
	rand.reset(input_seed)

	batch_size := num / num_clusters
	remainder := num %% num_clusters

	#unroll for i in 0 ..< num_clusters {
		center_x := rand.float64_range(min_x, max_x)
		center_y := rand.float64_range(min_y, max_y)

		x_radius := rand.float64_range(0, max_x_radius)
		y_radius := rand.float64_range(0, max_y_radius)

		local_min_x := center_x - x_radius
		local_max_x := center_x + x_radius
		local_min_y := center_y - y_radius
		local_max_y := center_y + y_radius


		for j in 0 ..< batch_size {
			x0 := wrap_x(rand.float64_range(local_min_x, local_max_x))
			y0 := wrap_y(rand.float64_range(local_min_y, local_max_y))
			x1 := wrap_x(rand.float64_range(local_min_x, local_max_x))
			y1 := wrap_y(rand.float64_range(local_min_y, local_max_y))

			assert(x0 >= min_x && x0 <= max_x)
			assert(y0 >= min_y && y0 <= max_y)
			assert(x1 >= min_x && x1 <= max_x)
			assert(y1 >= min_y && y1 <= max_y)

			append(&result, Pair{x0 = x0, y0 = y0, x1 = x1, y1 = y1})
		}
	}

	for i in 0 ..< remainder {
		append(
			&result,
			Pair {
				x0 = wrap_x(rand.float64_range(min_x, max_x)),
				y0 = wrap_y(rand.float64_range(min_y, max_y)),
				x1 = wrap_x(rand.float64_range(min_x, max_x)),
				y1 = wrap_y(rand.float64_range(min_y, max_y)),
			},
		)
	}

	o := Out {
		pairs = result,
	}

	data, err := json.marshal(o, json.Marshal_Options{pretty = true})
	if err != nil {
		fmt.println("could not save data")
		delete(result)
		return Out{}
	}

	_ = os.write_entire_file("data/pairs.json", data)
	delete(data)
	return o
}

wrap_x :: proc(x: f64) -> f64 {
	if x < min_x {
		return x + 2 * max_x
	}

	if x > max_x {
		return x + 2 * min_x
	}

	return x
}

wrap_y :: proc(y: f64) -> f64 {
	if y < min_y {
		return y + 2 * max_y
	}

	if y > max_y {
		return y + 2 * min_y
	}

	return y
}
