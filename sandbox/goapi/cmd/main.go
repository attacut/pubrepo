package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"
)

type HealthResponse struct {
	Status    string    `json:"status"`
	Timestamp time.Time `json:"timestamp"`
	Service   string    `json:"service"`
	Version   string    `json:"version"`
}

func healthCheckHandler(w http.ResponseWriter, r *http.Request) {
	// Set response headers
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)

	// Create health response
	response := HealthResponse{
		Status:    "healthy",
		Timestamp: time.Now(),
		Service:   "aaaa",
		Version:   "1.0.0",
	}

	// Encode and send response
	json.NewEncoder(w).Encode(response)
}

func main() {
	// Setup routes
	http.HandleFunc("/api/v1/health", healthCheckHandler)

	// Start server
	port := ":8080"
	fmt.Printf("🚀 Server starting on port %s\n", port)
	fmt.Printf("📋 Health check available at: http://localhost%s/healthcheck\n", port)

	log.Fatal(http.ListenAndServe(port, nil))
}
