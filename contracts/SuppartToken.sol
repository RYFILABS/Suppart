pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC20/ERC20Detailed.sol";

contract SuppartToken is ERC20, ERC20Detailed {
    
    event TokenBuyEvent (
        address from,
        address to,
        uint256 amount
    );
    
    event TokeSellEvent (
        address from,
        address to,
        uint256 amount
    );
    
    struct Project {
        string name;
        uint total;
    }
    
    struct AddressFunding {
        string name;
        uint total;
    }
    
    mapping(address => AddressFunding[]) AddressProjects;
    Project[] ProjectTotals;
    
    address private owner;
    mapping (address => uint256) pendingWithdrawals;
    
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
        //require(_projectName, "You must provide a project_name");
        
        bool foundproject;
        uint project_index;
        
        transferFrom(owner, msg.sender, _amount);
        
        (foundproject, project_index) = getProjectIndex(_projectName);
        
        if(foundproject) {
            ProjectTotals[project_index].total += _amount;
        } else {
            createSupportProject(_projectName);
        }
        
        emit TokenBuyEvent(owner, msg.sender, _amount);
    }
    
    function sellToken(string memory _projectName, uint256 _amount) public {
        
        bool foundproject;
        uint project_index;
        
        (foundproject, project_index) = getProjectIndex(_projectName);
        
        require(foundproject == true, 'You must provide a valid _projectName');
        
        AddressFunding[] memory addressfunding = AddressProjects[msg.sender];
        
        for(uint i = 0; i< addressfunding.length; i++) {
            
            if(keccak256(bytes(addressfunding[i].name)) == keccak256(bytes(_projectName))){
                
                //found project for this address
                addressfunding[i].total -= _amount;
                
            }
        }
        
        pendingWithdrawals[msg.sender] = _amount;
        
        transfer(owner, _amount);
        
        withdrawEth();
        
        emit TokeSellEvent(msg.sender, owner, _amount);
    }
    
    function withdrawEth() public {
        uint256 amount = pendingWithdrawals[msg.sender];
        // Pending refund zerod before to prevent re-entrancy attacks
        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount * 1 ether);
    }
    
    function createSupportProject(string memory _projectName) public returns(bool result, uint id){ 
        bool foundproject;
        
        (foundproject, ) = getProjectIndex(_projectName);
        
        require(foundproject == false, "There is already a project with this name.");
        
        Project memory _newProject = Project(_projectName, 0);
            
        ProjectTotals.push(_newProject);
        
        id = ProjectTotals.length - 1;
        
        return (true, id);
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

