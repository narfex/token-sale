const hre = require("hardhat");

async function main() {

  const Factory = await ethers.getContractFactory("Factory");

  const factory = await Factory.deploy(
    "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56", // busdAddress
    "0x3764Be118a1e09257851A3BD636D48DFeab5CAFE", // tokenContract
    "0xFbA1906e682BF0032D26EfBA6bFC5229a663B968", // tokenSaleContract //0x9cE316e703C6BdcaD8ada3dCF2d3a4E3911C0d4c
    "0x9e8db3942797d2578f48caf5663eb22e286ad84b", // factoryOwner
  );
  await factory.deployed();

  console.log("Factory deployed to:", factory.address);

  const Pool = await ethers.getContractFactory("Pool");

  const pool = await Pool.deploy(
    "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56", // busdAddress
    "0x3764Be118a1e09257851A3BD636D48DFeab5CAFE", // tokenContract
    "0xFbA1906e682BF0032D26EfBA6bFC5229a663B968", // tokenSaleContract
    "0x9e8db3942797d2578f48caf5663eb22e286ad84b", // factoryOwner
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
//     2, // maxPoolAmount
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
