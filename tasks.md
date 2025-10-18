# MyHoopster - Matchup Simulation Enhancement Tasks

## Overview
This document tracks the implementation of enhanced matchup simulation features for MyHoopster. Each task builds upon the previous ones to create a more engaging and realistic basketball match experience.

---

## Phase 1: Core Gameplay Enhancements

### Task 1: Smarter AI with Playstyle Implementation ✅
**Status**: COMPLETED
**Priority**: High
**Estimated Time**: 1-2 hours
**Actual Time**: ~30 minutes

**Description**:
Make opponents use their playstyle attribute to determine action preferences instead of random selection.

**Implementation Details**:
- ✅ Created playstyle-based action weights with `_getPlaystyleWeights()` method
- ✅ Defined playstyle profiles:
  - **Shooter**: 60% shoot, 25% drive, 15% trick
  - **Speedster/Athletic**: 25% shoot, 60% drive, 15% trick
  - **Dribbler/Streetball/Flashy**: 25% shoot, 30% drive, 45% trick
  - **Defender**: 50% shoot, 35% drive, 15% trick (conservative)
  - **Scorer**: 50% shoot, 35% drive, 15% trick
  - **All-Around/Balanced**: 35% shoot, 35% drive, 30% trick
  - **Legendary**: 40% shoot, 30% drive, 30% trick
- ✅ Created `_selectWeightedAction()` for weighted random selection
- ✅ Updated `_opponentTurn()` to use playstyle-based action selection
- ✅ Verified all opponent playstyles are properly set in park.dart

**Files Modified**:
- `lib/screens/match_screen.dart` - Added two new methods and updated `_opponentTurn()`

**Testing**:
- ✅ Code compiles successfully
- 🔄 Manual testing needed: Play matches against different opponent types
- 🔄 Verify shooters take more shots, speedsters drive more, dribblers use tricks more

---

### Task 2: Stamina/Fatigue System ✅
**Status**: COMPLETED
**Priority**: High
**Estimated Time**: 2-3 hours
**Actual Time**: ~45 minutes

**Description**:
Implement a fatigue system where player and opponent performance degrades as the match progresses based on stamina attribute.

**Implementation Details**:
- ✅ Added `playerStamina` and `opponentStamina` state variables (0-100)
- ✅ Created `_getStaminaCost()` method:
  - Shoot: 3 stamina (least tiring)
  - Drive: 6 stamina (most tiring - explosive movement)
  - Trick: 5 stamina (moderately tiring)
- ✅ Created `_getFatigueModifier()` method:
  - Returns modifier between 0.5 and 1.0 based on current stamina
  - Higher stamina attribute = better performance when tired
  - Stamina attribute reduces penalty when fatigued
- ✅ Created `_updateStamina()` to reduce stamina after actions
- ✅ Created `_recoverStamina()` for small recovery between possessions (1-3 points)
- ✅ Updated `_performAction()` to apply fatigue modifier and stamina costs
- ✅ Updated `_opponentTurn()` to apply fatigue modifier and stamina costs
- ✅ Updated `_startMatch()` to reset stamina to 100 at match start
- ✅ Added stamina bars to UI in `_buildPlayerScore()`:
  - Visual bar showing current stamina percentage
  - Color-coded: Green (>60%), Yellow (30-60%), Red (<30%)
  - Displays stamina percentage below bar

**Files Modified**:
- `lib/screens/match_screen.dart` - Added stamina system throughout

**Testing**:
- ✅ Code compiles successfully
- 🔄 Manual testing needed: Verify stamina decreases during match
- 🔄 Check that low stamina reduces success rates
- 🔄 Test that high stamina attribute provides advantage
- 🔄 Verify stamina bars display correctly and update in real-time

---

### Task 3: Defensive Actions (Steal/Block) ✅
**Status**: COMPLETED
**Priority**: Medium
**Estimated Time**: 2-3 hours
**Actual Time**: ~40 minutes

**Description**:
Add defensive actions that allow players to attempt steals or blocks instead of just offensive moves.

**Implementation Details**:
- ✅ Added `isDefending` and `defensiveAction` state variables
- ✅ Created `_buildDefensiveButtons()` widget that appears during opponent's turn
- ✅ Added three defensive options:
  - **Steal**: Attempt to steal the ball (max 40% success rate)
  - **Block**: Attempt to block the shot (max 35% success rate)
  - **Let Play**: Don't attempt defense (passive)
- ✅ Implemented steal mechanic:
  - Success based on player's defense vs opponent's dribbling
  - Formula: `defense / (defense + dribbling) * 0.4`
  - On success: Player gets possession immediately, opponent loses turn
  - On failure: Opponent gets 20% bonus to success rate
