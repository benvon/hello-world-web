package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	// The underscore (_) before the import means this package is imported for its side effects only.
	// In this case, github.com/lib/pq registers itself as a Postgres driver with the database/sql package
	// when imported, but we don't directly use any exported functions from the package.
	// This is a common pattern for SQL drivers.
	_ "github.com/lib/pq"
)

func main() {
	// Feature toggle for health check
	healthEnabled := os.Getenv("HEALTHCHECK_ENABLED") == "true"

	http.HandleFunc("/api/health", func(w http.ResponseWriter, r *http.Request) {
		if !healthEnabled {
			w.WriteHeader(http.StatusNotFound)
			return
		}

		// Read DB config from env vars
		dbHost := os.Getenv("DB_HOST")
		dbPort := os.Getenv("DB_PORT")
		dbUser := os.Getenv("DB_USER")
		dbPass := os.Getenv("DB_PASS")
		dbName := os.Getenv("DB_NAME")

		connStr := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable", dbHost, dbPort, dbUser, dbPass, dbName)
		db, err := sql.Open("postgres", connStr)
		if err != nil {
			respondJSON(w, map[string]string{"status": "error", "error": err.Error()})
			return
		}
		defer db.Close()

		err = db.Ping()
		if err != nil {
			respondJSON(w, map[string]string{"status": "unhealthy", "error": err.Error()})
			return
		}
		respondJSON(w, map[string]string{"status": "healthy"})
	})

	port := os.Getenv("API_PORT")
	if port == "" {
		port = "8081"
	}
	log.Printf("Starting API server on :%s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

func respondJSON(w http.ResponseWriter, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(data)
} 