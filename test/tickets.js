const { assert } = require("console");

const CurrencyToken = artifacts.require("CurrencyToken");
const FestivalTicket = artifacts.require("FestivalTicket");
contract("CurrencyToken Testing", async () => {
  let festivalContractAddress, festivalContract, token, tokencontractAddress;

  let address = [
    "0x4f546b02799F7d09F8d6EbBbE3853f6D0C2D2cF5",
    "0x954e2faBD5520ec4Fd3DD847F5b34434D2e525dC",
  ];
  beforeEach(async () => {
    token = await CurrencyToken.deployed(address[0]);
    tokencontractAddress = token.address;
    await token.transfer(address[1], BigInt(100 * 10 ** 18), {
      from: address[0],
    });
    festivalContract = await FestivalTicket.deployed(token.address, 10 ** 18);
    festivalContractAddress = festivalContract.address;
  });

  it("should contract deploy properly", async () => {
    assert(festivalContractAddress !== "");
  });

  it("Buy tickets From organizer", async () => {
    await token.approve(festivalContractAddress, BigInt(10 ** 18), {
      from: address[0],
    });
    let buyTokenFromOwner = await festivalContract.buyTicketFromOrganizer({
      from: address[0],
    });
    assert(buyTokenFromOwner.logs[0].event, "Transfer");
  });

  it("Change the price and again sell the ticket", async () => {
    let sellticket = await festivalContract.sellTicket(1, BigInt(10 ** 18), {
      from: address[0],
    });
    assert(sellticket.logs[0].event, "SellTicket");
  });

  it("Buy tickets From other owner", async () => {
    await token.approve(festivalContractAddress, BigInt(10 ** 18), {
      from: address[1],
    });
    let buyticket = await festivalContract.buyTicket(1, {
      from: address[1],
    });
    assert(buyticket.logs[0].event, "Transfer");
  });
});
