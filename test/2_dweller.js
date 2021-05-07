const { ethers } = require('ethers')
const Registry = artifacts.require('Vault74Registry')
const Dweller = artifacts.require('DwellerID')
const { loadSecret, getWallet, processPublicKey } = require('../utils')

const secret = loadSecret()

contract('Dweller', accounts => {
  it('Registry contract should be deployed', async function () {
    const instance = await Registry.deployed()

    assert.notEqual(instance, null)
  })

  it('User should be able to register', async function () {
    const instance = await Registry.deployed()

    const username = 'Dweller Name'
    const wallet = getWallet(secret, 1)
    const pubkey = processPublicKey(wallet)

    let error = null

    await instance
      .createDweller(username, pubkey, { from: accounts[1] })
      .catch(e => {
        error = e
      })

    assert.equal(error, null, 'Unable to create dweller')

    const dwellerID = await instance.getDwellerId(accounts[1])

    assert.notEqual(
      dwellerID,
      ethers.constants.AddressZero,
      'Missing dweller address for the current account'
    )
  })

  it("It's possible to retrieve the dweller information", async function () {
    const instance = await Registry.deployed()

    const dwellerAddress = await instance.getDwellerId(accounts[1])

    let error = null

    const dwellerInstance = await Dweller.at(dwellerAddress).catch(e => {
      error = e
    })

    const dweller = await dwellerInstance.getDweller().catch(e => {
      error = e
    })

    assert.equal(error, null, 'Something went wrong')
    assert.equal(accounts[1], dweller.address_, 'Dweller address mismatch')
  })

  it('User should be able to update name', async function () {
    const instance = await Registry.deployed()

    const dwellerAddress = await instance.getDwellerId(accounts[1])

    let connectionError = null
    const dwellerInstance = await Dweller.at(dwellerAddress).catch(e => {
      connectionError = e
    })

    const nameBefore = await dwellerInstance.name()

    const newName = 'New Dweller Name'
    await dwellerInstance.setDwellerName(newName, { from: accounts[1] })

    const nameAfter = await dwellerInstance.name()

    assert.notEqual(nameBefore, nameAfter, 'Name did not change')
    assert.equal(nameAfter, newName, 'Unable to update dweller name')
    assert.equal(connectionError, null, 'Unable to locate dweller contract')
  })

  it('User should be able to update photohash', async function () {
    const instance = await Registry.deployed()

    const dwellerAddress = await instance.getDwellerId(accounts[1])

    let connectionError = null
    const dwellerInstance = await Dweller.at(dwellerAddress).catch(e => {
      connectionError = e
    })

    const photoHashBefore = await dwellerInstance.photoHash()

    const newPhotoHash = 'newphotohash'
    await dwellerInstance.setPhoto(newPhotoHash, { from: accounts[1] })

    const photoHashAfter = await dwellerInstance.photoHash()

    assert.notEqual(
      photoHashBefore,
      photoHashAfter,
      'Photo Hash did not change'
    )
    assert.equal(
      photoHashAfter,
      newPhotoHash,
      'Unable to update dweller photo hash'
    )
    assert.equal(connectionError, null, 'Unable to locate dweller contract')
  })
})
