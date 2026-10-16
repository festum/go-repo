// Command dummy prints a greeting.
package main

import (
	"fmt"

	"github.com/festum/go-repo/internal/greet"
)

var version = "dev"

func main() {
	fmt.Println(greet.Greet("dummy"))
	fmt.Println(version)
}
