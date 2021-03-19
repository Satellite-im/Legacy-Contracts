const ethers = require("ethers");
const { readFileSync } = require("fs");
const Friends = artifacts.require("Friends");

const secret = readFileSync(".secret").toString().trim();

function getWallet(index) {
  return ethers.Wallet.fromMnemonic(secret, `m/44'/60'/0'/0/${index}`);
}

function processPublicKey(wallet) {
  return `0x${wallet.signingKey.publicKey.slice(4)}`;
}

const threadId = [
  "0x4d4649f57169bef4207cb944f8ba838d471996848d88430b0a92824aef931d61",
  "0x4d4649f57169bef4207cb944f8ba838d471996848d88430b0a92824aef931d61",
];

contract("Friend", (accounts) => {
  it("Friends contract should be deployed", async function () {
    const instance = await Friends.deployed();

    assert.notEqual(instance, null);
  });

  it("User should be able to send a friend request", async function () {
    const instance = await Friends.deployed();

    const requestsBefore = await instance.getRequests();

    const senderPublicKey = processPublicKey(getWallet(0));

    let error = null;

    await instance
      .makeRequest(accounts[0], senderPublicKey, {
        from: accounts[1],
      })
      .catch((e) => {
        error = e;
      });

    assert.equal(error, null, "Unable to make a friend request");

    const requestsAfter = await instance.getRequests();

    assert.notEqual(
      requestsBefore.length,
      requestsAfter.length,
      "Request has not been added"
    );
  });

  it("User cannot send the same request twice", async function () {
    const instance = await Friends.deployed();

    const requestsBefore = await instance.getRequests();

    const senderPublicKey = processPublicKey(getWallet(0));

    let error = null;

    await instance
      .makeRequest(accounts[0], senderPublicKey, {
        from: accounts[1],
      })
      .catch((e) => {
        error = e;
      });

    assert.notEqual(error, null, "Unable to make a friend request");

    const requestsAfter = await instance.getRequests();

    assert.equal(
      requestsBefore.length,
      requestsAfter.length,
      "Request has been added even if it shouldn't be"
    );
  });

  it("Receiver should be able to accept a request", async function () {
    const instance = await Friends.deployed();

    const requestsBefore = await instance.getRequests();
    const friendsBefore = await instance.getFriends();
    const senderFriendsBefore = await instance.getFriends({
      from: accounts[1],
    });

    const receiverPublicKey = processPublicKey(getWallet(1));

    let error = null;

    await instance
      .acceptRequest(accounts[1], threadId, receiverPublicKey, {
        from: accounts[0],
      })
      .catch((e) => {
        error = e;
      });

    assert.equal(error, null, "Unable to accept a friend request");

    const requestsAfter = await instance.getRequests();
    const friendsAfter = await instance.getFriends();
    const senderFriendsAfter = await instance.getFriends({
      from: accounts[1],
    });

    assert.notEqual(
      requestsBefore.length,
      requestsAfter.length,
      "Request has not been added"
    );

    assert.notEqual(
      friendsBefore.length,
      friendsAfter.length,
      "Friend has not been moved to the receiver list"
    );

    assert.notEqual(
      senderFriendsBefore.length,
      senderFriendsAfter.length,
      "Friend has not been moved to the sender list"
    );
  });

  it("User should be able to remove a friend", async function () {
    const instance = await Friends.deployed();

    const friendsBefore = await instance.getFriends();

    let error = null;

    await instance
      .removeFriend(accounts[1], {
        from: accounts[0],
      })
      .catch((e) => {
        error = e;
      });

    assert.equal(error, null, "Unable to remove a friend");

    const friendsAfter = await instance.getRequests();

    assert.equal(
      friendsBefore.length > friendsAfter.length,
      true,
      "Friend has not been removed"
    );
  });

  it("User should be able to remove a request", async function () {
    const instance = await Friends.deployed();

    const senderPublicKey = processPublicKey(getWallet(0));

    let error = null;

    await instance
      .makeRequest(accounts[0], senderPublicKey, {
        from: accounts[1],
      })
      .catch((e) => {
        error = e;
      });

    assert.equal(error, null, "Unable to make a friend request");

    const requestsBefore = await instance.getRequests();

    await instance
      .removeRequest(accounts[0], {
        from: accounts[1],
      })
      .catch((e) => {
        error = e;
      });

    assert.equal(error, null, "Unable to remove a friend request");

    const requestsAfter = await instance.getRequests();

    assert.equal(
      requestsBefore.length > requestsAfter.length,
      true,
      "Request has not been removed"
    );
  });

  it("User should be able to deny a request", async function () {
    const instance = await Friends.deployed();

    const senderPublicKey = processPublicKey(getWallet(0));

    let error = null;

    await instance
      .makeRequest(accounts[0], senderPublicKey, {
        from: accounts[1],
      })
      .catch((e) => {
        error = e;
      });

    assert.equal(error, null, "Unable to make a friend request");

    const requestsBefore = await instance.getRequests();

    await instance
      .denyRequest(accounts[1], {
        from: accounts[0],
      })
      .catch((e) => {
        error = e;
      });

    assert.equal(error, null, "Unable to deny a friend request");

    const requestsAfter = await instance.getRequests();

    assert.equal(
      requestsBefore.length > requestsAfter.length,
      true,
      "Request has not been removed"
    );
  });
});
