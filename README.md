# ETH Messenger

A simple, gas-efficient smart contract for sending ETH with text messages on Base L2. Send payments to multiple recipients, batch transactions, or automate recurring payments - all with customizable messages attached.

## Contract Address

**Base Mainnet (Verified)**
```
0x24DFcA03172Fb3e7E40D0be79678dDCeB287D13c
```

View on BaseScan: https://basescan.org/address/0x24DFcA03172Fb3e7E40D0be79678dDCeB287D13c#code

## Features

- **Send ETH with Messages**: Attach text messages to ETH transfers
- **Batch Payments**: Send to one recipient multiple times in a single transaction
- **Multi-Recipient**: Send to different recipients with individual amounts and messages
- **No Storage**: Contract does not hold funds - direct forwarding only
- **Gas Efficient**: Optimized for low transaction costs
- **Verified Contract**: Full transparency with verified source code

## Use Cases

- Tipping with personalized messages
- Recurring allowances or payments
- Batch payroll or airdrops
- Donation campaigns with notes
- P2P payments with context
- Social payments ("thanks for coffee!")

## Functions

### `sendMessage(address recipient, string message)`
Send ETH to a single recipient with a message.

**Parameters:**
- `recipient`: Address to receive ETH
- `message`: Text message (up to ~280 characters recommended)

**Example:**
```solidity
sendMessage(0xRecipient, "Thanks for your help!")
// Value: 0.01 ETH
```

### `sendMessageMultipleTimes(address recipient, string message, uint256 times)`
Send ETH to the same recipient multiple times in one transaction.

**Parameters:**
- `recipient`: Address to receive ETH
- `message`: Text message for all sends
- `times`: Number of times to send (1-100)

**Example:**
```solidity
sendMessageMultipleTimes(0xRecipient, "Monthly allowance", 5)
// Value: 0.05 ETH (0.01 per send × 5 times)
```

### `batchSend(address[] recipients, uint256[] amounts, string[] messages)`
Send different amounts to multiple recipients with individual messages.

**Parameters:**
- `recipients`: Array of addresses
- `amounts`: Array of amounts (in wei)
- `messages`: Array of messages

**Example:**
```solidity
batchSend(
  [0xAlice, 0xBob, 0xCharlie],
  [10000000000000000, 20000000000000000, 30000000000000000], // 0.01, 0.02, 0.03 ETH
  ["For Alice", "For Bob", "For Charlie"]
)
// Total Value: 0.06 ETH
```

### `getContractBalance()`
Returns the contract's ETH balance (should always be 0).

## Events

**MessageSent**
```solidity
event MessageSent(
    address indexed sender,
    address indexed recipient,
    uint256 amount,
    string message,
    uint256 timestamp
)
```

All transfers emit this event, which can be tracked on-chain.

## How to Use

