# EasyGPT Demo Questions (Step 0)

## Demo Objective
Demonstrate that EasyGPT can:
1) Answer operator-grade analytics questions across POS + delivery
2) Identify margin leaks at platform + item level
3) Take one controlled action (price/availability) with audit logging

## Demo Setup Assumptions
- Connected systems: Square (POS) + 1 delivery platform (DoorDash OR Uber Eats)
- Time ranges: 7d and 30d
- Data: at least 200+ orders, 30+ items recommended
- Cost model: item cost can be estimated (COGS%) or a simple per-item cost table

---

## Core Demo Flow (10 minutes)

### Q1 — Platform profitability snapshot (hook)
**User asks:** "Which platform was most profitable in the last 7 days?"
**Expected output (structure):**
- Ranked list by Net Profit and Margin%
- For each platform:
  - Gross Sales
  - Fees/Commission (if available)
  - Estimated COGS
  - Net Profit
  - Margin %
- 1–2 reasons (plain English)
- 1 recommendation (actionable)

**Example response format:**
- Platform A: Margin 22% | Net Profit $X
- Platform B: Margin 16% | Net Profit $Y
Reasons: higher discounts on B, higher commission on B
Recommendation: increase prices on B for low-margin items or reduce promotions

---

### Q2 — What changed vs last week (why)
**User asks:** "Why did DoorDash profit drop compared to the previous week?"
**Expected output:**
- Week-over-week delta (Net Profit, Margin%, Orders, AOV)
- Top 2 drivers:
  - higher fees/discounts
  - item mix shift
  - more refunds/cancellations
  - lower AOV
- Recommendation + next step question

---

### Q3 — Loss-making items (pain + clarity)
**User asks:** "Which items are losing money on delivery in the last 30 days?"
**Expected output:**
- Top 5 worst margin items (delivery only)
- For each item:
  - Units sold
  - Net revenue per unit
  - Estimated cost per unit
  - Margin per unit ($ and %)
- Suggested fix per item:
  - price increase amount
  - remove/disable on delivery
  - restrict hours
  - reduce modifiers / packaging add-on

---

### Q4 — Item drill-down (trust builder)
**User asks:** "Explain why [Item X] is low margin and what to change."
**Expected output:**
- Breakdown:
  - sell price by platform
  - fees impact
  - modifier/upsell frequency (if available)
  - refund rate (if available)
  - cost estimate assumptions
- 2 options:
  - Conservative fix (small price change)
  - Aggressive fix (availability/time restrictions)
- Confirm question: "Do you want me to apply this to DoorDash only?"

---

### Q5 — One action (the ‘wow’ moment)
Pick ONE action for the demo:

Option A (Pricing):
**User asks:** "Increase [Item X] price by $1 on DoorDash only."
**Expected output:**
- Confirmation step:
  - Old price → New price
  - Platforms affected (DoorDash only)
  - Effective time (now)
- Audit log entry created
- Status: "Queued / Applied"

Option B (Availability):
**User asks:** "Disable [Item X] on Uber Eats after 9pm."
**Expected output:**
- Confirmation step:
  - Schedule: 9pm–close
  - Platforms affected
- Audit log entry created
- Status: "Queued / Applied"

---

### Q6 — Proof / audit log (credibility)
**User asks:** "Show me what changes EasyGPT made today."
**Expected output:**
- List of changes (time, user, action, platform, old → new)
- Ability to rollback (even if mocked for demo):
  - "Revert change" button / command

---

## Extra Questions (Optional Buttons in UI)

### Ops/Trend
1) "What are my top 5 most profitable items across all channels?"
2) "What’s the best-selling item vs the best-profit item?"
3) "What days/hours are strongest for delivery vs in-store?"
4) "Any unusual spike in refunds or cancellations this week?"

### Menu Hygiene
5) "Which items have inconsistent pricing across platforms?"
6) "Which items are missing modifiers on DoorDash vs POS?"
7) "Which items should be bundled into combos based on order patterns?" (v2)

### Action Suggestions
8) "Suggest 3 price changes to increase weekly profit by $300."
9) "Suggest 3 items to promote on the least profitable platform."

---

## Non-Negotiable Response Rules (for EasyGPT)
- Never invent numbers.
- Always cite the time range and data sources used.
- If a metric is missing (e.g., commission), say so and proceed with best estimate.
- Any action requires explicit confirmation + creates an audit log entry.
