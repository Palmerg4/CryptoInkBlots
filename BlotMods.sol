pragma solidity >=0.5.0 <0.8.5;

import  "./CryptoInkBlots.sol";
import "./ownable.sol";

/**
 * @title BlotMods
 * @author Gordy Palmer
 * @dev NFT battle system. Mint NFTs(blots) with a power level based on msg.value. BlotMods is
 * added functionality to the main contract CryptoInkBlots. Simple view calls and power up ability.
 */

contract BlotMods is Ownable, CryptoInkBlots {
    
    uint powerUpFee = 1000000000000000 wei;
    
     modifier ownerOf(uint _blotId) {
    require(msg.sender == blotToOwner[_blotId], "You are not the owner of this Blot");
    _;
  }
  
  function withdraw() external onlyOwner {
    address payable _owner = address(uint160(owner()));
    _owner.transfer(address(this).balance);
  }
  
  function setPowerUpFee(uint _fee) external onlyOwner {
      powerUpFee = _fee;
  }
  
   ///@dev Function to get count of total blots owned by address, displayed as an array with blotId. 
    function getBlotsByOwner(address _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](ownerBlotCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < blots.length; i++) {
            if (blotToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }
    ///@dev Function to pay to increase power of one blot
    function payForPowerUp(uint _blotId) public payable ownerOf(_blotId) {
        require(msg.value >= powerUpFee, "Minimum to level up is 0.001 Ether");
        uint powerUpValue = blots[_blotId].power + ((msg.value / (3693 ** 4)) + (msg.value / 10000000000000));
        blots[_blotId].power = powerUpValue;
    }
    ///@dev Battle function allowing 2 blots to face off by power level, winner takes wager, msg.value - tx costs. 
    ///@dev TODO add wager functionality. Wager is msg.value of both parties, winner takes all - tx fees.
    function battle(uint _attackingBlot, uint _defendingBlot) public payable {
        
        Blot storage attacker = blots[_attackingBlot];
        Blot storage defender = blots[_defendingBlot];
        
        uint winner;
        
        if (attacker.power >= defender.power) {
            attacker.wins++;
            defender.losses++;
            _attackingBlot = winner;
        }
        
        else{
            attacker.losses++;
            defender.wins++;
            _defendingBlot = winner;
        }
        
    }
}