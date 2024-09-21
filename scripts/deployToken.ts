import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const circlesHubAddress = "0x29b9a7fbb8995b2423a71cc17cf9810798f6c543"; // Replace with the actual address

  const OrganisationToken =
    await ethers.getContractFactory("OrganisationToken");
  const organisationToken = await OrganisationToken.deploy(
    circlesHubAddress,
    deployer.address,
  );

  const deployed = await organisationToken.waitForDeployment();
  const deployedAddress = await deployed.getAddress();
  console.log("OrganisationToken deployed to:", deployedAddress);

  await run("verify:verify", {
    address: deployedAddress,
    constructorArguments: [circlesHubAddress, deployer.address],
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