- ✅ Implemented block mechanic:
  - Success based on player's defense vs opponent's shooting/speed average
  - Formula: `defense / (defense + avg(shooting, speed)) * 0.35`
  - On success: Block the shot, player regains possession
  - On failure: Opponent gets 20% bonus to success rate
- ✅ Added defensive feedback messages:
  - "STEAL! You got the ball!"
  - "BLOCKED! Great defense!"
  - "Steal attempt failed! [Opponent] scores!"
  - "Block attempt failed! [Opponent] scores!"
- ✅ Updated `_opponentTurn()` to handle defensive actions
- ✅ Reset defensive state properly between turns

**Files Modified**:
- `lib/screens/match_screen.dart` - Added defensive system throughout

**Testing**:
- ✅ Code compiles successfully
- 🔄 Manual testing needed: Test steal success rates feel balanced
- 🔄 Test block mechanics work correctly
- 🔄 Verify risk/reward balance (failed defense gives opponent bonus)
- ⏳ Stats tracking for steals/blocks (deferred to Task 7)

---

### Task 4: Advanced Mechanics (Shot Clock, Fouls, Free Throws) ⏳
**Status**: Not Started  
**Priority**: Medium  
**Estimated Time**: 3-4 hours

**Description**:
Add shot clock, foul system, and free throw mechanics for more realistic gameplay.

**Implementation Details**:
- **Shot Clock**:
  - 24-second shot clock per possession
  - Visual countdown timer
  - Turnover if time expires
  - Resets on possession change
- **Foul System**:
  - Random chance of foul on drives (higher with aggressive defense)
  - Shooting fouls grant free throws
  - Non-shooting fouls give possession
  - Track personal fouls (maybe limit to 5?)
- **Free Throws**:
  - Mini-game or simple shooting % based calculation
  - 2 free throws for shooting fouls
  - 1-and-1 or bonus situations
  - Update scoring to include free throw points

**Files to Modify**:
- `lib/screens/match_screen.dart` - Add shot clock UI, foul logic, free throw system
- Create new widget for shot clock display
- Create free throw mini-game widget (optional)

**Testing**:
- Verify shot clock counts down correctly
- Test foul frequency feels realistic
- Test free throw mechanics work properly

---

## Phase 2: Enhanced Experience

### Task 5: Momentum/Hot-Cold Streak System ✅
**Status**: COMPLETED
**Priority**: Medium
**Estimated Time**: 2 hours
**Actual Time**: ~35 minutes

**Description**:
Implement momentum system where consecutive makes/misses affect future success rates.

**Implementation Details**:
- ✅ Added `playerStreak` and `opponentStreak` state variables
- ✅ Created `_getMomentumModifier()` method:
  - Returns modifier between 0.85 and 1.15
  - Hot streak (3+ makes): +10-15% success rate bonus
  - Cold streak (3+ misses): -5-10% success rate penalty
  - Bonus/penalty scales with streak length (capped at +15%/-10%)
- ✅ Created `_updateStreak()` method:
  - Increments on success, decrements on failure
  - Resets to opposite direction when streak breaks
  - Tracks separately for player and opponent
- ✅ Created `_getStreakStatus()` method:
  - Returns "🔥 ON FIRE!" for hot streaks
  - Returns "🧊 COLD" for cold streaks
  - Returns empty string for neutral
- ✅ Created `_getStreakColor()` method:
  - Orange for hot streaks
  - Blue for cold streaks
  - Grey for neutral
- ✅ Updated `_performAction()` to apply momentum modifier
- ✅ Updated `_opponentTurn()` to apply momentum modifier
- ✅ Enhanced action messages with streak context:
  - "🔥 Swish! HEATING UP!" for hot streaks
  - "🧊 Missed! Can't buy a bucket..." for cold streaks
- ✅ Added visual streak indicators to scoreboard:
  - Small badge showing streak status
  - Color-coded (orange/blue)
  - Only appears when in hot/cold streak
- ✅ Reset streaks at match start

**Files Modified**:
- `lib/screens/match_screen.dart` - Added complete momentum system

**Testing**:
- ✅ Code compiles successfully
- 🔄 Manual testing needed: Verify streaks are tracked correctly
- 🔄 Test bonus/penalty amounts feel balanced
- 🔄 Check visual indicators display properly
- 🔄 Verify messages update based on streak status

---

### Task 6: Better Animations & Play-by-Play Feedback ⏳
**Status**: Not Started  
**Priority**: Low  
**Estimated Time**: 2-3 hours

**Description**:
Enhance visual feedback with better animations and detailed play-by-play commentary.

