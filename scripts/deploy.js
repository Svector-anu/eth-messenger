const hre = require("hardhat");

async function main() {
  console.log("Deploying ETHMessenger to Base...");

  const ETHMessenger = await hre.ethers.getContractFactory("ETHMessenger");
  const messenger = await ETHMessenger.deploy();
  await messenger.waitForDeployment();
  
  const address = await messenger.getAddress();
  
  console.log("ETHMessenger deployed to:", address);
  console.log("View on BaseScan:", `https://basescan.org/address/${address}`);
  
  console.log("Waiting for block confirmations...");
  await messenger.deploymentTransaction().wait(5);
  
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