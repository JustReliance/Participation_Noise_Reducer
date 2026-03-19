```markdown
# Participation Noise Reducer

## Overview
The **Participation Noise Reducer** smart contract is designed to filter low-signal burst activity in decentralized systems. It monitors user interactions and penalizes excessively noisy participation while rewarding consistent, meaningful contributions. This ensures a fair and balanced engagement environment.

---

## Features
- Noise filtering based on activity frequency
- Rewards consistent participation
- Penalizes excessive burst activity
- Configurable activity window and thresholds
- Transparent read-only access to user scores

---

## Error Codes
| Code | Description |
|------|-------------|
| u400  | Too noisy: user exceeded allowed activity threshold |

---

## Configuration Constants
- **NOISE-WINDOW** – Number of blocks defining the activity window (~1 day)  
- **MAX-ACTIONS-IN-WINDOW** – Maximum allowed actions within the window  
- **NOISE-PENALTY** – Deduction applied for exceeding maximum actions  
- **SIGNAL-REWARD** – Reward added for valid participation outside noisy bursts  

---

## Data Storage

### On-Chain Maps
| Map | Description |
|-----|-------------|
| `last-action-block` | Block height of the user's last activity |
| `window-action-count` | Number of actions within the current noise window |
| `participation-score` | Noise-adjusted participation score |

---

## Core Functions

### `record-participation`
Records a user action while managing noise:
- First action initializes score and counters.
- Actions outside the noise window reset counters and reward the user.
- Actions inside the noise window increment counters:
  - Exceeding `MAX-ACTIONS-IN-WINDOW` triggers a penalty.
  - Within limit, activity is counted without modification.

---

### Read-Only Functions
- `get-score(user)` – Returns the current participation score.  
- `get-action-count(user)` – Returns the number of actions within the current window.  

---

## How It Works
1. Users submit participation actions via `record-participation`.  
2. The contract calculates the gap since the last action.  
3. If the gap exceeds `NOISE-WINDOW`, the user is rewarded and counters reset.  
4. If the user exceeds `MAX-ACTIONS-IN-WINDOW` within the window, a penalty is applied and an error is returned.  
5. All updates are stored on-chain for transparency and auditability.  

---

## Use Cases
- Community contribution scoring  
- Moderation of spammy or burst activity  
- Incentivizing steady engagement over time  
- Integration with reputation or rewards systems  

---

## License
This project is open-source and available for modification and use in decentralized applications.
```
