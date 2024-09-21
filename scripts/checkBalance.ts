import { ethers } from "ethers";
import tokenABI from "./Token.json";
import { token } from "../typechain-types/@openzeppelin/contracts"; // Update with the path to your ABI

async function main() {
  // Define the token contract address and the address to check the balance of
  const tokenAddress = "0x41584DEDFC28a2f4CeDBB526Ea6C22057CA7c099";
  const addressToCheck = "0x404530CCbE8E4c03edDc314D020fE2c2665F6502";

  // Connect to the provider
  const providerUrl = "https://gnosis-mainnet.public.blastapi.io";
  const provider = new ethers.JsonRpcProvider(providerUrl);

  // Create a contract instance

  const tokenContract = new ethers.Contract(tokenAddress, tokenABI, provider);

  // Call the balanceOf function
  try {
    const balance = await tokenContract.balanceOf(addressToCheck);
    console.log(`Balance of address ${addressToCheck}:`, balance.toString());
  } catch (error) {
    console.error("Error fetching balance:", error);
  }
}

main();
