// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ETHMessenger {
    
    event MessageSent(
        address indexed sender,
        address indexed recipient,
        uint256 amount,
        string message,
        uint256 timestamp
    );

    function sendMessage(address payable recipient, string calldata message) 
        external 
        payable 
    {
        require(recipient != address(0), "Recipient cannot be zero address");
        require(msg.value > 0, "Must send ETH with message");
        
        (bool success, ) = recipient.call{value: msg.value}("");
        require(success, "ETH transfer failed");
        
        emit MessageSent(msg.sender, recipient, msg.value, message, block.timestamp);
    }

    function sendMessageMultipleTimes(
        address payable recipient, 
        string calldata message, 
        uint256 times
    ) 
        external 
        payable 
    {
        require(recipient != address(0), "Recipient cannot be zero address");
        require(msg.value > 0, "Must send ETH with message");
        require(times > 0 && times <= 100, "Times must be between 1 and 100");
        
        uint256 amountPerSend = msg.value / times;
        require(amountPerSend > 0, "Amount per send must be > 0");
        
        for (uint256 i = 0; i < times; i++) {
            (bool success, ) = recipient.call{value: amountPerSend}("");
            require(success, "ETH transfer failed");
            
            emit MessageSent(msg.sender, recipient, amountPerSend, message, block.timestamp);
        }
        
        uint256 remainder = msg.value - (amountPerSend * times);
        if (remainder > 0) {
            (bool success, ) = recipient.call{value: remainder}("");
            require(success, "Remainder transfer failed");
        }
    }

    function batchSend(
        address payable[] calldata recipients,
        uint256[] calldata amounts,
        string[] calldata messages
    ) 
        external 
        payable 
    {
        require(
            recipients.length == amounts.length && 
            recipients.length == messages.length,
            "Arrays length mismatch"
        );
        require(recipients.length <= 50, "Max 50 recipients per batch");
        
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }
        
        require(msg.value >= totalAmount, "Insufficient ETH sent");
        
        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Invalid recipient");
            require(amounts[i] > 0, "Amount must be > 0");
            
            (bool success, ) = recipients[i].call{value: amounts[i]}("");
            require(success, "ETH transfer failed");
            
            emit MessageSent(msg.sender, recipients[i], amounts[i], messages[i], block.timestamp);
        }
        
        uint256 excess = msg.value - totalAmount;
        if (excess > 0) {
            (bool success, ) = payable(msg.sender).call{value: excess}("");
            require(success, "Excess refund failed");
        }
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}