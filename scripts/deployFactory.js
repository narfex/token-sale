const hre = require("hardhat");
const { ethers } = require("hardhat");

async function main() {

  const Factory = await ethers.getContractFactory("Factory");

  const factory = await Factory.deploy(
    "0xe9e7cea3dedca5984780bafc599bd69add087d56", // busdAddress
    "0x3764be118a1e09257851a3bd636d48dfeab5cafe", // tokenContract
    "0x2a8C50a502B81A6CDd64B16e21CF7e39704215e6", // tokenSaleContract
    "0xa4FF4DBb11F3186a1e96d3e8DD232E31159Ded9B", // factoryOwner
    Number(100).toFixed(0).concat(Number(10**18).toFixed()), // min
    Number(100 * 1000).toFixed(0).concat(Number(10**18).toFixed()), // max
  );
  await factory.deployed();

  console.log("Factory deployed to:", factory.address);

  const Pool = await ethers.getContractFactory("Pool");

  const pool = await Pool.deploy(
    "0xe9e7cea3dedca5984780bafc599bd69add087d56", // busdAddress
    "0x3764be118a1e09257851a3bd636d48dfeab5cafe", // tokenContract
    "0x2a8C50a502B81A6CDd64B16e21CF7e39704215e6", // tokenSaleContract
    "0xa4FF4DBb11F3186a1e96d3e8DD232E31159Ded9B", // factoryOwner
    Number(100 * 1000).toFixed(0).concat(Number(10**18).toFixed()), // max pool amount
    Number(100).toFixed(0).concat(Number(10**18).toFixed()), // min
    Number(100 * 1000).toFixed(0).concat(Number(10**18).toFixed()), // max
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
