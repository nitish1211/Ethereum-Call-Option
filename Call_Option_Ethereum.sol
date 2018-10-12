pragma solidity ^0.4.19;
import "./Oraclize.sol";

contract SimpleOraclizeContract is usingOraclize {

    string public ETHUSD; // Relative price of Ethereum in USD 
    string public strikePrice = 100; // The exercise price on the call option
    event LogConstructorInitiated(string nextStep);
    event LogPriceUpdated(string price);
    event LogNewOraclizeQuery(string description);
    event LogExcerciseContract(string status)

    function SimpleOraclizeContract() payable {
        LogConstructorInitiated("Constructor was initiated. Call 'updatePrice()' to send the Oraclize Query.");
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) revert();
        ETHUSD = result;
        LogPriceUpdated(result);
    }

    function updatePrice() payable {
        if (oraclize_getPrice("URL") > this.balance) {
            LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclize_query("URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHXUSD.c.0");
        }
    }

    function contract() {
	if (stringToUint(ETHUSD) > strikePrice) // if the market price is greater than the strike price, the call option would be exercised.
	{
	    LogExcerciseContract("Call option is exercised");
	}
	else
	{
	    LogExcerciseContract("Call option is not exercised");
	}
    }
}


    function stringToUint(string s) constant returns (uint result) {
	bytes memory b = bytes(s);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint c = uint(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    } 