const FestivalTicket = artifacts.require("FestivalTicket");
const currencyToken = artifacts.require("CurrencyToken");

module.exports = async (deployer) => {
  deployer.deploy(currencyToken,"0x4f546b02799F7d09F8d6EbBbE3853f6D0C2D2cF5").then(() => {
    return deployer.deploy(
      FestivalTicket,
      currencyToken.address,
      BigInt(10 ** 18)
    );
  });
};