**Implementation Details**:
- **Enhanced Action Messages**:
  - More variety in success/failure messages
  - Context-aware messages (e.g., "Clutch shot!" when close game)
  - Opponent-specific taunts/reactions
  - Score-aware commentary (e.g., "Takes the lead!")
- **Better Animations**:
  - Slide animations for score changes
  - Pulse effects on active player
  - Court animations (ball movement visualization)
  - Celebration animations on big plays
- **Play-by-Play Log**:
  - Scrollable history of recent actions
  - Color-coded by player
  - Shows running score

**Files to Modify**:
- `lib/screens/match_screen.dart` - Enhanced animations and messages
- Consider creating separate widget for play-by-play log

**Testing**:
- Verify animations are smooth
- Check message variety and appropriateness
- Test play-by-play log functionality

---

### Task 7: Match Statistics Tracking ✅
**Status**: COMPLETED
**Priority**: Medium
**Estimated Time**: 2 hours
**Actual Time**: ~45 minutes

**Description**:
Track detailed match statistics and display them during the match.

**Implementation Details**:
- ✅ Added stat tracking maps for player and opponent:
  - `fgMade` / `fgAttempted` - Field goals
  - `threeMade` / `threeAttempted` - 3-pointers
  - `turnovers` - Turnovers from steals
  - `steals` - Successful steals
  - `blocks` - Successful blocks
- ✅ Created calculation methods:
  - `_getFGPercentage()` - Calculate field goal percentage
  - `_getThreePercentage()` - Calculate 3-point percentage
  - `_resetStats()` - Reset all stats at match start
- ✅ Updated `_performAction()` to track:
  - Field goal attempts and makes
  - 3-point attempts and makes
  - Separate tracking for 2s vs 3s
- ✅ Updated defensive actions to track:
  - Steals (player stat + opponent turnover)
  - Blocks (player stat)
- ✅ Updated `_opponentTurn()` to track opponent stats
- ✅ Created `_buildStatsDisplay()` widget:
  - Shows FG% with made/attempted breakdown
  - Shows 3P% with made/attempted breakdown
  - Shows steals, blocks, turnovers
  - Side-by-side comparison (player vs opponent)
  - Color-coded (orange for player, blue for opponent)
- ✅ Added toggle button to scoreboard:
  - "Show Stats" / "Hide Stats" button
  - Expandable stats panel during match
  - Clean, modern design
- ✅ Created `_buildStatRow()` helper:
  - Reusable stat row component
  - Shows percentage and raw numbers
  - Proper alignment and spacing

**Files Modified**:
- `lib/screens/match_screen.dart` - Complete stats system

**Testing**:
- ✅ Code compiles successfully
- 🔄 Manual testing needed: Verify all stats are tracked accurately
- 🔄 Test stats display UI and toggle
- 🔄 Check stats reset properly between matches
- 🔄 Verify percentages calculate correctly

---

### Task 8: Difficulty Balancing & Formula Refinement ⏳
**Status**: Not Started  
**Priority**: High  
**Estimated Time**: 2-3 hours

**Description**:
Refine success rate formulas and balance difficulty to ensure fair and engaging matches.

**Implementation Details**:
- **Review Current Formulas**:
  - Analyze current success rate calculations
  - Test against various attribute combinations
  - Identify imbalances (too easy/hard)
- **Refinements**:
  - Adjust base success rates for each action type
  - Fine-tune defense modifier impact
  - Balance 3-point shot probability
  - Ensure attribute scaling is appropriate (50-99 range)
  - Add diminishing returns for very high attributes
- **Difficulty Scaling**:
  - Ensure opponent difficulty matches their OVR rating
  - Test progression from easy to hard opponents
  - Adjust rewards based on difficulty
- **Playtesting**:
  - Test with low, medium, and high attribute players
  - Verify win rates feel appropriate for skill differences

**Files to Modify**:
- `lib/screens/match_screen.dart` - Update success rate calculations
- `lib/models/park.dart` - Verify opponent balance

**Testing**:
- Extensive playtesting with different player builds
- Test against all opponent types
- Verify matches feel competitive but fair

---

## Phase 3: Polish & Additional Features

### Task 9: Court-Specific Effects (Optional) ⏳
**Status**: Not Started  
**Priority**: Low  
**Estimated Time**: 1-2 hours

**Description**:
Add court-specific modifiers that affect gameplay based on the park location.

**Implementation Details**:
- **Neighborhood Court**: Balanced, no modifiers
- **Downtown Court**: Indoor, better shooting conditions (+5% shooting)
- **Venice Beach**: Outdoor, wind affects 3-pointers (-5% 3PT, +5% drives)
- **Rucker Park**: Legendary, pressure affects performance (higher stakes)
- Display court effects before match starts
- Add visual indicators during match

