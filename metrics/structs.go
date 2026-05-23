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
	RecursiveHaversine
	PartnerHaversine
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
	case RecursiveHaversine:
		return "RecursiveHaversine"
	case PartnerHaversine:
		return "PartnerHaversine"
	}
}

type Metrics [6]Metric

type Metric struct {
	Label             Label
	Parent            Label
	Hits              int
	ExclusiveDuration time.Duration
	InclusiveDuration time.Duration
	RootDuration      time.Duration
}

type Pace struct {
	Start   bool
	Label   Label
	Elapsed time.Duration
}
