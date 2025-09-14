# Multi-Token Yield Farm

## ⚠️ WARNING: Educational Purpose Only
This codebase contains **intentional vulnerabilities** for training purposes. **DO NOT DEPLOY TO MAINNET OR USE WITH REAL FUNDS.**

## Overview

This project simulates a complex DeFi yield farming protocol with multiple reward tokens, referral systems, time-based bonuses, and fee structures. Your mission: **identify and document all security vulnerabilities**.


## Protocol Overview

### What is This Protocol?

**YieldFarm Protocol** is a decentralized finance (DeFi) yield farming platform that allows users to earn rewards by staking their cryptocurrency tokens. Think of it as a "crypto savings account" where users deposit tokens and earn interest, but with much more complex mechanics.

### How It Works (User Journey)

1. **Deposit LP Tokens**: Users deposit liquidity provider (LP) tokens from decentralized exchanges like Uniswap
2. **Earn Rewards**: The protocol distributes reward tokens (YFT) to stakers based on their share of the pool
3. **Time Bonuses**: The longer you stake, the higher your reward multiplier (up to 2x after 3 months)
4. **Referral System**: Users can invite friends and earn 5% commission on their referral's rewards
5. **Multiple Rewards**: Some pools offer bonus tokens on top of the primary YFT rewards
6. **Withdraw**: Users can withdraw their staked tokens plus accumulated rewards at any time

## Audit Challenge

### Your Task
1. **Conduct a comprehensive security audit**
2. **Document all vulnerabilities** found
3. **Classify severity** (Critical/High/Medium/Low)
4. **Provide exploit scenarios** where applicable
5. **Suggest remediation** strategies


## Setup Instructions

### Prerequisites
```bash
# Install dependencies
forge install
forge build
```

### Contract Structure
```
src/
├── MultiTokenYieldFarm.sol    # Main farming contract
└── YieldFarmToken.sol         # Reward token (included in main file)
```

### Key Contract Addresses (After Deployment)
- **YieldFarmToken**: Reward token contract
- **MultiTokenYieldFarm**: Main farming protocol
- **Mock LP Tokens**: For testing different pools


### Report Template
For each vulnerability, document:
```markdown
## Vulnerability: [Title]
**Severity**: High/Medium/Low
**Location**: Contract.sol, Line X
**Category**: Reentrancy/Arithmetic/Access Control/etc.

### Description
[What is the vulnerability?]

### Impact
[What damage can it cause?]

### Proof of Concept
[Code or steps to exploit]

### Recommendation
[How to fix it]
```

## Deliverables

### Expected Outputs
1. **Comprehensive audit report** with all findings
2. **Exploit contracts** (where applicable)
3. **Test suite** covering discovered edge cases
4. **Risk assessment** and recommendations


Remember: The goal is learning, not just finding bugs. Understand the **why** behind each vulnerability and how it could manifest in real protocols.

Good luck, and happy hunting! 