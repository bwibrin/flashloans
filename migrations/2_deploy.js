const MockArbitrage = artifacts.require("MockArbitrage");
const MyFlashLoan = artifacts.require("MyFlashLoan");

module.exports = function (deployer) {
  const arbitrage = await deployer.deploy(MockArbitrage, 0.1*1e18);
  const flashloan = await deployer.deploy(MyFlashLoan);

  
};
