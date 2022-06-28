const hre = require("hardhat");
const { ethers } = require("hardhat");

async function main() {

  const Factory = await ethers.getContractFactory("Factory");

  const factory = await Factory.deploy(
    "0x78867bbeef44f2326bf8ddd1941a4439382ef2a7", // busdAddress
    "0xcDA8eD22bB27Fe84615f368D09B5A8Afe4a99320", // tokenContract
    "0x33b6bFa80ed5C8f935D6F745787Cc5EAa4736b55", // tokenSaleContract
    "0xa4FF4DBb11F3186a1e96d3e8DD232E31159Ded9B", // factoryOwner
    Number(1 * (10**18)).toFixed(0),
    Number(5 * (10**18)).toFixed(0),
  );
  await factory.deployed();

  console.log("Factory deployed to:", factory.address);

  const Pool = await ethers.getContractFactory("Pool");

  const pool = await Pool.deploy(
    "0x78867bbeef44f2326bf8ddd1941a4439382ef2a7", // busdAddress
    "0xcDA8eD22bB27Fe84615f368D09B5A8Afe4a99320", // tokenContract
    "0x33b6bFa80ed5C8f935D6F745787Cc5EAa4736b55", // tokenSaleContract
    "0xa4FF4DBb11F3186a1e96d3e8DD232E31159Ded9B", // factoryOwner
    Number(10 * (10**18)).toFixed(0), // maxPoolAmount
    Number(1 * (10**18)).toFixed(0), // minimum deposit for user in pools
    Number(5 * (10**18)).toFixed(0), // maximum deposit for user in pools
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

// const hre = require("hardhat");

// async function main() {

//   const Factory = await ethers.getContractFactory("Factory");

//   const factory = await Factory.deploy(
//     "0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7", // busdAddress
//     "0xcDA8eD22bB27Fe84615f368D09B5A8Afe4a99320", // tokenContract
//     "0x9cE316e703C6BdcaD8ada3dCF2d3a4E3911C0d4c", // tokenSaleContract //0x9cE316e703C6BdcaD8ada3dCF2d3a4E3911C0d4c
//     "0x9e8db3942797d2578f48caf5663eb22e286ad84b", // factoryOwner
//   );
//   await factory.deployed();

//   console.log("Factory deployed to:", factory.address);

//   const Pool = await ethers.getContractFactory("Pool");

//   const pool = await Pool.deploy(
//     "0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7", // busdAddress
//     "0xcDA8eD22bB27Fe84615f368D09B5A8Afe4a99320", // tokenContract
//     "0x9cE316e703C6BdcaD8ada3dCF2d3a4E3911C0d4c", // tokenSaleContract
//     "0x9e8db3942797d2578f48caf5663eb22e286ad84b", // factoryOwner
//     3, // maxPoolAmount
//     1, // minimum deposit for user in pools
//     2, // maximum deposit for user in pools 
//   );
//   await pool.deployed();

//   console.log("Pool deployed to:", pool.address);
// }

// main() 
//   .then(() => process.exit(0))
//   .catch((error) => {
//     console.error(error);
//     process.exit(1);
//   });
