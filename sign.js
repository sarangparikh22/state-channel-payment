const Web3 = require('web3');

const web3 = new Web3(Web3.givenProvider || 'ws://localhost:8545', null, {});


//Hash Generation of Payment Object -> Just for Testing
console.log(web3.eth.accounts.hashMessage("8264"));

//Signature Generation from Payment Object and Private Key
console.log(web3.eth.accounts.sign("8264", "0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d").signature);
console.log(web3.eth.accounts.sign("8264", "0x6cbed15c793ce57650b9877cf6fa156fbef513c4e6134f022a85b1ffdd59b2a1").signature);
