const hre = require("hardhat");

async function main() {

  const NTokenSale = await ethers.getContractFactory("NTokenSale");

  const nTokenSale = await NTokenSale.deploy(
    "0xcDA8eD22bB27Fe84615f368D09B5A8Afe4a99320", // tokenContract
    "0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7", // busdAddress
    800000, // saleSupply
    9999999, // timeEndSale in seconds
    "0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7", // BUSD in bsc testnet
    "0xcDA8eD22bB27Fe84615f368D09B5A8Afe4a99320", // NarfexAddress in bsc testnet
    "0xf47644e079303263a2de0829895d000900d2fab8", // pair Narfex -> BUSD in PancakeSwap
    30000, // minimum amount of deposit to buy in busd for each user
    100000, // maximum amount of deposit for sale in busd for each user
    );
  await nTokenSale.deployed();

  console.log("NTokenSale deployed to:", nTokenSale.address);
}

main() 
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
