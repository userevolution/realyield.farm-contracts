pragma solidity ^0.6.6;
import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
import "./Interfaces/VRFrandom.sol";
import '@openzeppelin/contracts/access/Ownable.sol';


contract reocurringRandom is ChainlinkClient, Ownable {
    enum RSTATE { OPEN, CLOSED, CALCULATING_WINNER }
    RSTATE public state;
    uint256 public lotteryId;
    address public RVF;
    uint256 public interval;
    
   
    
    // 0.1 LINK
    uint256 public ORACLE_PAYMENT = 100000000000000000;
    // Alarm stuff
    address CHAINLINK_ALARM_ORACLE = 0xc99B3D447826532722E41bc36e644ba3479E4365;
    bytes32 CHAINLINK_ALARM_JOB_ID = "2ebb1c1a4b1e4229adac24ee0b5f784f";
    
    constructor(address _rvf, uint _interval) public
    {
        setPublicChainlinkToken();
        lotteryId = 1;
        state = RSTATE.CLOSED;
        RVF=_rvf;
        start_new_lottery(_interval);
    }

  
    
  function start_new_lottery(uint256 duration) internal {
    require(state == RSTATE.CLOSED, "can't start a new lottery yet");
    state = RSTATE.OPEN;
    Chainlink.Request memory req = buildChainlinkRequest(CHAINLINK_ALARM_JOB_ID, address(this), this.fulfill_alarm.selector);
    req.addUint("until", now + duration);
    sendChainlinkRequestTo(CHAINLINK_ALARM_ORACLE, req, ORACLE_PAYMENT);
  }
  
  function fulfill_alarm(bytes32 _requestId)
    public
    recordChainlinkFulfillment(_requestId)
      {
        require(state == RSTATE.OPEN, "The lottery hasn't even started!");
        // add a require here so that only the oracle contract can
        // call the fulfill alarm method
        state = RSTATE.CALCULATING_WINNER;
        lotteryId = lotteryId + 1;
        VRFrandom(RVF).getRandom(lotteryId);
        start_new_lottery(interval);
    }
function cancelRequests() public  onlyOwner(){
     state = RSTATE.CLOSED;
    

}

  

    
}
