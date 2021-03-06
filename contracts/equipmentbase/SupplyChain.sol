pragma solidity ^0.4.24;

//import "../equipmentaccesscontrol/MfgRole.sol";

// Define a contract 'Supplychain'
contract SupplyChain {

//  Manufacturer will always have a seller role.
//  Consumer will always have a seller role.
//  all shipping will occur between a seller and a consumer.  MFG will not ship.  Seller will not receive.
//  All service activities will occur between consumer and service provide.  MFG can also be a service provider.

  // Define 'owner'
  address owner;

  // Define a variable called 'upc' for Universal Product Code (UPC)
  uint  upc;

  // Define a variable called 'sku' for Stock Keeping Unit (SKU)
  uint  sku;
  
  // Define a public mapping 'items' that maps the UPC to an Item.
  mapping (uint => Item) items;

  // Define a public mapping 'itemsHistory' that maps the UPC to an array of TxHash, 
  // that track its journey through the supply chain -- to be sent from DApp.
  mapping (uint => string[]) itemsHistory;
  
  // Define enum 'State' with the following values:
  enum State 
  { 
    Manufactured,       // 0
    ForSale,            // 1
    Sold,               // 2
    ShippedToConsumer,  // 3
    InOperation,		// 4
    HasOpenCall,        // 5
    ShippedToSrv,  		// 6
    ReceivedBySrv,      // 7
    UnderRepair,        // 8
    Repaired,           // 9
    EOL                 // 10
  }

  State constant defaultState = State.Manufactured;

  // Define a struct 'Item' with the following fields:
  struct Item {
    uint    sku;  // Stock Keeping Unit (SKU)
    uint    upc; // Universal Product Code (UPC), generated by the Farmer, goes on the package, can be verified by the Consumer
    address ownerID;  // Metamask-Ethereum address of the current owner as the product moves through the stages
    address originMfgID; // Metamask-Ethereum address of the Mfg
    string  originMfgName; // Mfg Name
    string  originMfgInformation;  // Mfg Information
    string  originMfgLatitude; // Mfg Latitude
    string  originMfgLongitude;  // Mfg Longitude
    uint    productID;  // Product ID potentially a combination of upc + sku
    string  productNotes; // Product Notes
    uint    productPrice; // Product Price
    State   itemState;  // Product State as represented in the enum above
    address sellerID; // Metamask-Ethereum address of the Seller
    address consumerID; // Metamask-Ethereum address of the Consumer
    address srvID;  // Metamask-Ethereum address of the Service Provider
    uint srvUsage;  // usage in hours for the items
    string probNotes; // Notes on problem experienced
    string srvNotes; // Notes on service provided
    address shipToID;	// Metamast-Ethereum address of the ship-to party
  }

  // Define events with the same state values and accept 'upc' as input argument
  event Manufactured(uint upc);
  event ForSale(uint upc);
  event Sold(uint upc);
  event ShippedToConsumer(uint upc);
  event InOperation(uint upc);
  event CallOpened(uint upc);
  event ShippedToSrv(uint upc);
  event ReceivedBySrv(uint upc);
  event UnderRepair(uint upc);
  event Repaired(uint upc);
  event EOL(uint upc);

  // Define a modifer that checks to see if msg.sender == owner of the contract
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  // Define a modifer that verifies the Caller
  modifier verifyCaller (address _address) {
    require(msg.sender == _address);
    _;
  }

  // Define a modifier that checks if the paid amount is sufficient to cover the price
  modifier paidEnough(uint _price) { 
	require(msg.value >= _price); 
    _;
  }
  
  // Define a modifier that checks the price and refunds the remaining balance
  modifier checkValue(uint _upc) {
    _;
    uint _price = items[_upc].productPrice;
    uint amountToReturn = msg.value - _price;
	items[_upc].consumerID.transfer(amountToReturn);
  }

  // Define a modifier that checks if an item.state of a upc is manufactured
  modifier manufactured(uint _upc) {
    require(items[_upc].itemState == State.Manufactured);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is ShippedToConsumer
  modifier shippedToConsumer(uint _upc) {
   	require(items[_upc].itemState == State.ShippedToConsumer);
    _;
  }
  
  // Define a modifier that checks if if the shipTo Address = recBy Address
  modifier recEQship(uint _upc) {
   	require(items[_upc].shipToID == msg.sender);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is ForSale
  modifier forSale(uint _upc) {
    require(items[_upc].itemState == State.ForSale);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Sold
  modifier sold(uint _upc) {
    require((items[_upc].itemState == State.Sold) || (items[_upc].itemState == State.Repaired));
    _;
  }
  
  // Define a modifier that checks if an item.state of a upc is InOperation
  modifier inOperation(uint _upc) {
    require(items[_upc].itemState == State.InOperation);    
    _;
  }

  // Define a modifier that checks if an item.state of a upc is HasOpenCall
  modifier HasOpenCall(uint _upc) {
    require(items[_upc].itemState == State.HasOpenCall);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is ShippedToSrv
  modifier shippedToSrv(uint _upc) {
   	require(items[_upc].itemState == State.ShippedToSrv);
    _;
  }
  
  // Define a modifier that checks if an item.state of a upc is ReceivedBySrv
  modifier receivedBySrv(uint _upc) {
   	require(items[_upc].itemState == State.ReceivedBySrv);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is UnderRepair
  modifier underRepair(uint _upc) {
    require(items[_upc].itemState == State.UnderRepair);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is UnderRepair
  modifier repaired(uint _upc) {
    require(items[_upc].itemState == State.Repaired);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is EOL
  modifier notEOL(uint _upc) {
    require(items[_upc].itemState != State.EOL);
    _;
  }

  // In the constructor set 'owner' to the address that instantiated the contract
  // and set 'sku' to 1
  // and set 'upc' to 1
  constructor() public payable {
    owner = msg.sender;
    sku = 1;
    upc = 1;
  }

  // Define a function 'kill' if required
  function kill() public {
    if (msg.sender == owner) {
      selfdestruct(owner);
    }
  }


  // Define a function 'manufactureItem' that allows a manufacturer to mark an item 'Created'
  function manufactureItem(uint _upc, address _originMfgID, string _originMfgName, string _originMfgInformation, string  _originMfgLatitude, string  _originMfgLongitude, string _productNotes) public 
  {
    // Add the new item as part of Manufacturing
    owner = _originMfgID;
    items[_upc].sku = sku; 										// product SKU
    items[_upc].upc = upc; 										// product UPC
    items[_upc].ownerID = _originMfgID;							// Metamask-Ethereum address of the current owner as the product moves through the stages
    items[_upc].originMfgID = _originMfgID;                     // Metamask-Ethereum address of the Mfg
    items[_upc].originMfgName = _originMfgName;                 // Mfg Name
    items[_upc].originMfgInformation = _originMfgInformation;   // Mfg Information
    items[_upc].originMfgLatitude = _originMfgLatitude;         // Mfg Latitude
    items[_upc].originMfgLongitude = _originMfgLongitude;       // Mfg Longitude
    items[_upc].productID = _upc + sku;                         // Product ID potentially a combination of upc + sku
    items[_upc].productNotes = _productNotes;					// Notes/description of the product
    items[_upc].itemState = State.Manufactured;                 // Product State as represented in the enum above
    
    // Increment sku
    sku = sku + 1;

    // Emit the appropriate event
    emit Manufactured(_upc);
  }

  // Define a function 'sellItem' that allows a seller (Note that MFG will be the seller) to mark an item 'ForSale'
  function sellItem(uint _upc, uint _price) public 
  // Call modifier to check if upc has passed previous supply chain stage
   manufactured(_upc)
  
  // Call modifier to verify caller of this function
	 verifyCaller(items[_upc].originMfgID)
  {
    // Update the appropriate fields
	  items[_upc].productPrice = _price;                        // Product Price    
    items[_upc].sellerID = msg.sender;                        // Product Price    
    items[_upc].itemState = State.ForSale;                 // Product State as represented in the enum above

    // Emit the appropriate event
   	emit ForSale(_upc);
  }

  // Define a function 'buyItem' that allows the "seller" to mark an item 'Sold'
  // Use the above defined modifiers to check if the item is available for sale, if the buyer has paid enough, 
  // and any excess ether sent is refunded back to the buyer
  function buyItem(uint _upc) public payable 
    // Call modifier to check if upc has passed previous supply chain stage
    forSale(_upc)
    // Call modifer to check if buyer has paid enough
    paidEnough(items[_upc].productPrice)
    // Call modifer to send any excess ether back to buyer
    checkValue(_upc)
    {
    // Update the appropriate fields - consumerID, itemState
    items[_upc].consumerID = msg.sender;				        // Consumer ID
    items[_upc].itemState = State.Sold;					        // Product State as represented in the enum above
    
    // Transfer money to seller
    items[_upc].sellerID.transfer(items[_upc].productPrice);

    // emit the appropriate event
    emit Sold(_upc);
  }

  // Define a function 'shipItem' that allows the current owner to mark an item 'ShippedToConsumer'
  // Use the above modifers to check if the item is sold
  function shipItem(uint _upc, address _shipTo) public 
    // Call modifier to check if upc has passed previous supply chain stage
    sold(_upc)
    // Call modifier to verify caller of this function
    onlyOwner()
  {
    // Update the appropriate fields
    items[_upc].itemState = State.ShippedToConsumer;         // Product State as represented in the enum above
    items[_upc].shipToID = _shipTo;								// Set address for ship-to

    // Emit the appropriate event
     emit ShippedToConsumer(_upc);
  }

  // Define a function 'receiveItem' that allows the receiver to mark an item 'InOperation'
  // Use the above modifiers to check if the item is shipped
  function receiveItem(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stage
    shippedToConsumer(_upc)
    recEQship(_upc)
    // Access Control List enforced by calling Smart Contract / DApp
  {
    // Update the appropriate fields - ownerID, sellerID, itemState
    owner = msg.sender;
    items[_upc].shipToID = 0;    							// Clear the ship-to address
    items[_upc].ownerID = msg.sender;						// Set the UPC Owner
    items[_upc].consumerID = msg.sender;			        // Consumer ID
    items[_upc].itemState = State.InOperation;		        // Product State as represented in the enum above
    
    // Emit the appropriate event
    emit InOperation(_upc);
  }

  // Define a function 'requestSrv' that allows the consumer to mark an item 'HasOpenCall'
  // Use the above modifiers to check if the item is inOperation
  function requestSrv(uint _upc, address _srvID, uint256 _srvUsage, string _probNotes) public 
    // Call modifier to check if upc has passed previous supply chain stage
    onlyOwner()
    inOperation(_upc)
    // Access Control List enforced by calling Smart Contract / DApp
    {
    // Update the appropriate fields - ownerID, consumerID, itemState
    items[_upc].srvID = _srvID;								// Set the service provider
    items[_upc].itemState = State.HasOpenCall;		        // Product State as represented in the enum above
    items[_upc].srvUsage = _srvUsage;						//  Send current usage (in hours)
    items[_upc].probNotes = _probNotes;						//  Enter in problem description
    
    // Emit the appropriate event
    emit CallOpened(_upc);
  }

  // Define a function 'shipItemSrv' that allows the current owner to mark an item 'ShippedToSrv'
  // Use the above modifers to check if the item is sold
  function shipItemSrv(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stage
    HasOpenCall(_upc)
    // Call modifier to verify caller of this function
    onlyOwner()
  {
    // Update the appropriate fields
    items[_upc].itemState = State.ShippedToSrv;			        // Product State as represented in the enum above
    items[_upc].shipToID = items[_upc].srvID;					// Set address for ship-to

    // Emit the appropriate event
        emit ShippedToSrv(_upc);
  }

  // Define a function 'receiveItemSrv' that allows the receiver to mark an item 'ReceivedBySrv'
  // Use the above modifiers to check if the item is shipped
  function receiveItemSrv(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stage
    shippedToSrv(_upc)
    recEQship(_upc)
    // Access Control List enforced by calling Smart Contract / DApp
  {
    // Update the appropriate fields - sellerID, itemState
    owner = msg.sender;
    items[_upc].ownerID = msg.sender;			        // Product State as represented in the enum above
    items[_upc].itemState = State.ReceivedBySrv;        // Product State as represented in the enum above
	items[_upc].shipToID = 0;    						// Clear the ship-to address
    
    // Emit the appropriate event
    emit ReceivedBySrv(_upc);
  }

  // Define a function 'repairItem' that allows the receiver to mark an item 'UnderRepair'
  // Use the above modifiers to check if the item is received
  function repairItem(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stage
    receivedBySrv(_upc)
    // Access Control List enforced by calling Smart Contract / DApp
  {
    // Update the appropriate fields
    items[_upc].itemState = State.UnderRepair;        // Product State as represented in the enum above
    
    // Emit the appropriate event
    emit UnderRepair(_upc);
  }

  // Define a function 'repairComplete' that allows the receiver to mark an item 'Repaired' or 'EOL'
  // Use the above modifiers to check if the item is under repair
  function repairComplete(uint _upc, uint _EOL, string _srvNotes) public 
    // Call modifier to check if upc has passed previous supply chain stage
    underRepair(_upc)
    // Access Control List enforced by calling Smart Contract / DApp
  {
    // Update the appropriate fields
    items[_upc].srvNotes = _srvNotes;					//  enter in all repair data
    if (_EOL == 0)
    	items[_upc].itemState = State.Repaired;        // Product State as represented in the enum above
   	if (_EOL == 1)
    	items[_upc].itemState = State.EOL;		       // Product State as represented in the enum above
    
    // Emit the appropriate event
    if (_EOL == 0)
    	emit Repaired(_upc);
   	if (_EOL == 1)
    	emit EOL(_upc);
  }

  // Define a function 'shipFromSrv' that allows the current owner to mark an item 'ShippedToConsumer'
  // Use the above modifers to check if the item is sold
  function shipFromSrv(uint _upc, address _shipTo) public 
    // Call modifier to check if upc has passed previous supply chain stage
    repaired(_upc)
    // Call modifier to verify caller of this function
	verifyCaller(items[_upc].srvID)
  {
    // Update the appropriate fields
    items[_upc].itemState = State.ShippedToConsumer;         // Product State as represented in the enum above
    items[_upc].shipToID = _shipTo;								// Set address for ship-to

    // Emit the appropriate event
        emit ShippedToConsumer(_upc);
  }

  // Define a function 'fetchItemBufferOne' that fetches the data
  function fetchItemBufferOne(uint _upc) public view returns 
	(
		uint    itemSKU,
		uint    itemUPC,
		address ownerID,
		address originMfgID,
		string  originMfgName,
		string  originMfgInformation,
		string  originMfgLatitude,
		string  originMfgLongitude
	) 
  {
	// Assign values to the parameters
	itemSKU = items[_upc].sku;
	itemUPC = items[_upc].upc;
	ownerID = items[_upc].ownerID;
	originMfgID = items[_upc].originMfgID;
	originMfgName = items[_upc].originMfgName;
	originMfgInformation = items[_upc].originMfgInformation;
	originMfgLatitude = items[_upc].originMfgLatitude;
	originMfgLongitude = items[_upc].originMfgLongitude;

	return 
	(
		itemSKU,
		itemUPC,
		ownerID,
		originMfgID,
		originMfgName,
		originMfgInformation,
		originMfgLatitude,
		originMfgLongitude
	);
  }

  // Define a function 'fetchItemBufferTwo' that fetches the data
  function fetchItemBufferTwo(uint _upc) public view returns 
  (
  uint    itemSKU,
  uint    itemUPC,
  uint    productID,
  string  productNotes,
  uint    productPrice,
  State   itemState,
  address originMfgID,
  address sellerID,
  address consumerID,
  address shipToID
  ) 
  {
    // Assign values to the parameters
  itemSKU = items[_upc].sku;
  itemUPC = items[_upc].upc;
  productID = items[_upc].productID;
  productNotes = items[_upc].productNotes;
  productPrice = items[_upc].productPrice;
  itemState = items[_upc].itemState;
  originMfgID = items[_upc].originMfgID;
  sellerID = items[_upc].sellerID;
  consumerID = items[_upc].consumerID;
  shipToID = items[_upc].shipToID;

  return 
  (
  itemSKU,
  itemUPC,
  productID,
  productNotes,
  productPrice,
  itemState,
  originMfgID,
  sellerID,
  consumerID,
  shipToID
  );
  }

  // Define a function 'fetchItemBufferThree' that fetches the data
  function fetchItemBufferThree(uint _upc) public view returns 
  (
  uint    itemSKU,
  uint    itemUPC,
  uint    productID,
  address srvID,
  uint srvUsage,
  string probNotes,
  string srvNotes
  ) 
  {
    // Assign values to the parameters
  itemSKU = items[_upc].sku;
  itemUPC = items[_upc].upc;
  productID = items[_upc].productID;
  srvID = items[_upc].srvID;
  srvUsage = items[_upc].srvUsage;
  probNotes = items[_upc].probNotes;
  srvNotes = items[_upc].srvNotes;
    
  return 
  (
  itemSKU,
  itemUPC,
  productID,
  srvID,
  srvUsage,
  probNotes,
  srvNotes
  );
  }    
}
