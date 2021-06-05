pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
contract allowanceContract is Ownable{
    using SafeMath for uint;
     mapping(address=>uint) allowance;
     event allowanceChanged(address indexed forWho, address indexed fromWhom, uint oldAmount, uint newAmount);
    
    address public contractOnwer;
    
    constructor(){
        contractOnwer = msg.sender;
    }
    
    function setAllowance(address _to, uint amount) public{
        emit allowanceChanged(_to, msg.sender, allowance[_to], amount);
        allowance[_to] = amount;
    }
  
    function renounceOwnership() public override {
        revert("You cannot renounceOwnership");
    }
    
    modifier ownerOrAllower(uint _amount){
        require(contractOnwer == msg.sender || allowance[msg.sender] >= _amount,"Not Allowed");
        _;
    }
    
     function reduceAllowance(address to, uint amount) internal{
            emit allowanceChanged(to, msg.sender, allowance[to],allowance[to].sub(amount));

        allowance[to] = allowance[to].sub(amount);    
        
    }
    
    
}
contract sharedWallet is allowanceContract{
    
   event moneySent(address beneficiary, uint amount);
   event moneyReceived(address from, uint amount);
    fallback () external payable{
        emit moneySent(msg.sender, msg.value);
    }
    
    
   
    function withdrawMoney(address payable _to, uint amount) public ownerOrAllower(amount){
        require(amount <= address(this).balance, "There are not enough funds stored on the smart wallet");
        if(contractOnwer != msg.sender){
            reduceAllowance(msg.sender,amount);
        }
        emit moneyReceived(_to, amount);
        _to.transfer(amount);
    }
   
}
