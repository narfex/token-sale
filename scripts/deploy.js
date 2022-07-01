const hre = require("hardhat");

async function main() {

  const NTokenSale = await ethers.getContractFactory("NarfexPrivateSale");

  const nTokenSale = await NTokenSale.deploy(
    "0x3764be118a1e09257851a3bd636d48dfeab5cafe", // tokenContract
    "0xe9e7cea3dedca5984780bafc599bd69add087d56", // busdAddress
    "0x1570fd96f93629c3b0bfa1e892ead924944635f7", // pair Narfex -> BUSD in PancakeSwap
    Number(30 * 1000).toFixed(0).concat(Number(10**18).toFixed()), // min
    Number(100 * 1000).toFixed(0).concat(Number(10**18).toFixed()), // max
    60 * 60 * 24 * 60, // First unlock in seconds
    60 * 60 * 24 * 120, // Percentage unlock in seconds
    Number(0.4 * (10**18)).toFixed(0), // First Narfex Price
  );
  await nTokenSale.deployed();

  console.log("NarfexPrivateSale deployed to:", nTokenSale.address);
}

main() 
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });