const main = async () => {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    console.log("Account balance:", (await deployer.getBalance()).toString());

    const Web3Gifts = await ethers.getContractFactory("Web3GiftsNFT");
    const web3gifts = await Web3Gifts.deploy("Web3Gifts", "W3G", "ipfs://QmXqUMkNLRdpjHfwoAomzXPz9HfTLMZVsnjsX9HwbHJaBe");

    console.log("Contract address:", web3gifts.address);
}

const run = async () => {
    try {
        await main()
        process.exit(0)
    } catch (error) {
        console.log(error)
        process.exit(1)
    }
}

run()