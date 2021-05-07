const { ethers } = require('ethers')
const { readFileSync } = require('fs')

function getWallet (secret, index) {
  return ethers.Wallet.fromMnemonic(secret, `m/44'/60'/0'/0/${index}`)
}

function processPublicKey (wallet) {
  return `0x${wallet.signingKey.publicKey.slice(4)}`
}

function loadSecret () {
  const secret = readFileSync('.secret')
    .toString()
    .trim()

  console.log('Loaded Secret:', secret)
  return secret
}

module.exports = {
  getWallet,
  loadSecret,
  processPublicKey
}
