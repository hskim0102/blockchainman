pragma solidity ^0.4.26;


contract ContractPjt{
 
    //나의 계약 관련 구조체 선언
    struct contractList{
        address contractor;         //계약하는 상대 주소
        string title;               //계약 이름
        string content;             //계약서 내용
        uint date;                  //계약 날짜
        uint validate_date;         //계약 만료 날짜
        uint256 deposit;            //계약금
        bool isValid;               //유효여부
        bool isSecret;              //공개여부 추가
        bool isTransferable;        //양도가능 여부 추가
        bool isChecked;             //계약서 확인 여부 추가
    }
 
    //계약 제목으로 계약서 맵핑
    mapping(string => contractList) private ctList;
    
    address public Owner;           //계약의 주인 주소
    
    event NewContract(address contractor, string title, string content, uint date, uint validate_date, uint256 deposit, bool isValid, bool isSecret, bool isTransferable);
    
    // 오너가 아니면 수정을 못하게 한다.
    modifier onlyOwner{
        require(msg.sender == Owner, "Only Owner can call this.");
         _;
    }
    
    constructor() public{
        Owner = msg.sender;
    }
    
    //계약서 작성 
    function setContract(string _title, string _content, uint _date, uint _validate_date, uint256 _deposit, bool _isValid, bool _isSecret, bool _isTransferable) public {
        require(Owner != msg.sender, "contractor is not same with Owner");
        
        var ctrt = ctList[_title];
        ctrt.contractor = msg.sender;
        ctrt.title = _title;
        ctrt.content = _content;
        ctrt.date = _date;
        ctrt.validate_date = _validate_date;
        ctrt.deposit = _deposit;
        ctrt.isValid = _isValid;
        ctrt.isSecret = _isSecret;
        ctrt.isTransferable = _isTransferable;
        ctrt.isChecked = false;             //계약자가 쓴 계약서를 아직 확인하지 않은 상태
    }

    //계약자의 계약서 확인
    function checkContract(string title) payable public onlyOwner returns(uint256) {
        ctList[title].isChecked = true;
        require(Owner.balance >= ctList[title].deposit);
        require(msg.value == ctList[title].deposit * 1 ether, "It must be same with deposit");
        
        emit NewContract(ctList[title].contractor, ctList[title].title, ctList[title].content, ctList[title].date, ctList[title].validate_date, ctList[title].deposit, ctList[title].isValid, ctList[title].isSecret, ctList[title].isTransferable);
        return ctList[title].deposit;
    }

    //계약서 내용 열람
    function showContent(string title) public returns(string) {
        if(!ctList[title].isSecret) {
            return ctList[title].content; 
        } else if (msg.sender == Owner || msg.sender == ctList[title].contractor) {
            return ctList[title].content;
        }

    }

    //계약금 송금
    function payContract(string title) payable public onlyOwner {
        contractList storage localCt = ctList[title];
        require(localCt.isValid, "It is not a valid contract");
        require(localCt.isChecked, "It is not confirmed by owner");
        
        localCt.deposit = localCt.deposit * 1 ether;
        
        localCt.contractor.transfer(localCt.deposit);
    }
    
    //양도 요청
    function requestTransferContract(string title, uint percent) payable public {
        require(Owner != msg.sender, "request contractor is not same with Owner");
        
        contractList storage localCt = ctList[title];
        uint remise = ctList[title].deposit * percent / 100;
        ctList[title].deposit = remise;
        require(msg.value == remise, "It must be same with remise");
    }
    
    //계약서 양도 ( 양도금 송금)
    function transferContract(string title) public onlyOwner returns (uint){
        contractList storage localCt = ctList[title];
        Owner.transfer(localCt.deposit);
        //delete ctList[title];
        
        return localCt.deposit;
        
    }
}