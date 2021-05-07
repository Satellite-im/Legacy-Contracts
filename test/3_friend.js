const Friends = artifacts.require('Friends')
const { processPublicKey, getWallet, loadSecret } = require('../utils')

const secret = loadSecret()

const threadId = [
  '0x4d4649f57169bef4207cb944f8ba838d471996848d88430b0a92824aef931d61',
  '0x4d4649f57169bef4207cb944f8ba838d471996848d88430b0a92824aef931d61'
]

const textileRecipient =
  'bbaareiavmjsv5rxnjtyxbuhnlrtltu2jqmejlzagwvtfzhbfibhszr6syq'

String.prototype.reverse = function () {
  return this.split('')
    .reverse()
    .join('')
}

contract('Friend', accounts => {
  it('Friends contract should be deployed', async function () {
    const instance = await Friends.deployed()

    assert.notEqual(instance, null)
  })

  it('User should be able to send a friend request', async function () {
    const instance = await Friends.deployed()

    const requestsBefore = await instance.getRequests()

    const senderPublicKey = textileRecipient

    let error = null

    await instance
      .makeRequest(accounts[0], senderPublicKey, {
        from: accounts[1]
      })
      .catch(e => {
        error = e
      })

    assert.equal(error, null, 'Unable to make a friend request')

    const requestsAfter = await instance.getRequests()

    assert.notEqual(
      requestsBefore.length,
      requestsAfter.length,
      'Request has not been added'
    )
  })

  it('User cannot send the same request twice', async function () {
    const instance = await Friends.deployed()

    const requestsBefore = await instance.getRequests()

    const senderPublicKey = textileRecipient

    let error = null

    await instance
      .makeRequest(accounts[0], senderPublicKey, {
        from: accounts[1]
      })
      .catch(e => {
        error = e
      })

    assert.notEqual(error, null, 'Unable to make a friend request')

    const requestsAfter = await instance.getRequests()

    assert.equal(
      requestsBefore.length,
      requestsAfter.length,
      "Request has been added even if it shouldn't be"
    )
  })

  it('Receiver should be able to accept a request', async function () {
    const instance = await Friends.deployed()

    const requestsBefore = await instance.getRequests()
    const friendsBefore = await instance.getFriends()
    const senderFriendsBefore = await instance.getFriends({
      from: accounts[1]
    })

    const receiverPublicKey = textileRecipient.reverse()

    let error = null

    await instance
      .acceptRequest(accounts[1], receiverPublicKey, {
        from: accounts[0]
      })
      .catch(e => {
        error = e
      })

    assert.equal(error, null, 'Unable to accept a friend request')

    const requestsAfter = await instance.getRequests()
    const friendsAfter = await instance.getFriends()
    const senderFriendsAfter = await instance.getFriends({
      from: accounts[1]
    })

    assert.notEqual(
      requestsBefore.length,
      requestsAfter.length,
      'Request has not been added'
    )

    assert.notEqual(
      friendsBefore.length,
      friendsAfter.length,
      'Friend has not been moved to the receiver list'
    )

    assert.notEqual(
      senderFriendsBefore.length,
      senderFriendsAfter.length,
      'Friend has not been moved to the sender list'
    )
  })

  it('User should be able to remove a friend', async function () {
    const instance = await Friends.deployed()

    const friendsBefore = await instance.getFriends()
    const otherFriendsbefore = await instance.getFriends({ from: accounts[1] })

    let error = null

    await instance
      .removeFriend(accounts[1], {
        from: accounts[0]
      })
      .catch(e => {
        error = e
      })

    assert.equal(error, null, 'Unable to remove a friend')

    const friendsAfter = await instance.getRequests()
    const otherFriendsAfter = await instance.getFriends({ from: accounts[1] })

    assert.equal(
      friendsBefore.length > friendsAfter.length,
      true,
      'Friend has not been removed'
    )

    assert.equal(
      otherFriendsbefore.length > otherFriendsAfter.length,
      true,
      'Friend has not been removed from the other account'
    )
  })

  it('User should be able to remove a request', async function () {
    const instance = await Friends.deployed()

    const senderPublicKey = processPublicKey(getWallet(secret, 0))

    let error = null

    await instance
      .makeRequest(accounts[0], senderPublicKey, {
        from: accounts[1]
      })
      .catch(e => {
        error = e
      })

    assert.equal(error, null, 'Unable to make a friend request')

    const requestsBefore = await instance.getRequests()

    await instance
      .removeRequest(accounts[0], {
        from: accounts[1]
      })
      .catch(e => {
        error = e
      })

    assert.equal(error, null, 'Unable to remove a friend request')

    const requestsAfter = await instance.getRequests()

    assert.equal(
      requestsBefore.length > requestsAfter.length,
      true,
      'Request has not been removed'
    )
  })

  it('User should be able to deny a request', async function () {
    const instance = await Friends.deployed()

    const senderPublicKey = textileRecipient

    let error = null

    await instance
      .makeRequest(accounts[0], senderPublicKey, {
        from: accounts[1]
      })
      .catch(e => {
        error = e
      })

    assert.equal(error, null, 'Unable to make a friend request')

    const requestsBefore = await instance.getRequests()

    await instance
      .denyRequest(accounts[1], {
        from: accounts[0]
      })
      .catch(e => {
        error = e
      })

    assert.equal(error, null, 'Unable to deny a friend request')

    const requestsAfter = await instance.getRequests()

    assert.equal(
      requestsBefore.length > requestsAfter.length,
      true,
      'Request has not been removed'
    )
  })
})
