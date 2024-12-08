// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract cfa {
    mapping (address => bool) buyers;
    uint256 public price = 10 ether; //будет зависеть от объёма привлекаемых средств: hardcap
    address public owner;//address: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    address public cfaAddress;//address: 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8
    bool fullyPaid; //false

    event ItemFullyPaid(uint _price, address _cfaAddress); //передаём цену и адрес

    constructor() {
        owner = msg.sender; 
//msg глобальный объект sender- тот, кто запускает транзакцию( по сути это альфа банк). Подумать как указать здесть эмитента
        cfaAddress = address(this);
    }

    function addBuyer(address _addr) public {
        require(owner == msg.sender, "No access");//доступ к списку инвесторов только у владельца
        buyers[_addr] = true;
    }
    function getBuyer(address _addr) public view returns(bool) {
        require(owner == msg.sender, "No access");

        return buyers[_addr];
    }
    function getBalance() public view returns(uint) { //uint- целое число без знака
        return cfaAddress.balance;
    }
    
    function withdrawAll() public  { //вывод денег на счёт
        require(owner == msg.sender && fullyPaid, "No access");//деньги снимает именно владелец и только всю сумму

        address payable receiver = payable(msg.sender);

        receiver.transfer(cfaAddress.balance);//переводим всё с баланса на адрес цфа
    }

    receive() external payable { 
        require(buyers[msg.sender] && msg.value <= price && !fullyPaid, "Rejected");// проверяем, чтобы отправитель денег был в списке покупателей и сумма перевода должна быть меньше хардкэп
         
         if (cfaAddress.balance == price) {
            fullyPaid = true;

            emit ItemFullyPaid(price, cfaAddress);//создаём событие

         }
    }

}