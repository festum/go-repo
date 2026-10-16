// Command dummy prints a greeting.
package main

import (
	"fmt"

	"github.com/festum/go-repo/internal/greet"
)

func main() {
	fmt.Println(greet.Greet("dummy"))
}
