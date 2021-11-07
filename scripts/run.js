const main = async () => {
    const contractFactory = await hre.ethers.getContractFactory("MyEpicNFT");
    const contract = await contractFactory.deploy()
    await contract.deployed()
    console.log('Contract deployed to --> ', contract.address)
    let txn = await contract.makeAnEpicNFT()
    // Wait for it to be mined.
    await txn.wait()
    console.log('Transaction mined.')

    // Mint another NFT for fun.
    txn = await contract.makeAnEpicNFT()
    // Wait for it to be mined.
    await txn.wait()
}

const run = async () => {
    try {
        await main()
        process.exit(0)
    } catch (error) {
        process.exit(1)
    }
}

run()