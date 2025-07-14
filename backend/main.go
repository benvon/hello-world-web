package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"time"
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
		
		// SSL configuration
		sslMode := os.Getenv("DB_SSL_MODE")
		if sslMode == "" {
			sslMode = "require" // Default to requiring SSL
		}

		// Build connection string with SSL enforcement
		connStr := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s connect_timeout=5", 
			dbHost, dbPort, dbUser, dbPass, dbName, sslMode)
		
		db, err := sql.Open("postgres", connStr)
		if err != nil {
			respondJSON(w, map[string]string{"status": "error", "error": err.Error()})
			return
		}
		defer db.Close()

		// Set connection pool settings
		db.SetMaxOpenConns(1)
		db.SetMaxIdleConns(1)
		db.SetConnMaxLifetime(5 * time.Second)

		err = db.Ping()
		if err != nil {
			// Provide more helpful error messages for common PostgreSQL issues
			errorMsg := err.Error()
			if strings.Contains(errorMsg, "no pg_hba.conf entry") {
				errorMsg = "PostgreSQL authentication failed: Check pg_hba.conf configuration and ensure the client IP is allowed"
			} else if strings.Contains(errorMsg, "connection refused") {
				errorMsg = "Cannot connect to PostgreSQL: Check if the database is running and the host/port are correct"
			} else if strings.Contains(errorMsg, "authentication failed") {
				errorMsg = "PostgreSQL authentication failed: Check username and password"
			} else if strings.Contains(errorMsg, "SSL") {
				errorMsg = "SSL connection failed: Check SSL configuration and certificates"
			}
			respondJSON(w, map[string]string{"status": "unhealthy", "error": errorMsg})
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