### Option 1: BaseScan Interface
1. Go to the [contract page](https://basescan.org/address/0x24DFcA03172Fb3e7E40D0be79678dDCeB287D13c#writeContract)
2. Connect your wallet (MetaMask, Coinbase Wallet, etc.)
3. Select a function under "Write Contract"
4. Fill in the parameters
5. Enter the ETH amount to send
6. Click "Write" and confirm in your wallet

### Option 2: Thirdweb Dashboard
1. Import contract at [thirdweb.com/dashboard](https://thirdweb.com/dashboard)
2. Use contract address: `0x24DFcA03172Fb3e7E40D0be79678dDCeB287D13c`
3. Select Base network
4. Interact through the Explorer tab

### Option 3: Direct Integration
```javascript
import { ethers } from 'ethers';

const CONTRACT_ADDRESS = "0x24DFcA03172Fb3e7E40D0be79678dDCeB287D13c";
const ABI = [...]; // Get from BaseScan

const provider = new ethers.BrowserProvider(window.ethereum);
const signer = await provider.getSigner();
const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

// Send message with ETH
await contract.sendMessage(
  "0xRecipientAddress",
  "Payment for services",
  { value: ethers.parseEther("0.01") }
);
```

## Technical Specifications

- **Solidity Version**: 0.8.20
- **Optimization**: Enabled (200 runs)
- **Network**: Base (Chain ID: 8453)
- **License**: MIT
- **Constructor Arguments**: None
- **Contract Storage**: No funds stored - all ETH forwarded immediately

## Gas Costs (Approximate)

- `sendMessage`: ~50,000 gas (~$0.10-0.30)
- `sendMessageMultipleTimes` (5x): ~100,000 gas (~$0.20-0.50)
- `batchSend` (3 recipients): ~150,000 gas (~$0.30-0.70)

*Note: Costs vary based on Base network congestion*

## Security Features

- No fund storage (no risk of locked funds)
- Direct ETH forwarding using `.call`
- Input validation (non-zero addresses, amounts, etc.)
- Protection against reentrancy (no state changes after transfers)
- Open source and verified code

## Development

### Prerequisites
- Node.js v18+
- Hardhat
- Base network ETH for gas

### Installation
```bash
git clone <your-repo>
cd eth-messenger
npm install
```

### Compile
```bash
npx hardhat compile
```

### Deploy
```bash
npx hardhat run scripts/deploy.js --network base
```

### Verify
```bash
npx hardhat verify --network base <CONTRACT_ADDRESS>
```

## Contract ABI

The full ABI is available on [BaseScan](https://basescan.org/address/0x24DFcA03172Fb3e7E40D0be79678dDCeB287D13c#code) or in the `artifacts` folder after compilation.

## Example Integrations

### Send Tips on Your Website
```javascript
async function sendTip(recipientAddress, message, amountEth) {
  const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);
  const tx = await contract.sendMessage(
    recipientAddress,
    message,
    { value: ethers.parseEther(amountEth) }
  );
  await tx.wait();
  console.log("Tip sent!");
}
```

### Monthly Recurring Payment
```javascript
// Send 0.1 ETH per month for 12 months
async function setupRecurring() {
  const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);
  const tx = await contract.sendMessageMultipleTimes(
    recipientAddress,
    "Monthly payment",
    12,
    { value: ethers.parseEther("1.2") } // 0.1 × 12
  );
  await tx.wait();
}
```

### Team Payroll
```javascript
async function payTeam(teamMembers) {
  const recipients = teamMembers.map(m => m.address);
  const amounts = teamMembers.map(m => ethers.parseEther(m.amount));
  const messages = teamMembers.map(m => `Salary for ${m.name}`);
  
  const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);
  const tx = await contract.batchSend(recipients, amounts, messages);
  await tx.wait();
}
```

## FAQ

**Q: Can I get my ETH back if I send to the wrong address?**  
A: No, all transfers are final. Always verify the recipient address before sending.

**Q: Does the contract hold my funds?**  
A: No, all ETH is forwarded immediately to recipients. The contract never stores funds.

**Q: What's the maximum message length?**  
A: Technically unlimited, but longer messages cost more gas. Keep under 280 characters for efficiency.

**Q: Can I cancel a transaction?**  
A: No, once confirmed on-chain, transactions are permanent.

**Q: Is this contract audited?**  
A: The contract is open source and verified. Use at your own risk. Consider an audit for production use.

## Support & Community

- **Issues**: [GitHub Issues](your-repo/issues)
- **Discussions**: [GitHub Discussions](your-repo/discussions)
- **BaseScan**: [View Contract](https://basescan.org/address/0x24DFcA03172Fb3e7E40D0be79678dDCeB287D13c)

## License

MIT License - see LICENSE file for details.

## Acknowledgments

Built for Base L2. Deployed and verified using Hardhat and Thirdweb.

---

**Contract Address**: `0x24DFcA03172Fb3e7E40D0be79678dDCeB287D13c`  
**Network**: Base Mainnet  
**Status**: Verified and Active