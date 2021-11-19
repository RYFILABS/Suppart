const path = require("path");

module.exports = {
	contracts_build_directory: path.join(__dirname, "client/src/contracts"),
	networks: {
		development: {
		  host: "127.0.0.1",
		  port: 7545,
		  network_id: "*" // Match any network id
		}
	  },
	mocha: {
	},
	compilers: {
		solc: {
			version: "0.8.1",    // Fetch exact version from solc-bin (default: truffle's version)
		}
	}
}