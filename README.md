# JaveLLin Service Portal

This repository containts an Ethereum DApp that demonstrates a Supply Chain flow between a Seller and Buyer. The user story is similar to any commonly used supply chain process. A Seller can add items to the inventory system stored in the blockchain. A Buyer can purchase such items from the inventory system. Additionally a Seller can mark an item as Shipped, and similarly a Buyer can mark an item as Received.
In addition, the buyer can also request service on an item, and move the item through the entire service progression.

The App has a lot of potential, including enhancing the web experience with updated values for SKU based on the manufactured item.  It is also posed to handle dealing with multiple sellers and consumers, to track the item through distribution, all the way to end user.

## Built With

* [Ethereum](https://www.ethereum.org/) - Ethereum is a decentralized platform that runs smart contracts
* [Infura](https://infura.io/) - a tool to connect Ethereum to the web.
* [Metamask] - browser tool to link Ethereum accounts directly to the web for easy contract interactions.
* [Truffle Framework](http://truffleframework.com/) - Truffle is the most popular development framework for Ethereum with a mission to make your life a whole lot easier.

	Truffle Version:  4.1.14
   "openzeppelin-solidity": "^2.1.2",
    "truffle-hdwallet-provider": "^1.0.3",
    "web3": "^1.0.0-beta.37"


## How to use the project?
From the project folder
Execute:  npm run dev
this will execute the project to run on your local machine.
From there, go you browser:
http://localhost:8080/

Be sure your Metamask is enabled on your browswer and connected to the Rinkeby test network.
Pick your user on Metamask.
Be sure to set the correct addresses for Current Owner, manufacturer ID, SellerID, ConsumerID and Service Provider ID.

Manufacture a Unit with a given UPC Code.
Mark the item for ForSale

Switch to your ConsumerID account in Metamask
Buy the item.

Switch to your SellerID/ManufurerID acount in Metamask
Ship the item

Switch to your ConsumerID account in Metamask
Receive the item

Now request Service Call.  Be sure to enter a value in the Product Usage Count and update your Problem notes.
Now ShipSrv to send your product to the service provider.

Switch to your srvID account in Metamask
ReceiveSrv to show that the product has been received.

Repair to show that the service provider has begun work on the unit.
Repaired - show that the unit was sucessfully repaired.
ShipItem - to return the unit to the consumer.

Switch to your ConsumerID account in Metamask
Receive the item

You can repeat the above steps, but instead of pressing Repaired, you can press EOL to show that the unit can no longer be repaired and will be scrapped.


## Acknowledgments

* Solidity
* Ganache-cli
* Truffle
* IPFS
