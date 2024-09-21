import { ethers, run } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  // console.log("Deploying contracts with the account:", deployer.address);
  //
  const tokenAddress = "0xc37e0576ce3d29db608efae3b25c2dc9d6c884b7"; // Replace with the actual token address
  //
  // const IdeaVoting = await ethers.getContractFactory("IdeaVoting");
  // const ideaVoting = await IdeaVoting.deploy(tokenAddress, deployer.address);
  //
  // const deployed = await ideaVoting.waitForDeployment();
  // console.log("IdeaVoting deployed to:", await deployed.getAddress());

  // // Verify the contract on Etherscan
  await run("verify:verify", {
    address: "0x98ea56b8afa5ebb886084a8eb6bd6d47c38fa046",
    constructorArguments: [tokenAddress, deployer.address],
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
