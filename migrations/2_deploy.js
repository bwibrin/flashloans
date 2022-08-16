const FlashloanDemo = artifacts.require("FlashloanDemo");

module.exports = async function (deployer) {
  const FUJI_LP_ADDRESS = "0x7fdC1FdF79BE3309bf82f4abdAD9f111A6590C0f"
  const FUJI_JOE_ROUTER = "0xd7f655E3376cE2D7A2b08fF01Eb3B1023191A901"
  const FUJI_PANGOLIN_ROUTER = "0xd7f655E3376cE2D7A2b08fF01Eb3B1023191A901" //Pangolin is not on testnet. So use traderjoe instead

  const AVAX_LP_ADDRESS = "0xb6A86025F0FE1862B372cb0ca18CE3EDe02A318f"
  const AVAX_JOE_ROUTER = "0x60aE616a2155Ee3d9A68541Ba4544862310933d4"
  // const AVAX_PANGOLIN_ROUTER = "0xE54Ca86531e17Ef3616d22Ca28b0D458b6C89106"
  const AVAX_PANGOLIN_ROUTER = "0x60aE616a2155Ee3d9A68541Ba4544862310933d4"


  const myFlashloan = await deployer.deploy(FlashloanDemo, FUJI_LP_ADDRESS, FUJI_JOE_ROUTER, FUJI_PANGOLIN_ROUTER);
  // const myFlashloan = await deployer.deploy(FlashloanDemo, AVAX_LP_ADDRESS, AVAX_JOE_ROUTER, AVAX_PANGOLIN_ROUTER);

  // const myFlashloan = await deployer.deploy(FlashloanDemo);


};
