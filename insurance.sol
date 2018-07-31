pragma solidity ^0.4.14;

contract insuranceFactory {

    address owner; //In this case It would be person who deployed smart contract(developer).
    address[] newContracts;
		address[] customers;

		uint constant flightDelayInsurance = 1;
		uint constant fireInsurance = 2;
		uint constant lifeInsurance = 3;
		uint numberOfFDI; //number of flightDelayInsurance;
		uint numberOfFI; //number of fireInsurance;
		uint numberOfLI; // number of lifeInsurance;


		event LOG_NewContractAddress(address newContractAddress,address customer,uint typeOfInsurance);

		constructor(){
				owner = msg.sender;
		}


		mapping(uint => address) getContractAddressByIndex;


    function newInsurance(uint typeOfInsurance) external {

        uint number= newcontracts.length;

				customers.push(msg.sender);

				address newInsurance = new singleFactory();
				newContracts.push(newInsurance);
				getContractAddressByIndex[number]=newInurance;

				if(typeOfInsurance ==1){
					numberOfFDI++;
					}
				else if(typeOfInsurance ==2){
					numberOfFI++;
				}
				else{
					 numberOfLI++;
				}


				LOG_NewContractAddress(newContract, msg.sender,typeOfInsurance);




    }


}

contract singleFactory{




	struct insuranceInfo{
			uint typeOfInsurance; //For example , 1 means flightDelayInsurance;
			uint customerAddress;
			uint deposit;
	}





}
