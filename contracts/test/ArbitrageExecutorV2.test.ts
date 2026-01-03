import { ethers } from "hardhat";
import { expect } from "chai";

describe("ArbitrageExecutorV2", () => {
  async function deploy() {
    const [owner, user, admin, dev] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("MockERC20");
    const token = await Token.deploy("Mock", "MOCK", ethers.parseEther("1000000"));

    const Router = await ethers.getContractFactory("MockRouter");
    const routerProfit = await Router.deploy(10100); // +1%
    const routerLoss = await Router.deploy(9900); // -1%

    const Flash = await ethers.getContractFactory("MockFlashLoanProvider");
    const flash = await Flash.deploy();

    const Exec = await ethers.getContractFactory("ArbExecutor"); // treat ArbExecutor as V2 equivalent
    const exec = await Exec.deploy(admin.address, dev.address, 500); // 5% admin fee

    await token.transfer(flash, ethers.parseEther("100000"));
    await token.transfer(exec, ethers.parseEther("1000")); // seed dust

    return { owner, user, admin, dev, token, routerProfit, routerLoss, flash, exec };
  }

  it("distributes fees only on profit", async () => {
    const { user, admin, dev, token, routerProfit, flash, exec } = await deploy();
    const amount = ethers.parseEther("1000");
    const path = [token, token].map((t) => t.target);

    await token.connect(user).approve(routerProfit, ethers.MaxUint256);
    await token.connect(user).approve(exec, ethers.MaxUint256);
    await token.connect(user).approve(flash, ethers.MaxUint256);

    const balAdminBefore = await token.balanceOf(admin);
    const balDevBefore = await token.balanceOf(dev);
    const balUserBefore = await token.balanceOf(user);

    await exec
      .connect(user)
      .executeFlashArb(
        flash,
        token,
        amount,
        ethers.id("dexToDex"),
        routerProfit,
        routerProfit,
        path,
        path,
        0
      );

    const balAdminAfter = await token.balanceOf(admin);
    const balDevAfter = await token.balanceOf(dev);
    const balUserAfter = await token.balanceOf(user);

    expect(balAdminAfter).to.be.gt(balAdminBefore);
    expect(balDevAfter).to.be.gt(balDevBefore);
    expect(balUserAfter).to.be.gt(balUserBefore);
  });

  it("reverts when paused", async () => {
    const { exec, user, token, routerProfit, flash } = await deploy();
    await exec.setPaused(true);
    const path = [token, token].map((t) => t.target);
    await expect(
      exec
        .connect(user)
        .executeFlashArb(
          flash,
          token,
          ethers.parseEther("1"),
          ethers.id("dexToDex"),
          routerProfit,
          routerProfit,
          path,
          path,
          0
        )
    ).to.be.revertedWith("paused");
  });

  it("no fees when no profit", async () => {
    const { user, admin, dev, token, routerLoss, flash, exec } = await deploy();
    const amount = ethers.parseEther("1000");
    const path = [token, token].map((t) => t.target);

    const adminBefore = await token.balanceOf(admin);
    const devBefore = await token.balanceOf(dev);
    await expect(
      exec
        .connect(user)
        .executeFlashArb(
          flash,
          token,
          amount,
          ethers.id("dexToDex"),
          routerLoss,
          routerLoss,
          path,
          path,
          0
        )
    ).to.be.reverted; // insufficient profit, revert

    expect(await token.balanceOf(admin)).to.eq(adminBefore);
    expect(await token.balanceOf(dev)).to.eq(devBefore);
  });
});