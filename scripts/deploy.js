const { ethers, run } = require("hardhat");
require("dotenv").config;
const { writeFileSync } = require("fs");
const hre = require("hardhat");

// const {}
async function main() {
  const private_key = process.env.PRIVATE_KEY;
  // const provider = new InfuraProvider("sepolia",infura_key);

  // Provider for Sepolia Testnet
  const provider = new ethers.JsonRpcProvider(
    "https://sepolia.infura.io/v3/0fba3fdf4179467ba9832ac74d77445c"
  );

  // provoider for Matic testnet
  // const provider = new ethers.JsonRpcProvider(
  //   "https://autumn-falling-firefly.matic-testnet.quiknode.pro/c8e3ff914ff86361fd66c6de0e7aed3c878963fb/"
  // );

  // provoider for Scroll sepolia testnet
  // const provider = new ethers.JsonRpcProvider(
  //   "https://winter-ultra-sheet.scroll-testnet.quiknode.pro/3d92ec6b4d0bd800befb790f751b5b79441575a1/"
  // );

  console.log(provider);

  const deployer = new ethers.Wallet(private_key, provider);
  console.log(`Deploying contracts with the account: ${deployer.address}`);
  const balance = await provider.getBalance(deployer);
  // const balanceInEther = ethers.utils.formatEther(balance);
  console.log(balance);
  const HPMTFactory = await ethers.getContractFactory("HPMT");
  const hpmt = await HPMTFactory.connect(deployer).deploy();
  await hpmt.waitForDeployment();
  console.log(`HPMT contract address: ${hpmt.target}`);

  writeFileSync(
    "deploy.json",
    JSON.stringify(
      {
        HPMTContractAddress: hpmt.target,
      },
      null,
      2
    )
  );

  async function verify(contractAddress, args) {
    try {
      await hre.run("verify:verify", {
        address: contractAddress,
        constructorArgument: args,
      });
      console.log("HPMT Contract successfully verified on Etherscan");
    } catch (e) {
      console.log(e);
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error.message);
    process.exit(1);
  });
