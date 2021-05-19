pragma solidity >=0.5.0 <0.8.5;

import "./ownable.sol";
import "./ERC721.sol";

/**
 * @title CryptoInkBlots
 * @author Gordy Palmer
 * @dev NFT battle simulator. Mint NFTs(blots) with power level generated based on msg.value sent 
 * as well as block number. The earlier block number, the higher power multiplier when minted.
 * After battle, the NFT that wins gets a win added. Vice versa for loser NFT.
 * TODO add wager system. Msg.value sent with battle NFT is wager, winner takes all - transaction fee.
 * TODO ability to mint art as an NFT blot.
 */

contract CryptoInkBlots is Ownable, ERC721 {
    
    event NewBlot(uint id, string name, uint power, uint wins, uint losses);
    event PoweredUpBlot(uint id);
    
    struct Blot {
        string name;
        uint power;
        uint wins;
        uint losses;
    }
    
    Blot[] public blots;
    
    mapping (uint => address) public blotToOwner;
    mapping (address => uint) ownerBlotCount;
    
    function _createBlot(string memory _name, uint _power, uint _wins, uint _losses) private {
        uint id = blots.push(Blot(_name, _power, 0, 0)) - 1;
        blotToOwner[id] = msg.sender;
        ownerBlotCount[msg.sender]++;
        emit NewBlot(id, _name, _power, _wins, _losses);
    }
    ///@dev Function to generate power multiplier based on msg.value and block number.
    function _generateStats() private view returns (uint) {
        uint _powerLevel = 100;
        _powerLevel = _powerLevel * (msg.value - block.timestamp);
        _powerLevel = _powerLevel / (3693 ** 4);
        return (_powerLevel);  
    }
    ///@dev Function to create a blot with name picked by msg.sender, power based on ETH value sent and name block number. Higher value sent, higher power level.
    function makeBlot(string memory _name) public payable {
        require (msg.value >= 1000000000000000 wei, 'Minimum amount not reached, send minimum 0.001 ETH to create a blot');
        uint _power = _generateStats();
        _createBlot(_name, _power, 0, 0);
        emit _safeMint(msg.sender, _tokenId, _name);
    }
}