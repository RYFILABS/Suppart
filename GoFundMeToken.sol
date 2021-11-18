pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC20/ERC20Detailed.sol";

contract GoFundMeToken is ERC20, ERC20Detailed {
    
    struct Project {
        string name;
        uint total;
    }
    
    Project[] public ProjectTotals;
    
    struct AddressFunding {
        string name;
        uint total;
    }
    
    mapping(address => Project[]) projects;
    
    address private owner;
    
    event TokenBuyEvent (
        address from,
        address to,
        uint256 amount
    );
    
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    )
        ERC20Detailed(name, symbol, 18)
        public
    {
        _mint(msg.sender, initialSupply);
        owner = msg.sender;
    }
    
    function buyToken(string calldata _projectName, uint256 _amount) external payable {
        require(_amount == ((msg.value / 1 ether)), "Incorrect amount of Eth.");
        //require(project_name, "You must provide a project_name");
        bool foundproject;
        uint project_index;
        
        transferFrom(owner, msg.sender, _amount);
        
        (foundproject, project_index) = getProjectIndex(_projectName);
        
        if(foundproject) {
            ProjectTotals[project_index].total += _amount;
        }
        
        emit TokenBuyEvent(owner, msg.sender, _amount);
    }
    
    function getProjectIndex(string memory project_name) internal view returns(bool foundproject, uint project_index){
        for(uint i = 0; i< ProjectTotals.length; i++) {
            
            if(keccak256(bytes(ProjectTotals[i].name)) == keccak256(bytes(project_name))){
                
                return (true, i);
            }
            
        }
        return (false, 0);
    }
    
}

