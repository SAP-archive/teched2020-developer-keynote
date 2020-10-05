package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"math"
)

type CalculationResult struct {
	Credits float64
}

type CalculationError struct {
	error string
}

func calculateDonationCredit(usd float64) float64 {

	switch {
	case usd == 0: return 0
	case usd < 10: return round(0.1 * usd)
	case usd < 100: return round(0.15 * usd)
	case usd < 1000: return round(0.2 * usd)
	case usd < 10000: return round(0.5 * usd)
	case usd >= 10000: return round(2 * usd)
	}
	return 0
}

func round(value float64) float64 {
	return math.Round(value*100)/100
}

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

func calculationHandler(w http.ResponseWriter, r *http.Request) {
	Calculate(w, r)
}

func setupRoutes() {
	http.HandleFunc("/conversion", calculationHandler)
}

func main() {
	fmt.Println("Go Web App Started on Port 3000")
	fmt.Println(calculateDonationCredit(666.66))
	fmt.Println(calculateDonationCredit(12345.88))
	fmt.Println(calculateDonationCredit(1000004335.9888))
	setupRoutes()
	http.ListenAndServe(":3000", nil)
}
