const hre = require("hardhat");

async function main() {

  const NTokenSale = await ethers.getContractFactory("NTokenSale");

  const nTokenSale = await NTokenSale.deploy(
    "0x3764Be118a1e09257851A3BD636D48DFeab5CAFE", // tokenContract
    "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56", // busdAddress
    "0x1570fd96f93629c3B0bfA1E892eAd924944635F7", // pair Narfex -> BUSD in PancakeSwap
    800000, // saleSupply
    30000, // minimum amount of deposit to buy in busd for each user
    100000, // maximum amount of deposit for sale in busd for each user 
    "0x9e8db3942797d2578f48caf5663eb22e286ad84b", // owner address 
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
