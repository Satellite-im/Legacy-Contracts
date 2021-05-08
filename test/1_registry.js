const { ethers } = require('ethers')
const Registry = artifacts.require('Vault74Registry')
const Friends = artifacts.require('Friends')
const { loadSecret, getWallet, processPublicKey } = require('../utils')

const secret = loadSecret()

contract('Registry', accounts => {
  it('Registry contract should be deployed', async function () {
    const instance = await Registry.deployed()

    assert.notEqual(instance, null)
  })

  it('Friends contract should be deployed', async function () {
    const instance = await Friends.deployed()

    assert.notEqual(instance, null)
  })

  it('User should be able to register', async function () {
    const instance = await Registry.deployed()

    const username = 'DwellerName'
    const wallet = getWallet(secret, 0)
    const pubkey = processPublicKey(wallet)

    let error = null

    await instance.createDweller(username, pubkey).catch(e => {
      error = e
    })

    assert.equal(error, null, 'Unable to create dweller')

    const dwellerID = await instance.getDwellerId(accounts[0])

    assert.notEqual(
      dwellerID,
      ethers.constants.AddressZero,
      'Missing dweller address for the current account'
    )
  })

  it('User should be able to create a new server', async function () {
    const instance = await Registry.deployed()

    const serverName = ethers.utils.formatBytes32String('ServerName')

    let error = null

    await instance.createServer(serverName).catch(e => {
      error = e
    })

    assert.equal(error, null)
  })
})
