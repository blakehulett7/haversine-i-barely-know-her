package perform

import "../bson"
import "core:os"

Error :: union #shared_nil {
	bson.Error,
	os.Error,
}
