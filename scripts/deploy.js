const hre = require("hardhat");

async function main() {

  const NTokenSale = await ethers.getContractFactory("NTokenSale");

  const nTokenSale = await NTokenSale.deploy(
    "0xcDA8eD22bB27Fe84615f368D09B5A8Afe4a99320", // tokenContract 0x29572D9CC8c8687303D28Ab5eD7c96e1Cee2aE91
    "0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7", // busdAddress 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
    5000, // saleSupply
    1000, // timeEndSale in seconds
    "0xf47644e079303263a2de0829895d000900d2fab8", // factoryAddress Pancake 0xa56F17EEdCdcE4BCDADFB6968f0CdBC14754134B  0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    "0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7", // BUSD 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
    "0xcDA8eD22bB27Fe84615f368D09B5A8Afe4a99320", // NarfexAddress in Pancake 0xcDA8eD22bB27Fe84615f368D09B5A8Afe4a99320
    1, //firstNarfexPrice
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
