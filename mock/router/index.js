var approuter = require('@sap/approuter');
require('@sap/xsenv').loadEnv();

var ar = approuter();

ar.beforeRequestHandler.use(function myMiddleware(req, _res, next) {
	req.headers.apikey = process.env.API_KEY;
	next();
});
ar.start();
