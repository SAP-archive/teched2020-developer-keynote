sap.ui.define(["sap/ui/integration/Extension"], function (Extension) {
	"use strict";

	let cache;

	var oExtension = new Extension();

	oExtension.getDerivedData = function () {
		return new Promise(function (resolve) {
			this.getData().then(function (aData) {
				let oResponse = {
					months: aData.items,
					target: 11000 //TODO hard-coded assumption
				}


				const customers = aData.items.reduce(function (akku, creditsReport) {
					Object.keys(aData.items[1]).forEach((key) => {
						if (key === "Month") {
							return;
						}
						if (!akku[key]) {
							akku[key] = { total: 0, customer: key }
						}
						akku[key][creditsReport.Month] = creditsReport[key];
						akku[key].total += creditsReport[key];
					});

					return akku;
				}, {});

				oResponse.customers = Object.values(customers);
				oResponse.total = oResponse.customers.reduce((subtotal, customer) => subtotal + customer.total, 0);
				oResponse.growth = (oResponse.total / 860).toFixed(1); //TODO hard-coded assumption


				resolve(oResponse);
			});
		}.bind(this));
	};

	oExtension.getData = function () {
		return new Promise(function (resolve, reject) {
			if (!!cache) {
				resolve(cache);
				return;
			}
			fetch('sap/credits.json')
				.then(response => response.json())
				.then(data => resolve(data));
		});
	};

	return oExtension;
});
