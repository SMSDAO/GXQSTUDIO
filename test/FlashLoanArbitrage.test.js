const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("FlashLoanArbitrage", function () {
  let flashLoanArbitrage;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    // Get signers
    [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy the contract
    const FlashLoanArbitrage = await ethers.getContractFactory("FlashLoanArbitrage");
    flashLoanArbitrage = await FlashLoanArbitrage.deploy();
    await flashLoanArbitrage.waitForDeployment();
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await flashLoanArbitrage.owner()).to.equal(owner.address);
    });

    it("Should have default fee percentage of 50", async function () {
      expect(await flashLoanArbitrage.feePercentage()).to.equal(50);
    });
  });

  describe("Fee Configuration", function () {
    it("Should allow owner to set fee config", async function () {
      await flashLoanArbitrage.setFeeConfig(addr1.address, 30);
      
      expect(await flashLoanArbitrage.feeRecipient()).to.equal(addr1.address);
      expect(await flashLoanArbitrage.feePercentage()).to.equal(30);
    });

    it("Should not allow non-owner to set fee config", async function () {
      await expect(
        flashLoanArbitrage.connect(addr1).setFeeConfig(addr2.address, 40)
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Should not allow fee percentage greater than 100", async function () {
      await expect(
        flashLoanArbitrage.setFeeConfig(addr1.address, 101)
      ).to.be.revertedWith("Fee percentage too high");
    });
  });

  describe("Price Oracle", function () {
    it("Should allow owner to set price oracle", async function () {
      const tokenAddress = "0x1111111111111111111111111111111111111111";
      const oracleAddress = "0x2222222222222222222222222222222222222222";
      
      await flashLoanArbitrage.setPriceOracle(tokenAddress, oracleAddress);
      
      expect(await flashLoanArbitrage.priceOracles(tokenAddress)).to.equal(oracleAddress);
    });

    it("Should not allow non-owner to set price oracle", async function () {
      const tokenAddress = "0x1111111111111111111111111111111111111111";
      const oracleAddress = "0x2222222222222222222222222222222222222222";
      
      await expect(
        flashLoanArbitrage.connect(addr1).setPriceOracle(tokenAddress, oracleAddress)
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });
  });

  describe("ETH Handling", function () {
    it("Should accept ETH", async function () {
      const tx = await owner.sendTransaction({
        to: await flashLoanArbitrage.getAddress(),
        value: ethers.parseEther("1.0")
      });
      
      await tx.wait();
      
      const balance = await ethers.provider.getBalance(await flashLoanArbitrage.getAddress());
      expect(balance).to.equal(ethers.parseEther("1.0"));
    });
  });
});