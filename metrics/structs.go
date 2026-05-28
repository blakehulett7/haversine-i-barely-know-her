package metrics

import "time"

type enum = byte
type f64 = float64
type u8 = uint8
type u64 = uint64

type Label enum

//go:generate stringer -type=Label -output=enum_strings.go
const (
	ParseJSON Label = iota + 1
	QuickParse
	ParallelParse
	LexJSON
	LexJSONClean
	ReferenceHaversine
	RecursiveHaversine
	PartnerHaversine
	ReadFile
)

type Metrics [10]Metric

type Metric struct {
	Label             Label
	Parent            Label
	Hits              int
	ExclusiveDuration time.Duration
	InclusiveDuration time.Duration
	RootDuration      time.Duration
	BytesProcessed    u64
}

type Pace struct {
	Start     bool
	Label     Label
	Elapsed   time.Duration
	ByteCount u64
}
