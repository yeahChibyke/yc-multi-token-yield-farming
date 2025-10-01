## Bonus Reward Backdating Vulnerability

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

Track bonus periods separately and only apply bonuses to deposits made during active bonus periods: