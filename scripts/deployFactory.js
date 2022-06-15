const hre = require("hardhat");

async function main() {

  const Factory = await ethers.getContractFactory("Factory");

  const factory = await Factory.deploy(
    "0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7", // busdAddress
    "0xcDA8eD22bB27Fe84615f368D09B5A8Afe4a99320", // tokenContract
    "0xfe72323a3dAa1a491CBaF32532De0EFBF9eB4B70", // tokenSaleContract
    //"0x29572D9CC8c8687303D28Ab5eD7c96e1Cee2aE91", // factoryOwner
  );
  await factory.deployed();

  console.log("Factory deployed to:", factory.address);

  const Pool = await ethers.getContractFactory("Pool");

  const pool = await Pool.deploy(
    "0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7", // busdAddress
    "0xcDA8eD22bB27Fe84615f368D09B5A8Afe4a99320", // tokenContract
    "0xfe72323a3dAa1a491CBaF32532De0EFBF9eB4B70", // tokenSaleContract
    "0x29572D9CC8c8687303D28Ab5eD7c96e1Cee2aE91", // factoryOwner
    2, // maxPoolAmount
  );
  await pool.deployed();

  console.log("Pool deployed to:", pool.address);
}

main() 
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
  // 0xcDA8eD22bB27Fe84615f368D09B5A8Afe4a99320