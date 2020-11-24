sap.ui.define(["sap/ui/integration/Extension"], function (Extension) {
	"use strict";

	let cache;

	function asc(a, b) {
		return a - b;
	}

	var oExtension = new Extension();

	oExtension.getDerivedData = function () {
		return new Promise(function (resolve) {
			this.getData().then(function (aData) {
				const total = aData.reduce((counter, month) => counter + parseFloat(month.totalcredits), 0);

				//Preaggregation, shouldn't be needed once the flattened datastrucutre is available
				const oCustomerMap = aData.reduce(function (akku, item) {
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

				const oMonthMap = aData.reduce(function (akku, item) {
					if (!akku[item.creationdateyyyymm]) {
						akku[item.creationdateyyyymm] = {
							date: new Date(item.creationdateyyyymm.slice(0, 4) + "-" + item.creationdateyyyymm.slice(4, 6) + "-02") // set to the 2nd to avoid time zone issues
						}
					}
					akku[item.creationdateyyyymm][item.custid] = parseFloat(item.totalcredits);

					return akku;
				}, {});

				const aMonths = Object.keys(oMonthMap).sort();
				const aCustomers = Object.keys(oCustomerMap);

				let avgGrowth = 0;
				const aGrowth = aCustomers.map((customer) => {
					let firstMonth = oCustomerMap[customer][aMonths[0]],
						lastMonth = oCustomerMap[customer][aMonths[aMonths.length - 1]]
					let growth = (lastMonth / firstMonth * 100 - 100);
					avgGrowth += growth / aCustomers.length;
					return +growth.toFixed(1);
				}).sort(asc);

				let oResponse = {
					total: total,
					months: Object.values(oMonthMap),
					customers: Object.values(oCustomerMap),
					avgGrowth: avgGrowth.toFixed(1),
					smallestG: aGrowth[0],
					largestG: aGrowth[aGrowth.length - 1],
					achievement: (total / 800000 * 100 - 100).toFixed(1), // hard-coded assumption
					target: 800000 // hard-coded assumption
				};

				resolve(oResponse);
			});
		}.bind(this));
	};

	oExtension.getData = function () {
		return new Promise(function (resolve) {
			if (cache) {
				resolve(cache);
				return;
			}
			fetch("sap/credits")
				.then(response => response.json())
				.then(data => {
					cache = data.d.results;
					resolve(cache);
				});
		});
	};

	return oExtension;
});
