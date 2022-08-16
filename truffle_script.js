const FlashloanDemo = artifacts.require("FlashloanDemo")
var {ethers} = require("ethers");
const Web3 = require('web3');
const BigNumber = require('bignumber.js');
const U256 = require('uint256');

const url = {
  "ganache": "http://localhost:7545",
  "rinkeby": "https://rinkeby.infura.io/v3/768ea9df02e44a5482683ce6e7f1649e",
  "avax_fuji": "https://rpc.ankr.com/avalanche_fuji",
  "avax_mainnet": "https://rpc.ankr.com/avalanche"
};
const myArgs = process.argv;
const network = myArgs.at(-1)
const provider = new ethers.providers.JsonRpcProvider(url[network]);
const web3 = new Web3(url[network])


const test = async () => {
  // var flashloanDemo = await FlashloanDemo.deployed()
  // console.log(flashloanDemo.address)
  // const signer = new ethers.Wallet(process.env.cra_wallet_3_cohort_1_key, provider)
  // var flashloanDemo =  new ethers.Contract("0x81E13589713BBd80153631892B60861c6E4e4Fa1", FlashloanDemo["abi"], signer) // AVAX Mainnet contract

  const signer = new ethers.Wallet(process.env.faucet_pk, provider)
  var flashloanDemo =  new ethers.Contract("0x4b2F4D70356e12115d7513be6c80E046d9b19F30", FlashloanDemo["abi"], signer) // AVAX Fuji contract

  // ================= RECOVER AVAX =====================
  // var tx = await flashloanDemo.withdraw("0x0000000000000000000000000000000000000000");
  // ====================================================
  var amount = await web3.utils.toWei("12")
  var amount_int = web3.utils.toBN(amount).toString()
  console.log(amount_int)

  var wavax = await web3.utils.toChecksumAddress("0xd00ae08403B9bbb9124bB305C09058E32C39A48c".toLowerCase()) // WAVAX Fuji
  var jtoken = await web3.utils.toChecksumAddress("0xf558ea6C3379ed5C33D8e91a2ED0b59d858303A9".toLowerCase()) // JToken Fuji
  // var wavax = await web3.utils.toChecksumAddress("0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7".toLowerCase()) // WAVAX Mainnet
  // var usdc = await web3.utils.toChecksumAddress("0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E".toLowerCase()) // USDC Mainnet !!!! 6 decimals !!!!
  // var dai = await web3.utils.toChecksumAddress("0xd586E7F844cEa2F87f50152665BCbc2C279D8d70".toLowerCase()) // DAI Mainnet
  var buyJoe = true

  var gasPrice = 100678112814 //circa 100nAVAX
  // var flash = await flashloanDemo.flashloan(wavax, amount_int, buyJoe, wavax, dai, {'gasLimit': 500000, 'gasPrice': gasPrice});
  // var flash = await flashloanDemo.flashloan(wavax, amount_int, buyJoe, wavax, usdc, {'gasLimit': 800000, 'maxFeePerGas': gasPrice * 2, 'maxPriorityFeePerGas': 10000000});
  // var flash = await flashloanDemo.flashloan(wavax, amount_int, buyJoe, wavax, usdc, {'gasLimit': 800000})
  var flash = await flashloanDemo.flashloan(wavax, amount_int, buyJoe, wavax, jtoken, {'gasLimit': 800000})
  console.log(flash)

}


const test2 = async () => {

  contract  = await betting.deployed()

  // const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:7545");
  // var WSS_URL = "wss://127.0.0.1:7545"
  // const web3 = new Web3(new Web3.providers.WebsocketProvider(WSS_URL));

  // console.log(Object.keys(dbank))

  // var mint = await token.mint(myAccount, web3.utils.toWei('1000'))

  // const contract = new web3.eth.Contract(dbank.abi, dbank.address)

  contract.events.allEvents({})
    .on('data', async function(event){
        console.log("========= EVENT ===========")
        console.log(event.event)
        console.log(event.returnValues);
        console.log("===========================")
        // console.log(event)
        // Do something here
    })
    .on('error', console.error);
  

  var accounts = await web3.eth.getAccounts()
  var account = accounts[0]

  const dep = await deposit(5, account);

  // const withd = await withdraw(account);

}

const deposit = async (amount, account) => {
  // var deposit = await dbank.deposit({value: web3.utils.toWei(amount.toString()), from: account})

  var bal = await dbank.etherBalanceOf(account)
  var time = await dbank.depositStart(account)
  console.log(web3.utils.fromWei(bal).toString())
  console.log(new Date(parseInt(time, 10)*1000))

  var isDeposited = await dbank.isDeposited(account)
  console.log(isDeposited)
}

const withdraw = async (account) => {
  
  var withdraw = await dbank.withdraw()
  var bal = await dbank.etherBalanceOf(account)
  console.log(web3.utils.fromWei(bal).toString())

  isDeposited = await dbank.isDeposited(account)
  console.log(isDeposited)

  var bal = await token.balanceOf(account)
  console.log(web3.utils.fromWei(bal).toString())

  var totalSupply = await token.totalSupply()
  console.log(web3.utils.fromWei(totalSupply).toString())
}

module.exports = test;




