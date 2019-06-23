pragma solidity ^0.5.0;

contract UsingEcrecover{
    
    function recover(bytes32 hash, bytes memory signature)
        public
        pure
        returns (address)
      {
        bytes32 r;
        bytes32 s;
        uint8 v;
    
        if (signature.length != 65) {
          return (address(0));
        }
    
        assembly {
          r := mload(add(signature, 0x20))
          s := mload(add(signature, 0x40))
          v := byte(0, mload(add(signature, 0x60)))
        }
    
        if (v < 27) {
          v += 27;
        }
    
        if (v != 27 && v != 28) {
          return (address(0));
        } else {
          return ecrecover(hash, v, r, s);
        }
    }
    
    function hash(string memory message) public pure returns(bytes32){
    
        string memory header = "\x19Ethereum Signed Message:\n000000";
    
        uint256 lengthOffset;
        uint256 length;
        assembly {
          // The first word of a string is its length
          length := mload(message)
    
          // The beginning of the base-10 message length in the prefix
          lengthOffset := add(header, 57)
        }
    
        // Maximum length we support
        require(length <= 999999);
    
        // The length of the message's length in base-10
        uint256 lengthLength = 0;
    
        // The divisor to get the next left-most message length digit
        uint256 divisor = 100000;
    
        // Move one digit of the message length to the right at a time
        while (divisor != 0) {
    
          // The place value at the divisor
          uint256 digit = length / divisor;
    
          if (digit == 0) {
            // Skip leading zeros
            if (lengthLength == 0) {
              divisor /= 10;
              continue;
            }
          }
    
          // Found a non-zero digit or non-leading zero digit
          lengthLength++;
    
          // Remove this digit from the message length's current value
          length -= digit * divisor;
    
          // Shift our base-10 divisor over
          divisor /= 10;
          
          // Convert the digit to its ASCII representation (man ascii)
          digit += 0x30;
    
          // Move to the next character and write the digit
          lengthOffset++;
          assembly {
            mstore8(lengthOffset, digit)
          }
        }
    
        // The null string requires exactly 1 zero (unskip 1 leading 0)
        if (lengthLength == 0) {
          lengthLength = 1 + 0x19 + 1;
    
        } else {
          lengthLength += 1 + 0x19;
        }
    
        // Truncate the tailing zeros from the header
        assembly {
          mstore(header, lengthLength)
        }
    
        // Perform the elliptic curve recover operation
        bytes32 check = keccak256(abi.encodePacked(header, message));
        return check;
    }
}