var Ico = artifacts.require("./Ico.sol");
var MemberLib = artifacts.require("./MemberLib.sol");
var Ownable = artifacts.require("./Ownable.sol");
var SafeMath = artifacts.require("./SafeMath.sol");

module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, MemberLib);
  deployer.deploy(MemberLib);
  deployer.deploy(Ownable);
  deployer.link(MemberLib, Ico);
  deployer.link(Ownable, Ico);
  deployer.deploy(Ico);
};