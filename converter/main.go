package main

import (
	"encoding/json"
	"fmt"
	"math"
	"net/http"
	"strconv"
)

// CalculationResult represents the data structure for the API response containing the calculated credits.
type CalculationResult struct {
	Credits float64
}

// CalculationError represents the error case if something goes wrong while calculating the credit amount.
type CalculationError struct {
	error string
}

// The calculateDonationCredit method is used to calculate the credit amount for each incoming sales order.
func calculateDonationCredit(usd float64) float64 {

	switch {
	case usd == 0:
		return 0
	case usd < 10:
		return round(0.1 * usd)
	case usd < 100:
		return round(0.15 * usd)
	case usd < 1000:
		return round(0.2 * usd)
	case usd < 10000:
		return round(0.5 * usd)
	case usd >= 10000:
		return round(2 * usd)
	}
	return 0
}

// A simple rounding method to round to two digits after comma.
func round(value float64) float64 {
	return math.Round(value*100) / 100
}

// Calculate will trigger the credit calculation and builds the response payload for the incoming request.
func Calculate(w http.ResponseWriter, r *http.Request) {

	fmt.Println("GET params were:", r.URL.Query())
	salesAmountString := r.URL.Query().Get("salesAmount")

	if salesAmount, err := strconv.ParseFloat(salesAmountString, 64); err == nil {
		fmt.Println("Debug:")
		fmt.Println("input variable is:", salesAmount)
		donCredits := calculateDonationCredit(salesAmount)

		calculationResult := CalculationResult{Credits: donCredits}
		w.Header().Set("Content-Type", "application/json") // this
		json.NewEncoder(w).Encode(calculationResult)
	}

}

func Welcome(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Welcome to the SAP TechEd Developer Keynote 2020")
}

// The calculationHandler abstracts the calculate method from the public API.
func calculationHandler(w http.ResponseWriter, r *http.Request) {
	Calculate(w, r)
}

// Setting up the routes for incoming requests.
func setupRoutes() {
	http.HandleFunc("/", Welcome)
	http.HandleFunc("/conversion", calculationHandler)
}

// The main method of the GO application setting up the routes and starting the http server.
func main() {
	fmt.Println("Go Web App Started on Port 8080")
	setupRoutes()
	http.ListenAndServe(":8080", nil)
}
