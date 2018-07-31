pragma solidity ^0.4.22;


contract Bank {

 address public owner;

  constructor(address _owner) public {
		 owner = _owner;
  }

	function deposit() public payable {
		require(msg.value > 0);
	}


function withdraw() public {
	require(msg.sender == owner);
	owner.transfer(address(this).balance);
	//address(this) means contract Banck itself
}
}
