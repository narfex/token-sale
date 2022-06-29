const hre = require("hardhat");

async function main() {

  const NTokenSale = await ethers.getContractFactory("NarfexTokenSale");

  const nTokenSale = await NTokenSale.deploy(
    "0x3764be118a1e09257851a3bd636d48dfeab5cafe", // tokenContract
    "0xe9e7cea3dedca5984780bafc599bd69add087d56", // busdAddress
    "0x1570fd96f93629c3b0bfa1e892ead924944635f7", // pair Narfex -> BUSD in PancakeSwap
    Number(30 * 1000).toFixed(0).concat(Number(10**18).toFixed()), // min
    Number(100 * 1000).toFixed(0).concat(Number(10**18).toFixed()), // max
    Number(0.4 * (10**18)).toFixed(0), // First Narfex Price
    60 * 60 * 24 * 60, // First unlock in seconds
    60 * 60 * 24 * 120, // Percentage unlock in seconds
  );
  await nTokenSale.deployed();

  console.log("NarfexTokenSale deployed to:", nTokenSale.address);
}

main() 
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

// const hre = require("hardhat");

// async function main() {

//   const NTokenSale = await ethers.getContractFactory("NTokenSale");

//   const nTokenSale = await NTokenSale.deploy(
//     "0x3764Be118a1e09257851A3BD636D48DFeab5CAFE", // tokenContract
//     "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56", // busdAddress
//     "0x1570fd96f93629c3B0bfA1E892eAd924944635F7", // pair Narfex -> BUSD in PancakeSwap
//     800000, // saleSupply
//     30000, // minimum amount of deposit to buy in busd for each user
//     100000, // maximum amount of deposit for sale in busd for each user 
//     "0x9e8db3942797d2578f48caf5663eb22e286ad84b", // owner address 
//     );
//   await nTokenSale.deployed();

//   console.log("NTokenSale deployed to:", nTokenSale.address);
// }

// main() 
//   .then(() => process.exit(0))
//   .catch((error) => {
//     console.error(error);
//     process.exit(1);
//   });
