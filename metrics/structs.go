package metrics

import "time"

type enum = u8
type f64 = float64
type u8 = uint8
type u64 = uint64

type Label enum

const (
	ParseJSON Label = iota + 1
	LexJSON
	ReferenceHaversine
)

func (l Label) String() string {
	switch l {
	default:
		return "invalid label"
	case ParseJSON:
		return "json.Parse"
	case ReferenceHaversine:
		return "ReferenceHaversine"
	case LexJSON:
		return "json.lex"
	}
}

type Metrics [4]Metric

type Metric struct {
	Start            bool
	Label            Label
	Child            Label
	Hits             int
	ExlusiveDuration time.Duration
	Duration         time.Duration
}
