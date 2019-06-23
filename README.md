# Simple Payment State Channel on Ethereum

This is a Simple State Channel (Payment) on Ethereum in under 100 lines of code :)

## Installation

Clone the Repository and install Node Modules

```bash
npm install
```

## Setting Up Ganache


```python
ganache-cli -d
```

## Remix Setup
1) Import all the Solidity (.sol) files on the Remix Online Editor.

2) Change the Environment to Ganache local url.

3) Deploy the Ecrecover.sol and StringOps.sol and change their respective addresses in the SimplePaymentChannel.sol

## Signature Generation
1) Make the changes in the Payment Object

```python
node sign.js
```
2) Copy the Signatures and Paste it on Remix Online Editor.
 

## License
[MIT](https://choosealicense.com/licenses/mit/)