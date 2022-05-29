const hre = require("hardhat");

async function main() {

  const NTokenSale = await ethers.getContractFactory("NTokenSale");
  const nTokenSale = await NTokenSale.deploy();
  await nTokenSale.deployed();

  console.log("NTokenSale deployed to:", nTokenSale.address);

}

main() 
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
