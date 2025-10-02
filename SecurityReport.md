## Issue 1 : Bonus Reward Backdating Vulnerability

### Summary

When a bonus reward token is added to a pool after users have already deposited, all existing deposits incorrectly receive the full bonus rewards, even though they were made before the bonus period started. This creates unfair distribution where early depositors get bonus rewards they never earned.

### Vulnerability Details

The contract calculates bonus rewards using a global "accumulated bonus per share" value that applies equally to all deposits, regardless of when they were made.

Here's what happens:

- Alice deposits 100 tokens at Block 10 (no bonus active)

- At Block 50, the owner adds a bonus token that pays 1 token per block

- Bob deposits 100 tokens at Block 50 (bonus is now active)

- At Block 70, the contract calculates that 20 bonus tokens have been earned (20 blocks × 1 token/block)

- Both Alice and Bob receive 10 bonus tokens each (100 shares × accumulated bonus)

**The Problem:** Alice's deposit existed for 40 blocks before the bonus started (blocks 10-49), but she still gets the same bonus rate as Bob, who deposited exactly when the bonus began.

### Impact

- Unfair Rewards: Early depositors receive bonus tokens for periods when no bonus was active

- Economic Inefficiency: Bonus tokens are wasted on deposits that shouldn't qualify

- Manipulation Risk: Users can front-run bonus announcements by depositing early, then collecting unearned bonuses
    
### Recommended Mitigation

Track bonus periods separately and only apply bonuses to deposits made during active bonus periods.

## Issue 2: Fee Collection Inflation Vulnerability

### Summary

The contract mints 10% extra reward tokens to the fee collector, but this additional minting is not accounted for in the reward calculations. This creates token inflation where more tokens are minted than are allocated to users, breaking the reward accounting system.

### Vulnerability Details

In the `updatePool()` function, the contract does this:

```
    uint256 reward = (multiplier * rewardPerBlock * pool.allocPoint) / totalAllocPoint;

    // Mint rewards
    rewardToken.mint(address(this), reward);          // Mint for users
    rewardToken.mint(feeCollector, reward / 10);     // Mint extra 10% for fees

    pool.accRewardPerShare += (reward * 1e12) / stakingSupply;
```

**The Problem:**

- Only reward amount is added to accRewardPerShare

- But reward + reward/10 tokens are actually minted

- The contract owes users reward tokens based on accounting, but has minted 1.1 * reward tokens

- This creates a mismatch between allocated rewards and actual token supply

### Impact

- Accounting Mismatch: Contract tracks fewer rewards than actually exist

- Incorrect Reward Rates: accRewardPerShare underestimates true reward distribution

- Potential Insolvency: If all users withdraw, there may not be enough tokens to cover accounted rewards

- Hidden Inflation: 10% of all minted rewards are unaccounted for in the reward system

### Recommended Mitigation

The protocol should mint only the accounted amount:

```
    function updatePool(uint256 _pid) public {
        // ... existing calculations ...
        
        uint256 reward = (multiplier * rewardPerBlock * pool.allocPoint) / totalAllocPoint;
        
        // Mint only the reward amount to contract
        rewardToken.mint(address(this), reward);
        
        // Update accounting with the full reward amount
        pool.accRewardPerShare += (reward * 1e12) / stakingSupply;
        
        // Fee is taken from the contract balance, not minted separately
        uint256 feeAmount = reward / 10;
        safeRewardTransfer(feeCollector, feeAmount);
        
        pool.lastRewardBlock = block.number;
    }
```

## Issue 3: Time Multiplier Minting Mismatch Vulnerability

### Summary

The contract applies time-based multipliers when calculating rewards for users during withdrawals, but these multipliers are not considered when minting the actual reward tokens. This creates a situation where the contract mints fewer tokens than it needs to pay out, potentially leading to insolvency.

### Vulnerability Details

In the `withdraw()` function, rewards are calculated with a time multiplier:

```
    // Calculate pending rewards with time multiplier
    uint256 pending = ((user.amount * pool.accRewardPerShare) / 1e12) - user.rewardDebt;
    uint256 timeMultiplier = getTimeMultiplier(user.lastDepositTime);
    pending = (pending * timeMultiplier) / 100;  // Apply multiplier
```

However, in `updatePool()`, rewards are minted without considering these multipliers:

```
    uint256 reward = (multiplier * rewardPerBlock * pool.allocPoint) / totalAllocPoint;
    rewardToken.mint(address(this), reward);  // Mint base amount only
```

**The Problem:**

- Contract mints tokens based on base reward rates

- But pays out tokens multiplied by time multipliers (up to 2x)

- Over time, the contract will owe more tokens than it has minted

- Users with long-term stakes will receive more rewards than were ever minted

### Impact

- Contract Insolvency: The contract cannot pay all promised rewards

- Fund Loss: Later users may not receive their full rewards

- Accounting Break: Reward tracking becomes meaningless

- Unfair Distribution: Early withdrawers get full rewards, late withdrawers get nothing when contract is empty

### Recommended Mitigation

The protocol should either:

- Remove time multipliers from reward calculation, or
- Mint rewards accounting for potential multipliers, or 
- Track time multipliers seperatley from base rewards

## Issue 4: Incorrect Referral Commission Funding Vulnerability

### Summary

The contract pays referral commissions from the farm's reward pool instead of deducting them from the user's actual rewards. This means the farm subsidizes referral payments, allowing users to receive their full rewards while referrers get additional "free" tokens from the contract.

### Vulnerability Details

In the `withdraw()` function, referral commissions are handled incorrectly:

```
    if (pending > 0) {
        safeRewardTransfer(msg.sender, pending);  // User gets full rewards
        
        // Pay referral commission FROM CONTRACT
        if (user.referrer != address(0)) {
            uint256 commission = (pending * referralCommission) / 10000;
            safeRewardTransfer(user.referrer, commission);  // Extra tokens from contract
            userInfo[_pid][user.referrer].referralRewards += commission;
            emit ReferralCommissionPaid(msg.sender, user.referrer, commission);
        }
    }
```

**The Problem:**

- User receives 100% of their pending rewards

- Referrer receives an ADDITIONAL 5% commission from the contract

- The contract pays out 105% of what should be paid for each referred user

- This creates token inflation and unfair advantage for referred users

### Impact

- Token Inflation: Contract pays out more rewards than allocated

- Unfair Advantage: Referred users effectively get bonus rewards

- Fund Drain: Contract depletes faster than intended

- Economic Imbalance: Referral system costs the protocol instead of the user

### Recommended Mitigation

Deduct commission from user's rewards

