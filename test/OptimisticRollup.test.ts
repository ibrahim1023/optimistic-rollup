const { expect } = require("chai");
const hre = require("hardhat");
const { MerkleTree } = require("merkletreejs");
const { formatBytes32String, parseEther, ethers } = require("ethers");
const keccak256 = require("keccak256");

describe("Optimistic Rollup Contract", function () {
  let optimisticRollup: any;
  let fraudProof: any;
  let token: any;
  let owner: any;

  let merkleTree: any, merkleRoot, leaves, claims: any;

  before(async () => {
    [owner] = await hre.ethers.getSigners();

    // Deploy the ERC20 token
    const Token = await hre.ethers.getContractFactory("Token");
    token = await Token.deploy();

    const OptimisticRollup = await hre.ethers.getContractFactory(
      "OptimisticRollup"
    );
    optimisticRollup = await OptimisticRollup.deploy(token.target);

    const FraudProof = await hre.ethers.getContractFactory("FraudProof");

    fraudProof = await FraudProof.deploy(optimisticRollup.target);

    await token
      .connect(owner)
      .approve(optimisticRollup.target, parseEther("100"));
  });

  it("Should allow deposits", async () => {
    let amount = parseEther("1");

    // User1 deposits tokens into the rollup
    await optimisticRollup.connect(owner).deposit(amount);

    // Check balance in the rollup
    const user1Balance = await optimisticRollup.balances(owner.address);
    expect(user1Balance).to.equal(amount);
  });

  it("Should allow withdrawals", async () => {
    let amount = parseEther("0.5");

    // User1 deposits tokens into the rollup
    await optimisticRollup.connect(owner).withdraw(amount);

    // Check balance in the rollup
    const user1Balance = await optimisticRollup.balances(owner.address);
    expect(user1Balance).to.equal(amount);
  });

  it("Should allow a valid state challenge and prevent invalid challenges", async function () {
    // Setup state roots
    const newStateRoot = ethers.encodeBytes32String("state1");
    const newStateRoot2 = ethers.encodeBytes32String("state2");

    // Update state root to 'state1'
    await optimisticRollup.updateState(newStateRoot);

    // Update state root to 'state2'
    await optimisticRollup.updateState(newStateRoot2);

    // Try to challenge the latest state root (should revert)
    await expect(
      optimisticRollup.challengeState(newStateRoot2)
    ).to.be.revertedWith("Cannot challenge latest state root");

    // Challenge an old state root (should succeed)
    await expect(optimisticRollup.challengeState(newStateRoot))
      .to.emit(optimisticRollup, "FraudChallenge")
      .withArgs(newStateRoot, owner.address); // Ensure correct event and args are emitted
  });

  it("Should reject invalid claim", async () => {
    const newStateRoot = ethers.encodeBytes32String("state1");
    const newStateRoot2 = ethers.encodeBytes32String("state2");

    // Update the state root (this simulates an off-chain service)
    await optimisticRollup.updateState(newStateRoot);

    // Verify state root is updated
    expect(await optimisticRollup.latestStateRoot()).to.equal(newStateRoot);

    // Try to challenge with an invalid state root (no proof submitted)
    await expect(
      fraudProof.submitFraudProof(newStateRoot2, newStateRoot, [])
    ).to.be.revertedWith("Invalid proof");
  });
});
