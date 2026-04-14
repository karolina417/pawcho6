package main

import (
	"fmt"
	"net"
	"net/http"
	"os"
)

var VERSION = "brak"

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		hostname, _ := os.Hostname()
		adres, _ := net.InterfaceAddrs()
		var ip string
		for _, a := range adres {
			if ipnet, ok := a.(*net.IPNet); ok && !ipnet.IP.IsLoopback() {
				if ipnet.IP.To4() != nil { ip = ipnet.IP.String() }
			}
		}

		fmt.Fprintf(w, "<p>IP: %s</p>", ip)           
		fmt.Fprintf(w, "<p>Hostname: %s</p>", hostname)
		fmt.Fprintf(w, "<p>Wersja: %s</p>", VERSION)
	})

	http.ListenAndServe(":8080", nil)
}