**Files to Modify**:
- `lib/screens/match_screen.dart` - Add court modifier logic
- `lib/models/park.dart` - Add court effect properties

**Testing**:
- Verify each court has appropriate effects
- Test modifiers are applied correctly

---

### Task 10: Match Replay/Highlights (Optional) ⏳
**Status**: Not Started  
**Priority**: Low  
**Estimated Time**: 3-4 hours

**Description**:
Add ability to review match highlights or key moments after the game.

**Implementation Details**:
- Record key moments during match:
  - Big shots (3-pointers, go-ahead baskets)
  - Defensive plays (steals, blocks)
  - Streak moments (hot/cold)
  - Lead changes
- Create highlights screen showing these moments
- Option to view full play-by-play
- Save match history for later review

**Files to Modify**:
- `lib/screens/match_screen.dart` - Record match events
- Create new `match_history_screen.dart`
- Update `lib/models/player.dart` to store match history

**Testing**:
- Verify highlights are captured correctly
- Test replay functionality
- Check match history persistence

---

## Implementation Order Recommendation

**Recommended order for best incremental improvement**:
1. Task 1: Smarter AI (immediate gameplay improvement)
2. Task 8: Difficulty Balancing (ensure foundation is solid)
3. Task 2: Stamina System (adds depth)
4. Task 5: Momentum System (adds excitement)
5. Task 7: Match Statistics (better feedback)
6. Task 3: Defensive Actions (more player agency)
7. Task 6: Better Animations (polish)
8. Task 4: Advanced Mechanics (complexity)
9. Task 9: Court Effects (optional flavor)
10. Task 10: Match Replay (optional feature)

---

## Notes
- Each task should be tested thoroughly before moving to the next
- Consider user feedback after implementing core features (Tasks 1-5)
- Some tasks may require adjustments to existing balance
- Keep performance in mind - avoid heavy computations during matches
- Maintain the iOS Cupertino design aesthetic throughout

---

**Last Updated**: 2025-10-18
**Total Tasks**: 10
**Completed**: 5
**In Progress**: 0
**Not Started**: 5

---

## Recent Session Summary (2025-10-18)

### Completed Tasks:
1. ✅ **Task 1: Smarter AI with Playstyle** - Opponents now use weighted action selection based on their playstyle
2. ✅ **Task 2: Stamina/Fatigue System** - Performance degrades during match based on stamina
3. ✅ **Task 3: Defensive Actions** - Added steal and block mechanics with risk/reward
4. ✅ **Task 5: Momentum/Streak System** - Hot/cold streaks affect success rates with visual indicators
5. ✅ **Task 7: Match Statistics** - Comprehensive stat tracking (FG%, 3P%, steals, blocks, turnovers)

### Additional Improvements:
- 🎨 **Modernized Navigation Bar**: Larger icons, better colors, active/inactive states
- 📊 **Enhanced Stats Tab**: Renamed from "Match" to "Stats", shows career statistics dashboard
- 🐛 **Fixed Overflow Bugs**: Match result and stats display now scroll properly
- ✨ **UI Polish**: Better spacing, color-coding, visual feedback throughout

### Key Features Added:
- **Playstyle-based AI**: Shooters shoot more, speedsters drive more, etc.
- **Stamina bars**: Visual stamina tracking with color-coded indicators
- **Streak badges**: "🔥 ON FIRE!" and "🧊 COLD" indicators
- **Live stats toggle**: Show/hide detailed match statistics during gameplay
- **Defensive gameplay**: Active defense with steal/block options
- **Performance modifiers**: Fatigue and momentum affect success rates

### Files Modified:
- `lib/screens/match_screen.dart` - Major enhancements (500+ lines added)
- `lib/main.dart` - Modernized navigation bar
- `tasks.md` - Updated with completion status

### Next Recommended Tasks:
1. **Task 8: Difficulty Balancing** - Refine formulas for better gameplay feel (HIGH PRIORITY)
2. **Task 6: Better Animations** - Enhanced visual feedback and messages
3. **Task 4: Advanced Mechanics** - Shot clock, fouls, free throws (COMPLEX)
4. **Task 9: Court Effects** - Court-specific modifiers (OPTIONAL)
5. **Task 10: Match Replay** - Highlights system (OPTIONAL)

### Testing Notes:
- All code compiles successfully (only deprecation warnings)
- Manual testing needed for gameplay balance
- Verify stat tracking accuracy
- Test on different screen sizes
- Check performance with all systems active

