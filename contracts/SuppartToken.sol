// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SuppartToken is ERC20 {
    
    modifier onlyOwner {
        require(msg.sender == owner, "You do not have permission to mint these tokens!");
        _;
    }

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
    Project[] public ProjectTotals;
    
    address payable owner;
    mapping (address => uint256) pendingWithdrawals;
    

    constructor(uint256 _initialSupply) ERC20("SuppartToken", "SART" ) {
        _mint(msg.sender, _initialSupply);
        owner = payable(msg.sender);
    }

    function buyToken(uint256 _amount) external payable {
        
        require(_amount > 0, "Incorrect amount, must be a positive amount.");
        //require(_projectName, "You must provide a project_name");
        
        bool foundproject;
        uint project_index;

        string memory _projectName = "project1";
        
        transferFrom(owner, msg.sender, _amount);
        
        (foundproject, project_index) = getProjectIndex(_projectName);
        
        if(foundproject) {
            ProjectTotals[project_index].total += _amount;
        } else {
            createSuppartProject(_projectName);
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
        payable(msg.sender).transfer(amount);
    }
    
    function createSuppartProject(string memory _projectName) public returns(bool result, uint id){ 
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

    function getProjectTotals() public view returns(Project[] memory) {
        return ProjectTotals;
    }
    
    function mint(address recipient, uint amount) public onlyOwner {
        _mint(recipient, amount);
    }

}
