const hre = require("hardhat");

async function main() {
  console.log("Deploying ETHMessenger to Base...");

  // Get the contract factory
  const ETHMessenger = await hre.ethers.getContractFactory("ETHMessenger");
  
  // Deploy the contract
  const messenger = await ETHMessenger.deploy();
  
  // Wait for deployment to finish
  await messenger.waitForDeployment();
  
  // Get the deployed contract address
  const address = await messenger.getAddress();
  
  console.log("ETHMessenger deployed to:", address);
  console.log("View on BaseScan:", `https://basescan.org/address/${address}`);
  
  // Wait for 5 block confirmations before verifying
  console.log("Waiting for block confirmations...");
  await messenger.deploymentTransaction().wait(5);
  
  // Verify the contract
  console.log("Verifying contract on BaseScan...");
  try {
    await hre.run("verify:verify", {
      address: address,
      constructorArguments: [],
    });
    console.log("Contract verified successfully!");
  } catch (error) {
    if (error.message.includes("Already Verified")) {
      console.log("Contract already verified!");
    } else {
      console.error("Verification failed:", error.message);
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });