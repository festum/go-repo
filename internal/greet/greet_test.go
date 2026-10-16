package greet_test

import (
	"testing"

	"github.com/festum/go-repo/internal/greet"
)

func TestGreet(t *testing.T) {
	t.Parallel()

	if got, want := greet.Greet("dummy"), "Hello, dummy!"; got != want {
		t.Errorf("Greet(%q) = %q, want %q", "dummy", got, want)
	}

	if got, want := greet.Greet(""), "Hello, world!"; got != want {
		t.Errorf("Greet(%q) = %q, want %q", "", got, want)
	}
}
