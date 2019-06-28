pragma solidity ^0.5.0;
import "./UsingEcrecover.sol";
import "./StringOps.sol";

contract SimpleStateChannel{
    UsingEcrecover e;
    StringOps strOps;
    
    address payable public p1;
    address payable public p2;
    address public closer;
    
    uint public channelID;
    uint public nonce;
    uint public p1f;
    uint public p2f;
    uint public expDate;
    
    mapping(address => uint) public balance;
    
    enum ChannelSate{
        OpenToContribution,
        Opened,
        Close,
        StateChannelCompleted
    }
    ChannelSate public channelState;
    modifier canFund(){
        require(balance[msg.sender] == 0);
        _;
    }
    modifier allowClose(){
        require(balance[p1] > 0 && balance[p2] > 0);
        _;
    }
    modifier onlyParticipants(){
        require(msg.sender == p1 || msg.sender == p2);
        _;
    }
    constructor(uint _channelID, address payable _p1, address payable _p2) public {
        e = UsingEcrecover(0x17e91224c30c5b0B13ba2ef1E84FE880Cb902352);
        strOps = StringOps(0x47AFf4EbA9820a24E5A383B1bE3f226bEFAe148A);
        channelID = _channelID;
        channelState = ChannelSate.OpenToContribution;
        p1 = _p1;
        p2 = _p2;
    }
    
    // open channel function to start state channel
    function open() payable public canFund onlyParticipants{
        // Opening state channel is allowed only once, 
        // after opening and adding some ether, balance of msg.sender will not be "0" through "canFund"
        require(msg.value > 0);
        balance[msg.sender] = msg.value;
        
        // channel will be changed to open state only when both parties add there funds to the contract
        if(balance[p1] > 0 && balance[p2] > 0){
            channelState = ChannelSate.Opened;
        }
    }
    
    // function to verify that 
    // 1. Message has been signed by both parties
    // 2. Signing address extracted from signature and user address is same for both parties
    function verify(uint _channelID, uint _nonce, uint _p1f, uint _p2f, bytes memory sig1, bytes memory sig2) public view returns(bool){
        require(_channelID == channelID && (_p1f + _p2f) * 1 ether == address(this).balance);
        string memory nonceString = strOps.uintToString(_nonce);
        string memory p1fString = strOps.uintToString(_p1f);
        string memory p2fString = strOps.uintToString(_p2f);
        string memory channelIDString = strOps.uintToString(_channelID);
        string memory txData = strOps.strConcat(channelIDString, nonceString, p1fString, p2fString);
        bytes32 hash = e.hash(txData);
        if((e.recover(hash, sig1) == p1) && (e.recover(hash, sig2) == p2)){
            return true;
        }else{
            return false;
        }
    }
    
    // Function to close the state channel and start timer to allow for challenge period
    function close(uint _channelID, uint _nonce, uint _p1f, uint _p2f, bytes memory sig1, bytes memory sig2) public allowClose onlyParticipants{
        require(channelState == ChannelSate.Opened);
        require(verify(_channelID, _nonce, _p1f, _p2f, sig1, sig2) == true);
        closer = msg.sender;
        channelState = ChannelSate.Close;
        nonce = _nonce;
        p1f = _p1f;
        p2f = _p2f;
        expDate = now + 1 minutes;
    }
    
    // Function for challenge period to allow other party to challenge in case of any dispute
    function challenge(uint _channelID, uint _nonce, uint _p1f, uint _p2f, bytes memory sig1, bytes memory sig2) public{
        require(channelState == ChannelSate.Close);
        require(nonce < _nonce && msg.sender != closer && 
        verify(_channelID, _nonce, _p1f, _p2f, sig1, sig2) == true &&
        now < expDate);
        nonce = _nonce;
        p1f = _p1f;
        p2f = _p2f;
        expDate = now;
    }
    
    // Function to claim the final amount after channel closure and transfer the amount to respective accounts from contract
    function claim() public onlyParticipants{
        require(channelState == ChannelSate.Close && now > expDate);
        p1.transfer(p1f * 1 ether);
        p2.transfer(p2f * 1 ether);
        channelState = ChannelSate.StateChannelCompleted;
    }
    
    function contractBalance() public view returns(uint){
        return address(this).balance;
    }
}
