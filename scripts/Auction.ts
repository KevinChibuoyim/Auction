import { ethers } from "hardhat";

async function main() {

  const Auction = await ethers.getContractFactory("Auction");
  const auction = await Auction.deploy(BeneficiaryOfAuction, AuctionEndTime);

  await auction.deployed();

  console.log(`Started an Auction Contract deployed to ${auction.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});


