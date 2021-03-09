const Registry = artifacts.require('Vault74Registry');
const Friends = artifacts.require('Friends');

module.exports = async function (deployer) {
  await deployer.deploy(Registry);
  await deployer.deploy(Friends);
};
