pragma solidity ^0.4.21;
 
contract Farm{
 
    struct contractList{
        string name;
        string doctype;
        uint age;
        string date;
        string zipaddress;
        bool validity_YN;
        
    }
 
    mapping(address => contractList) public ctList;
    
    address public Owner;
    
    event NewContract(address user, string name, string doctype,uint age, string date ,string zipaddress , bool validity_YN);
    
    
    modifier onlyOwner{
        require(msg.sender == Owner);
         _;
    }
    
    constructor() public{
        Owner = msg.sender;
    }
    
    function setContract(address _user, string _name, string _doctype,uint _age, string _date ,string _zipaddress , bool _validity_YN) public onlyOwner{
        contractList storage ctrt = ctList[_user];
        ctrt.name = _name;
        ctrt.doctype = _doctype;
        ctrt.age = _age;
        ctrt.date = _date;
        ctrt.zipaddress = _zipaddress;
        ctrt.validity_YN = _validity_YN;
        
        emit NewContract(_user, _name, _doctype, _age, _date, _zipaddress, _validity_YN );
    }
    
    function getDocType(address _address) public constant returns(string name){
        return ctList[_address].doctype;
    } 
}