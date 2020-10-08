sap.ui.define(["sap/ui/integration/Extension"], function (Extension) {
	"use strict";

	let cache;

	var oExtension = new Extension();

	oExtension.getDerivedData = function () {
		return new Promise(function (resolve) {
			this.getData().then(function (aData) {
				const total = aData.reduce((counter, month) => counter + parseFloat(month.totalcredits), 0);

				let oResponse = {
					total: total,
					growth: (total / 2250 * 100 - 100).toFixed(1), //TODO hard-coded assumption
					target: 2400 //TODO hard-coded assumption
				};


				//Preaggregation, shouldn't be needed once the flattened datastrucutre is available
				const customers = aData.reduce(function (akku, item) {
					if (!akku[item.custid]) {
						akku[item.custid] = {
							total: 0,
							custid: item.custid,
							customername: item.customername,
						}
					}
					akku[item.custid][item.creationdateyyyymm] = parseFloat(item.totalcredits);
					akku[item.custid].total += parseFloat(item.totalcredits);

					return akku;
				}, {});
				oResponse.customers = Object.values(customers);

				const months = aData.reduce(function (akku, item) {
					if (!akku[item.creationdateyyyymm]) {
						akku[item.creationdateyyyymm] = {
							date: new Date(item.creationdateyyyymm.slice(0, 4) + "-" + item.creationdateyyyymm.slice(4, 6))
						}
					}
					akku[item.creationdateyyyymm][item.custid] = parseFloat(item.totalcredits);

					return akku;
				}, {});
				oResponse.months = Object.values(months);

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
			fetch('sap/credits')
				.then(response => response.json())
				.then(data => {
					cache = data.d.results;
					resolve(cache)
				});
		});
	};

	return oExtension;
});
