pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;


contract wallet {
    /*
     Exception codes:
      100 - message sender is not a wallet owner.
      101 - invalid transfer value.
     */

  
    constructor() public {
        // check that contract's public key is set
        require(tvm.pubkey() != 0, 101);
        // Check that message has signature (msg.pubkey() is not zero) and message is signed with the owner's private key
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }


    // Modifier that allows function to accept external call only if it was signed
    // with contract owner's public key.
    modifier checkOwnerAndAccept {
        // Check that inbound message was signed with owner's public key.
        // Runtime function that obtains sender's public key.
        require(msg.pubkey() == tvm.pubkey(), 100);

		// Runtime function that allows contract to process inbound messages spending
		// its own resources (it's necessary if contract should process all inbound messages,
		// not only those that carry value with them).
		tvm.accept();
		_;
	}


    // Sends transaction, fee is subtracted from the value
    function sendTransactionExclCommision(address dest, uint128 value) public checkOwnerAndAccept {
        bool bounce = true; //if the transaction falls funds will be returned.
        uint16 flag = 0;
        dest.transfer(value, bounce, flag);
    }

    // Sends transaction, pays transfer fees separately from contract's balance
    function sendTransactionInclCommision(address dest, uint128 value) public checkOwnerAndAccept {
        bool bounce = true;
        uint16 flag = 1;
        dest.transfer(value, bounce, flag);
    }
    
    // Sends all funds and destroys the contract
    function sendAll(address dest) public checkOwnerAndAccept {
        bool bounce = true;
        uint16 flag = 128;
        dest.transfer(1, bounce, flag);
    }
}
