const StickerFactory = artifacts.require("StickerFactory");
const Sticker = artifacts.require("Sticker");

contract("StickerFactory", (accounts) => {
  const price = web3.utils.toWei("1");
  const lowerPrice = web3.utils.toWei("0.5");

  it("StickerFactory should be deployed", async function () {
    const instance = await StickerFactory.deployed();

    assert.notEqual(instance, null);
  });

  it("Should register a new artist", async function () {
    const factoryInstance = await StickerFactory.deployed();

    let error = null;
    await factoryInstance
      .registerArtist(
        accounts[1],
        "Banksy",
        "Qmaz17CGuuo2gU9V9VW3fHs49ufGVA1hvr3e7r4fonzcsG",
        "You don't know me, but I know you."
      )
      .catch((e) => {
        error = e;
      });

    assert.equal(error, null, "A new artist was registered");
  });

  it("It should be possible to get the artist details", async function () {
    const factoryInstance = await StickerFactory.deployed();

    let error = null;
    const artist = await factoryInstance.artists(accounts[1]).catch((e) => {
      error = e;
    });
    assert.equal(error, null, "It is not possible to get artist details");
    assert.equal(
      artist.name,
      "Banksy",
      "It is not possible to get artist name"
    );
  });

  it("Users should be able to create a new sticker", async function () {
    const instance = await StickerFactory.deployed();

    const setsBefore = await instance.getAvailableSets();

    await instance.createSticker("MySticker", "MyS", 2, "http://", price, {
      from: accounts[1],
    });

    const setsAfter = await instance.getAvailableSets();

    assert.notEqual(
      setsBefore.length,
      setsAfter.length,
      "The new set has not been created"
    );
  });

  it("Creator must receive the first item", async function () {
    const factoryInstance = await StickerFactory.deployed();
    const sets = await factoryInstance.getAvailableSets();
    assert(sets.length > 0, "No sets available. Unable to proceed with test");
    const stickerContractAddress = sets[0].stickerContract;
    const instance = await Sticker.at(stickerContractAddress);

    const balance = await instance.balanceOf(accounts[1]);

    assert.equal(
      balance,
      1,
      "The first token has not been minted to the creator"
    );
  });

  it("It's not possible to buy a sticker at lower price", async function () {
    const factoryInstance = await StickerFactory.deployed();
    const sets = await factoryInstance.getAvailableSets();
    assert(sets.length > 0, "No sets available. Unable to proceed with test");
    const stickerContractAddress = sets[0].stickerContract;
    const instance = await Sticker.at(stickerContractAddress);

    const balanceBefore = await instance.balanceOf(accounts[2]);

    let error = null;
    await instance
      .addSet({ from: accounts[2], value: lowerPrice })
      .catch((e) => {
        error = e;
      });

    assert.notEqual(error, null, "Sticker has been bought anyway");

    const balanceAfter = await instance.balanceOf(accounts[2]);

    assert.notEqual(
      balanceBefore,
      balanceAfter,
      "The token has not been transferred to the user"
    );
  });

  it("A new user can add the sticker to his address", async function () {
    const factoryInstance = await StickerFactory.deployed();
    const sets = await factoryInstance.getAvailableSets();
    assert(
      sets.length > 0,
      "No sticker available. Unable to proceed with test"
    );
    const stickerContractAddress = sets[0].stickerContract;
    const instance = await Sticker.at(stickerContractAddress);

    const balanceBefore = await instance.balanceOf(accounts[2]);

    await instance.addSet({ from: accounts[2], value: price });

    const balanceAfter = await instance.balanceOf(accounts[2]);

    assert.notEqual(
      balanceBefore,
      balanceAfter,
      "The token has not been transferred to the user"
    );
  });

  it("Users cannot buy more than max supply", async function () {
    const factoryInstance = await StickerFactory.deployed();
    const sets = await factoryInstance.getAvailableSets();
    assert(sets.length > 0, "No sets available. Unable to proceed with test");
    const stickerContractAddress = sets[0].stickerContract;
    const instance = await Sticker.at(stickerContractAddress);

    let error = null;
    await instance.addSet({ from: accounts[3], value: price }).catch((e) => {
      error = e;
    });

    assert.notEqual(
      error,
      null,
      "Users can buy more items than the max supply"
    );
  });

  it("Creator can claim money", async function () {
    const factoryInstance = await StickerFactory.deployed();
    const sets = await factoryInstance.getAvailableSets();
    assert(sets.length > 0, "No sets available. Unable to proceed with test");

    const stickerContractAddress = sets[0].stickerContract;

    const instance = await Sticker.at(stickerContractAddress);

    const contractBalanceBefore = await web3.eth.getBalance(stickerContractAddress);

    let error = null;
    await instance.claim({from: accounts[1]}).catch((e) => {
      error = e;
    });

    const contractBalanceAfter = await web3.eth.getBalance(stickerContractAddress);

    assert.equal(
      contractBalanceBefore > contractBalanceAfter,
      true,
      "Contract balance didn't change"
    );
  });

  it("Only creator can claim", async function () {
    const factoryInstance = await StickerFactory.deployed();
    const sets = await factoryInstance.getAvailableSets();
    assert(sets.length > 0, "No sets available. Unable to proceed with test");
    const stickerContractAddress = sets[0].stickerContract;
    const instance = await Sticker.at(stickerContractAddress);

    let error = null;
    await instance.claim({ from: accounts[4] }).catch((e) => {
      error = e;
    });

    assert.notEqual(
      error,
      null,
      "A user that was not a creator was able to claim funds"
    );
  });
});
