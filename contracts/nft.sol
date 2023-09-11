// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FestivalTicket is ERC721, Ownable {
    using SafeMath for uint256;

    uint256 public constant maxTickets = 1000;
    uint256 public ticketPrice;
    uint256 public organizerFeePercentage;
    address public currencyTokenAddress;
    uint256 public totalSoldTickets;

    event BuyTicketFromOrganizer (address buyerAddress,uint256 ticketId,uint256 price);
    event SellTicket (address sellerAddress,uint256 tickedId,uint256 price);
    event BuyTicket (address from,address buyer,uint256 ticketId,uint256 price);
    

    struct tickets{
        address ticketOwner;
        uint256 ticketPrices;
        bool IsticketForSale;
    }

    mapping(uint256 => tickets) public ticketsInfo;

    constructor(address _currencyTokenAddress, uint256 _ticketPrice) ERC721("FestivalTicket", "TICKET") {
        currencyTokenAddress = _currencyTokenAddress;
        ticketPrice = _ticketPrice;
    }

    function buyTicketFromOrganizer() external {
        require(totalSoldTickets < maxTickets, "No more tickets available");
        require(IERC20(currencyTokenAddress).allowance(msg.sender, address(this))>=ticketPrice, "Insufficient Allowance");
        require(IERC20(currencyTokenAddress).transferFrom(msg.sender,owner(), ticketPrice), "Transfer failed");
        uint256 tokenId = totalSoldTickets + 1;
        _mint(msg.sender, tokenId);
        ticketsInfo[tokenId].ticketOwner = msg.sender;
        ticketsInfo[tokenId].ticketPrices = ticketPrice;
        ticketsInfo[tokenId].IsticketForSale = false;
        totalSoldTickets+=1;
        emit BuyTicketFromOrganizer(msg.sender,tokenId,ticketPrice);
    }

    function sellTicket(uint256 _ticketId, uint256 _newPrice) external {
        require(ownerOf(_ticketId) == msg.sender, "You are not the owner of this ticket");
        require(_newPrice <= ticketsInfo[_ticketId].ticketPrices * 110 / 100, "New price too high");
        ticketsInfo[_ticketId].ticketPrices = _newPrice;
        ticketsInfo[_ticketId].IsticketForSale = true;
        emit SellTicket(msg.sender,_ticketId,_newPrice);
    }

    function buyTicket(uint256 _ticketId) external {
        require(ownerOf(_ticketId) != msg.sender, "You already own this ticket");
        require(ticketsInfo[_ticketId].IsticketForSale,"This ticket is not for sale");
        uint256 sellingPrice = ticketsInfo[_ticketId].ticketPrices;
        uint256 fee = sellingPrice.mul(organizerFeePercentage).div(100);
        require(IERC20(currencyTokenAddress).allowance(msg.sender, address(this))>=sellingPrice, "Insufficient Allowance");
        if(organizerFeePercentage>0){
            require(IERC20(currencyTokenAddress).transferFrom(msg.sender,owner(), fee), "Transfer failed to organizer");
        }
        require(IERC20(currencyTokenAddress).transferFrom(msg.sender,ownerOf(_ticketId),sellingPrice.sub(fee)), "Transfer failed to owner");
        // Implement monetization for the organizer - you can charge a fee here.
        // For example, deduct a percentage of the sellingPrice as a fee.
        
        _transfer(ownerOf(_ticketId),msg.sender, _ticketId);
        emit BuyTicket(ticketsInfo[_ticketId].ticketOwner,msg.sender,_ticketId,sellingPrice);
        ticketsInfo[_ticketId].ticketOwner = msg.sender;
        ticketsInfo[_ticketId].ticketPrices = sellingPrice;
        ticketsInfo[_ticketId].IsticketForSale = false;
    }
}
