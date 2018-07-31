pragma solidity ^0.4.19;



contract PatreonFactory{

 bytes32[] public names;

 address[] public newContracts;

 address[] public originalCreators;

 address public owner;



 event LOG_NewContractAddress (address indexed theNewContract, address indexed theContractCreator);



 constructor(){

     owner = msg.sender; // who publish this contract to the blockchain becomes the owner of this contract

 }



 function createContract(bytes32 name) external{



     //this is the loop to prevent names to be duplicated, to avoid confusion.

     for (uint32 i = 0; i < names.length; i++){

         assert(name !=names[i]);

     }



     uint contractNumber = newContracts.length;

     originalCreators.push(msg.sender);

     //this is the part our contract actually makes new contract

     //Let's make a new version of SinglePatreon, like.. making a instance.

     address newContract = new SinglePatreon(name, contractNumber);



     //so you got the address of your new SinglePatreon contract : new contract

     // now it's time to push it to newContracts dynamic array!



     newContracts.push(newContract);

     names.push(name);



     LOG_NewContractAddress(newContract, msg.sender);







 }



 function getName(uint i ) constant external returns(bytes32 contractName){

     return names[i];

 }



 function getContractAddressAtIndex(uint i) constant external returns(address contractAddress){

     return newContracts[i];

 }



 function getOriginalCreator(uint i) constant external returns(address originalCreator){

     return originalCreators[i];

 }



 function getNameArray() constant external returns(bytes32[] contractName){

     return names;

 }



 function getContractAddressArray() constant external returns (address[] contractAddress){

     return newContracts;

 }



 function getOriginalCreatorArray() constant external returns (address[] originalCreator){

     return originalCreators;

 }



 function getOwner() constant external returns (address _owner){

     return owner;

 }

 function () {} //can't send ether with send unless payable modifier exists



 }













contract SinglePatreon{





//***********************STATE VARIABLES*****************************************



    address public creator;

    address public owner;

    bytes32 public name; // contract name

    uint public singleDonationAmount;

    uint public monthlyDonationAmount;

    uint public contractNumber;

    uint32 public numberOfSingleContributions;



    //monthly Counter Variables;



    uint dynamicFirstOfMonth = 1498867200; //starts on July 1st, 2017.

    uint8 monthlyCounter = 6; //because we are starting on july 2017, and its 6th spot in a 12 spot array

    uint64 leapYearCounter = 1583020800; //did not add an assert for this, as it can't be changed easily



    //maintenance modes which regulate a state of this contract



    uint8 constant maintenanceNone = 0;

    uint8 constant maintenance_BalTooHigh=1;

    uint8 constant maintenance_Emergency = 255;

    uint8 public maintenance_mode;



    //sppedBump Variables



    bool speedBumpBool = true;

    uint speedBumpTime;



    //let's make a donationData struct



    struct donationData {

        address donator;

        uint totalDonationStart;

        uint totalRemaining;

        uint paymentPerMonth;

        uint8 monthsRemaining;

    }



    donationData[] public donators;



    mapping(address => uint) public patreonIds;



    //monthly accounting stuff

    uint[13] public ledger;



    //number of patreons

    uint8 constant allPatreonEver = 0;

    uint8 constant patreonsNow = 1;

    uint8 constant patreonsFinished = 2;

    uint8 constant patreonsCancelled = 3;

    //number of donations

    uint8 constant totalDonationsEver = 4;

    uint8 constant monthlyDonationsAvailable = 5;

    uint8 constant totalDonationsWithdrawn = 6;

    uint8 constant totalDonationsCancelled = 7;

    //number of ethers

    uint8 constant totalEtherEver = 8;

    uint8 constant totalEtherNow = 9;

    uint8 constant totalEtherWithdrawn = 10;

    uint8 constant totalEtherCancelled = 11;

    //monthly donation

    uint8 constant monthlyDonation = 12;





   // ******************** Modifiers, Events, enums *************************



    modifier onlyCreator {

        if(msg.sender!=creator)

        revert();

        _;

    }



    modifier onlyPatreons{

        if (msg.sender==creator)

        revert();

        _;

    }



    modifier onlyOwner{

        if(msg.sender !=owner)

        revert();

        _;

    }



    modifier notInMaintenance{

        healthCheck();

        if(maintenance_mode >= maintenance_Emergency)

        revert();

        _;

    }



      event LOG_SingleDonation (uint donationAmount, address donator);

    event LOG_PatreonContractCreated (address creator, address createdContract);

    event LOG_ChangeToSingleDonatorStruct (uint totalDonationStart, uint totalRemaining, uint monthsRemaining, uint paymentPerMonth, address donator);

    event LOG_ChangeToFullLedger (uint allPatreonsEver, uint patreonsNow, uint patreonsFinished, uint patreonsCancelled, uint totalDonationsEver, uint monthlyDonationsAvailable, uint totalDonationsWithdrawn, uint totalDonationsCancelled, uint totalEtherEver, uint totalEtherNow, uint totalEtherWithdrawn, uint totalEtherCancelled, uint monthlyDonation);

    event LOG_ChangeToContractBalance (uint contractBalance);

    event LOG_HealthCheck(bytes32 message, int diff, uint balance, uint ledgerBalance);



    function healthCheck() internal {

        int diff = int(this.balance-msg.value)-int(ledger[totalEtherNow]);



        if(diff ==0){

            return;

        }

        if (diff > 0){

            LOG_HealthCheck("Balance too high!",diff,this.balance,ledger[totalEtherNow]);

            maintenance_mode=maintenance_BalTooHigh;



        }

        else{

            LOG_HealthCheck("Balance too low",diff, this.balance, ledger[totalEtherNow]);

            maintenance_mode=maintenance_Emergency;

        }

    }



    //manually perform healthcheck





    function performHealthCheck(uint8 _maintenance_mode) external onlyOwner{

        maintenance_mode= _maintenance_mode;

        if(maintenance_mode>0 && maintenance_mode< maintenance_Emergency){



            healthCheck();



        }

    }





   // *****************************CONSTRUCTOR FUNCTIONS AND MAIN FUNCTIONS****



   constructor (bytes32 _name, uint _contractNumber){



   }





   function setOneTimeContribution (uint setAmountInWei) external onlyCreator{

       require (0<setAmountInWei && setAmountInWei<100 ether);

       singleDonationAmount = setAmountInWei;

   }



    function oneTimeContribution() external payable onlyPatreons{

        if(msg.value != singleDonationAmount)

        revert();



        creator.transfer(msg.value);

        numberOfSingleContributions++;

    }





    function setMontlyContribution(uint setMonthlyInWei) external onlyCreator{

        require (0<setMonthlyInWei && setMonthlyInWei <1200 ether);

        require (setMonthlyInWei % 12 ==0 );

        monthlyDonationAmount = setMonthlyInWei;

    }



    function monthlyContribution () external payable onlyPatreons notInMaintenance{

        if( msg.value != monthlyDonationAmount)

        revert();



        if((donators.length>=1)&&(patreonIds[msg.sender] !=0)||donators[0].donator==msg.sender)

        revert();





        uint patreonId = donators.length++;

        patreonIds[msg.sender]=patreonId;

        donationData memory pd = donators[patreonId];



        pd.donator = msg.sender;

        pd.totalDonationStart = msg.value;

        pd.totalRemaining = msg.value;

        pd.monthsRemaining = 12;

        pd.paymentPerMonth = msg.value/pd.monthsRemaining;



        donators[patreonId] = pd;



        assert(pd.totalRemaining==pd.monthsRemaining* pd.paymentPerMonth);



        ledger[monthlyDonation] = pd.paymentPerMonth;

        ledger[allPatreonEver] +=1;

        ledger[patreonsNow]+=1;

        assert(ledger[allPatreonEver]==(ledger[patreonsCancelled]+ledger[patreonsNow]+ledger[patreonsFinished]));



        ledger[totalDonationsEver] += 12;

        ledger[monthlyDonationsAvailable] +=12;

        assert(ledger[totalDonationsEver]==(ledger[monthlyDonationsAvailable]+ledger[totalEtherWithdrawn]+ledger[totalEtherCancelled]));



        LOG_ChangeToFullLedger (ledger[allPatreonEver], ledger[patreonsNow], ledger[patreonsFinished], ledger[patreonsCancelled], ledger[totalDonationsEver], ledger[monthlyDonationsAvailable], ledger[totalDonationsWithdrawn], ledger[totalDonationsCancelled], ledger[totalEtherEver], ledger[totalEtherNow], ledger[totalEtherWithdrawn], ledger[totalEtherCancelled], ledger[monthlyDonation]);

        LOG_ChangeToSingleDonatorStruct (pd.totalDonationStart,  pd.totalRemaining,  pd.monthsRemaining,  pd.paymentPerMonth,  msg.sender);



    }



    function patreonCancleMontly() external onlyPatreons notInMaintenance{

        uint patreonId = patreonIds[msg.sender];



        if(patreonId==0 && (msg.sender != donators[0].donator)){

            revert();



        }



        uint refund = donators[patreonId].totalRemaining;



        if (refund == 0){

            revert();

        }



        uint monthsRemoved = donators[patreonId].monthsRemaining;



        ledger[patreonsCancelled]+= 1;

        ledger[patreonsNow]-=1;

        assert (ledger[allPatreonEver] == ledger[patreonsCancelled]+ledger[patreonsNow]+ledger[patreonsFinished]);



        ledger[monthlyDonationsAvailable]-= monthsRemoved;

        ledger[totalDonationsCancelled]+= monthsRemoved;

        assert(ledger[totalDonationsEver] == ledger[monthlyDonationsAvailable]+ledger[totalDonationsWithdrawn]+ledger[totalDonationsCancelled]);



        ledger[totalEtherNow]-=refund;

        ledger[totalEtherCancelled]+=refund;

        assert(ledger[totalEtherEver] == ledger[totalEtherNow]+ledger[totalEtherWithdrawn]+ledger[totalEtherCancelled]);



        //You need to actually change these value otherwise someone will keep withdrawing the money.



        donators[patreonId].totalRemaining =0;

        donators[patreonId].monthsRemaining =0;



        assert(donators[patreonId].totalRemaining == donators[patreonId].monthsRemaining*donators[patreonId].paymentPerMonth);



        msg.sender.transfer(refund);



        LOG_ChangeToSingleDonatorStruct (donators[patreonId].totalDonationStart,  donators[patreonId].totalRemaining,  donators[patreonId].monthsRemaining,  donators[patreonId].paymentPerMonth,  donators[patreonId].donator);

        LOG_ChangeToFullLedger (ledger[allPatreonEver], ledger[patreonsNow], ledger[patreonsFinished], ledger[patreonsCancelled], ledger[totalDonationsEver], ledger[monthlyDonationsAvailable], ledger[totalDonationsWithdrawn], ledger[totalDonationsCancelled], ledger[totalEtherEver], ledger[totalEtherNow], ledger[totalEtherWithdrawn], ledger[totalEtherCancelled], ledger[monthlyDonation]);

        LOG_ChangeToContractBalance(this.balance);





    }



    function creatorWithdrawMontly() external onlyCreator notInMaintenance {



        //if there is nothing to withdraw , do go through the operations



        if(ledger[monthlyDonationsAvailable]<=0){



            revert();



        }



        if (now > dynamicFirstOfMonth) {



            oneDaySpeedBump();

            uint amountToWithdraw = ledger[patreonsNow]*ledger[monthlyDonation];



            //deal with patreons in ledger

            ledger[monthlyDonationsAvailable] -= ledger[patreonsNow];

            ledger[totalDonationsWithdrawn] += ledger[patreonsNow];

            assert(ledger[totalDonationsEver] == ledger[monthlyDonationsAvailable]+ledger[totalDonationsWithdrawn]+ledger[totalDonationsCancelled]);







            //deal with ether in ledger



            ledger[totalEtherNow]-= amountToWithdraw;

            ledger[totalEtherWithdrawn]+=amountToWithdraw;

            assert(ledger[totalEtherEver] == ledger[totalEtherNow]+ledger[totalEtherWithdrawn]+ledger[totalEtherCancelled]);



            //deal with patreons being fully completed or canceled on ledger



            uint patreonsCompleted = checkIfPatreonsAreDoneDonating();

            ledger[patreonsNow] -= patreonsCompleted;

            ledger[patreonsFinished] +=patreonsCompleted;

            assert(ledger[allPatreonEver] == ledger[patreonsCancelled]+ledger[patreonsFinished]+ledger[patreonsNow]);





            updateMonthlyCounter(); // this actually stops people from withdrawing money more than once a month.





            creator.transfer(amountToWithdraw);

             LOG_ChangeToContractBalance(this.balance);

            LOG_ChangeToFullLedger (ledger[allPatreonEver], ledger[patreonsNow], ledger[patreonsFinished], ledger[patreonsCancelled], ledger[totalDonationsEver], ledger[monthlyDonationsAvailable], ledger[totalDonationsWithdrawn], ledger[totalDonationsCancelled], ledger[totalEtherEver], ledger[totalEtherNow], ledger[totalEtherWithdrawn], ledger[totalEtherCancelled], ledger[monthlyDonation]);



        }

        else{ revert();}

    }



        function checkIfPatreonsAreDoneDonating() internal returns (uint _patreonDone){



            uint patreonsDone;





            for (uint x =0 ; x < donators.length;x++){



                if(donators[x].totalRemaining >0){

                    donators[x].totalRemaining -= donators[x].paymentPerMonth;

                    donators[x].monthsRemaining -=1;

                    assert(donators[x].totalRemaining == donators[x].monthsRemaining*donators[x].paymentPerMonth);



                    if(donators[x].monthsRemaining==0){

                        patreonsDone++;



                    }

                }



            }

            return patreonsDone;



        }







           function updateMonthlyCounter() internal {

        //@@@@@@@@@@@@@@@TESTING

       // uint tempDynamicFirstOfMonthForTesting = 1498867200;

        //make sure months are not trailing off

        assert(monthlyCounter <= 11);

        assert(monthlyCounter >= 0);



        //@@@@@@@@@@@@@@@TESTING

        //making sure no overflow has happened

        assert(dynamicFirstOfMonth + 1 > 1498867200);





        uint64 leapYearCycle = 126230400;//this number is 4 years plus a day, and it reoccuring on a consistent basis



        uint secondsInOneMonth31 = 2678400; // aug, oct dec, jan, mar, may, july

        uint secondsInOneMonth30 = 2592000; //sept, nov, april, june

        uint secondsInOneMonth28 = 2419200; // feb

        uint secondsInOneMonth29 = 2505600; // feb 29 2020, etc.



        //if statement that changes dynamicFirstOfMonth, with math. then increment

        if (monthlyCounter == 7 || monthlyCounter == 9 || monthlyCounter == 11 || monthlyCounter == 0 || monthlyCounter == 2 || monthlyCounter == 4 || monthlyCounter == 6) {

            dynamicFirstOfMonth += secondsInOneMonth31;

            if (monthlyCounter == 11) {

                monthlyCounter = 0;

            } else {

                monthlyCounter++;

            }

        } else if (monthlyCounter == 8 || monthlyCounter == 10 || monthlyCounter == 3 || monthlyCounter == 5) {

            dynamicFirstOfMonth += secondsInOneMonth30;

            monthlyCounter++;

        } else {

            if (now > leapYearCounter) {

                dynamicFirstOfMonth = dynamicFirstOfMonth + secondsInOneMonth29;

                leapYearCounter += leapYearCycle;

                monthlyCounter++;

            } else {

                dynamicFirstOfMonth += secondsInOneMonth28;

                monthlyCounter++;

            }

        }

    }







        function oneDaySpeedBump() internal {

            if(speedBumpBool ==true){

                speedBumpTime = now + 86400;

                speedBumpBool = false;

            } else if( now < speedBumpTime){

                revert();

            } else{

                speedBumpTime = now + 86400;

            }







        }









    function getContractNumber() constant external returns (uint) {

        return contractNumber;

    }

    function getOneTimecontribution() constant external returns(uint singleDonation) {

        return singleDonationAmount;

    }

    function getMonthlyDonationAmount() constant external returns (uint monthlyDonation) {

        return  monthlyDonationAmount;

    }

    //maybe not needed, contract balanace should suffice ?

    function getMonthsLeftForDonation() constant external returns (uint monthsLeft) {

          return ledger[monthlyDonationsAvailable];

    }

    function getContractBalance()  constant external returns(uint contractBalance) {

        return this.balance;

    }

    function getTotalSingleContributors() constant external returns(uint _numberOfSingleContributions) {

        return numberOfSingleContributions;

    }

    function getOwnerSinglePatreon() constant external returns (address _owner) {

        return owner;

    }

    function getPatreonID(address patreonsAddress) constant external returns (uint _id) {

        return patreonIds[patreonsAddress];

    }

    //owner can only send, the fix any error in withdrawals

    function () onlyOwner {}



    }//end contract

























































       
