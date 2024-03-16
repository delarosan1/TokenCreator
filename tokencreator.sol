// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract ERC20TokenFactory is Ownable, ReentrancyGuard {
   event TokenCreated(address tokenAddress);
  
   address[] public tokens;


   IERC20 public feeToken;
   uint256 public feeTokenAmount;
   address public burningAddress;


   constructor(IERC20 _feeToken, uint256 _feeTokenAmount, address _burningAddress) {
       feeToken = _feeToken;
       feeTokenAmount = _feeTokenAmount;
       burningAddress = _burningAddress;
   }


   function setFeeToken(IERC20 _feeToken) external onlyOwner {
       feeToken = _feeToken;
   }


   function setFeeTokenAmount(uint256 _feeTokenAmount) external onlyOwner {
       feeTokenAmount = _feeTokenAmount;
   }


   function setBurningAddress(address _burningAddress) external onlyOwner {
       burningAddress = _burningAddress;
   }


   function createToken(string memory name, string memory symbol, uint256 initialSupply) public nonReentrant {
       require(feeToken.allowance(msg.sender, address(this)) >= feeTokenAmount, "Fee not paid");
       feeToken.transferFrom(msg.sender, burningAddress, feeTokenAmount);
      
       ERC20NewToken newToken = new ERC20NewToken(name, symbol, initialSupply, msg.sender);
       tokens.push(address(newToken));
       emit TokenCreated(address(newToken));
   }


   function burnTokens(address tokenContract, uint256 amount) external {
       ERC20Burnable(tokenContract).burn(amount);
   }
  
   function getCreatedTokens() public view returns (address[] memory) {
       return tokens;
   }
}


contract ERC20NewToken is ERC20, ERC20Burnable {
   constructor(
       string memory name,
       string memory symbol,
       uint256 initialSupply,
       address initialHolder
   ) ERC20(name, symbol) {
       _mint(initialHolder, initialSupply);
   }
}

