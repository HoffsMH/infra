package transcript

import (
	"strings"
	"testing"
)

func TestWriteActiveBranch(t *testing.T) {
	input := strings.Join([]string{
		`{"uuid":"root","type":"user","message":{"role":"user","content":"hello"}}`,
		`not json`,
		`{"uuid":"answer","parentUuid":"root","type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"first"},{"type":"tool_use","name":"Read"}]}}`,
		`{"uuid":"side","parentUuid":"answer","type":"assistant","isSidechain":true,"message":{"role":"assistant","content":"ignore sidechain"}}`,
		`{"uuid":"meta","parentUuid":"answer","type":"user","isMeta":true,"message":{"role":"user","content":"ignore metadata"}}`,
		`{"uuid":"leaf","parentUuid":"meta","type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"second"}]}}`,
	}, "\n")

	var output strings.Builder
	if err := Write(strings.NewReader(input), &output); err != nil {
		t.Fatal(err)
	}

	want := "USER\n\nhello\n\nASSISTANT\n\nfirst\n\nASSISTANT\n\nsecond\n\n"
	if output.String() != want {
		t.Errorf("Write() = %q; expected %q", output.String(), want)
	}
}

func TestWriteWithoutMessages(t *testing.T) {
	var output strings.Builder
	if err := Write(strings.NewReader(`{"type":"progress"}`), &output); err != nil {
		t.Fatal(err)
	}
	if output.Len() != 0 {
		t.Errorf("Write() = %q; expected no output", output.String())
	}
}
