const Registry = artifacts.require('Vault74Registry')
const Friends = artifacts.require('Friends')
const StickerFactory = artifacts.require('StickerFactory')

module.exports = async function (deployer) {
  await deployer.deploy(Registry)
  await deployer.deploy(Friends)
  await deployer.deploy(StickerFactory)
}
