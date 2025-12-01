package main

import (
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(responsewriter http.ResponseWriter, request *http.Request) {
		log.Printf("[i] Client Data IP Address %s\n", request.RemoteAddr)
	})

	e := func() error {
		return http.ListenAndServe(":80", nil)
	}()

	if e != nil {
		log.Fatalf("something just happened... %v", e)
	}
}
