const hre = require("hardhat");

async function main() {

  const Vesting = await ethers.getContractFactory("VestingForTeam");

  const vesting = await Vesting.deploy(
    "0x3764Be118a1e09257851A3BD636D48DFeab5CAFE", // tokenContract
    "0x9e8db3942797d2578f48caf5663eb22e286ad84b", // owner address
  );
  await vesting.deployed();

  console.log("Vesting deployed to:", vesting.address);
}

main() 
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });