//"SPDX-License-Identifier: UNLICENSED"
pragma solidity 0.8.2; 



interface TokenI {
    
    function transfer(address to, uint256 amount) external returns(bool);
    function transferFrom(address from, address to, uint256 amount) external returns(bool);
    function balanceOf(address to) external returns(uint256);
}

contract Stake { 
    address public owner;  

    //_stakigntime=month; _stakedtime=on which block u staked;
    struct _staking{
        uint _stakingtime;
        uint _stakedtime;
        uint _amount;
        uint _profit;
    }

    mapping(address=>_staking) public staking;    
    mapping(uint => uint) public RewardPercentage;
    address public RewardPoolAddress;
    address public tokenAddress=address(0);
    address public contractadd = address(this);
    
    
    
    constructor(address _tokenContract) {

       owner=msg.sender;       
       
       tokenAddress= _tokenContract; 
       //deployTimestamp = block.timestamp ;
        RewardPercentage[30] = 700;
        RewardPercentage[90] = 7500;
        RewardPercentage[180] = 3500;
        RewardPercentage[360] = 160000;

       
    }  

    modifier onlyOwner() {
    // owner is storage variable is set during constructor
    if (msg.sender != owner) {      
       _;
    }
   
  }

    event withdrawprofit(address _to, uint _amount);
    event unstake(address _to, uint _amount);

    function changeRewardPoolAddress( address _rewardaddress) public {
        RewardPoolAddress = _rewardaddress;
    }   

    function RewardPercentageChange( uint _month , uint _percentage) public returns(uint) {
        RewardPercentage[_month] = _percentage;
        return  RewardPercentage[_month];
    }

    function viewPercentage(uint _month) public view returns(uint){
        return RewardPercentage[_month];
    }

    function setRewardToken(uint _amount) public {
        TokenI(tokenAddress).transferFrom(RewardPoolAddress,contractadd, _amount);
       
    }   

    // function calculateprofit() internal returns(uint){
    //     require(staking[msg.sender]._amount > 0,"Wallet Address is not Exist");
    //     uint month=staking[msg.sender]._stakingtime;
    //     uint profit = staking[msg.sender]._amount *  RewardPercentage[month]/100;
    //     //staking[msg.sender]._profit = profit;
    //     return profit;
    // }

    function viewProfit() public view returns(uint){
        require(staking[msg.sender]._amount > 0,"Wallet Address is not Exist");
        uint profit = staking[msg.sender]._amount *  RewardPercentage[staking[msg.sender]._stakingtime]/10000;
        return profit;
    }

    function stake(uint _staketime , uint _stakeamount) public returns (bool){
        require(staking[msg.sender]._amount == 0,"Wallet Address is already Exist");
        require(TokenI(tokenAddress).balanceOf(msg.sender) > _stakeamount, "Insufficient tokens");
        uint profit = _stakeamount * RewardPercentage[_staketime]/10000;
        staking[msg.sender] =  _staking(_staketime,block.timestamp,_stakeamount,profit);

        TokenI(tokenAddress).transfer(address(this), _stakeamount);
        return true;
    }

    function withdrawProfit() public returns (bool){            
            
             //uint locktime=staking[msg.sender]._stakedtime+(30 * staking[msg.sender]._stakingtime *(24*60*60));
             uint locktime=staking[msg.sender]._stakedtime+600;             
            require(staking[msg.sender]._amount > 0,"Wallet Address is not Exist");
            require(block.timestamp > locktime,"Tokens are Locked");
            uint profit= staking[msg.sender]._profit;
            
            staking[msg.sender]._profit=0;
                 

            TokenI(tokenAddress).transfer(msg.sender, profit);

            
             emit withdrawprofit(msg.sender,profit);
            return true;

             
           
    }

 function unStake() public returns (bool){            
             //uint locktime=deployTimestamp + (30 * stakeTime[msg.sender] *(24*60*60));
            // uint locktime=staking[msg.sender]._stakedtime+(30 * staking[msg.sender]._stakingtime *(24*60*60));
             uint locktime=staking[msg.sender]._stakedtime+600;
            
             
            require(staking[msg.sender]._amount > 0,"Wallet Address is not Exist");
            uint totalAmt;
            uint profit;
            uint remainingProfit;

            if(block.timestamp > locktime){
            
                profit= staking[msg.sender]._profit;
                totalAmt= staking[msg.sender]._amount+ profit;

            }else{

                profit= staking[msg.sender]._profit;
                remainingProfit=profit/2; //penalty
                totalAmt= staking[msg.sender]._amount+ remainingProfit;

            }
            staking[msg.sender]._amount=0;
            staking[msg.sender]._stakedtime=0;
            staking[msg.sender]._stakingtime=0;
            staking[msg.sender]._profit=0;
                 

            TokenI(tokenAddress).transfer(msg.sender, totalAmt);

            
             emit unstake(msg.sender,totalAmt);
            return true;

             
           
    }
   

    //function rescueTokens(){}
}

