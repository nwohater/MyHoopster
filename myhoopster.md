# MyHoopster - Basketball Park Simulator
## Product Requirements Document (PRD)

### 🏀 Project Overview
MyHoopster is a mobile basketball park simulator built with Flutter where players create and train their basketball character to compete in 1v1 matches across various iconic streetball courts. The game combines RPG-style character progression with basketball gameplay mechanics.

### 🎯 Core Vision
Create an engaging basketball simulation that captures the essence of streetball culture, allowing players to build their reputation from neighborhood courts to legendary venues like Rucker Park and Venice Beach.

### 📱 Current Implementation Status

#### ✅ Completed Features
- **Player Creation & Management**
  - Character creation with customizable name
  - RPG-style attribute system (Speed, Shooting, Dribbling, Defense, Stamina)
  - Level progression with experience points
  - Skill point allocation system
  - Energy management system

- **Training System**
  - 5 different training drills (Shooting, Dribbling, Speed, Defense, Cardio)
  - Energy-based training costs
  - Experience rewards with random bonuses
  - Attribute improvement mechanics

- **Park & Opponent System**
  - 4 iconic basketball courts (Neighborhood, Downtown, Venice Beach, Rucker Park)
  - Progressive difficulty with level/reputation requirements
  - 12 unique opponents with distinct playstyles and attributes
  - Reward system (coins, XP, reputation)

- **Match System**
  - Real-time 1v1 basketball gameplay
  - Turn-based action system (Shoot, Drive, Trick)
  - Attribute-based success calculations
  - Score tracking and match results
  - Animated feedback system

- **UI/UX**
  - iOS-style Cupertino design
  - 5-tab navigation (Home, Player, Training, Parks, Match)
  - Responsive layouts with proper state management
  - Local data persistence with SharedPreferences

### 🚀 Planned Features & TODOs

#### 🔥 High Priority TODOs

##### 1. Supabase Integration (Online Features)
- [ ] **Database Schema Design**
  - Player profiles table
  - Match history table
  - Leaderboards table
  - Tournament brackets table
- [ ] **Authentication System**
  - User registration/login
  - Social authentication (Google, Apple)
  - Guest mode with account linking
- [ ] **Online Multiplayer**
  - Real-time 1v1 matches against other players
  - Matchmaking system based on skill level
  - Connection handling and reconnection logic
- [ ] **Cloud Save System**
  - Sync player progress across devices
  - Backup and restore functionality
  - Conflict resolution for offline/online data

##### 2. Enhanced Gameplay Mechanics
- [ ] **Advanced Match System**
  - Shot clock implementation
  - Fatigue system affecting performance
  - Special moves and combos
  - Defensive actions (steal, block)
  - Foul system and free throws
- [ ] **Equipment System**
  - Shoes with stat bonuses
  - Basketball selection
  - Clothing/style customization
  - Equipment durability and upgrades
- [ ] **Weather & Court Conditions**
  - Dynamic weather affecting gameplay
  - Court surface types (indoor/outdoor)
  - Time of day variations

##### 3. Progression & Monetization
- [ ] **Enhanced Progression**
  - Player archetypes/builds (Shooter, Slasher, Defender, etc.)
  - Badge system for achievements
  - Prestige system for max-level players
  - Seasonal content and challenges
- [ ] **Economy System**
  - Premium currency (gems/tokens)
  - Daily rewards and login bonuses
  - Tournament entry fees and prizes
  - Equipment marketplace
- [ ] **Social Features**
  - Friend system and challenges
  - Crew/team creation
  - Chat system with moderation
  - Player profiles and stats sharing

#### 🎨 Medium Priority TODOs

##### 4. Audio & Visual Enhancements
- [ ] **Sound System**
  - Basketball sound effects (dribbling, shooting, crowd)
  - Background music for different courts
  - Voice lines for opponents
  - Audio settings and controls
- [ ] **Visual Improvements**
  - 3D court visualization
  - Player avatar customization
  - Particle effects for successful shots
  - Court-specific visual themes
  - Improved animations and transitions

##### 5. Game Modes & Content
- [ ] **Tournament System**
  - Single-elimination brackets
  - Round-robin leagues
  - Seasonal tournaments with special rewards
  - AI and player tournaments
- [ ] **Career Mode**
  - Story-driven progression
  - Rival characters and storylines
  - Cutscenes and dialogue
  - Multiple ending paths
- [ ] **Mini-Games**
  - Free throw contest
  - 3-point shootout
  - Dribbling challenges
  - Horse game mode

##### 6. Analytics & Performance
- [ ] **Analytics Integration**
  - Player behavior tracking
  - Match statistics and heatmaps
  - Retention and engagement metrics
  - A/B testing framework
- [ ] **Performance Optimization**
  - Memory usage optimization
  - Battery life improvements
  - Loading time reduction
  - Offline mode enhancements

#### 🔧 Technical TODOs

##### 7. Code Quality & Architecture
- [ ] **State Management Improvements**
  - Migrate from Provider to Riverpod/Bloc
  - Better separation of concerns
  - Improved error handling
  - Unit and integration tests
- [ ] **API Layer**
  - RESTful API design
  - GraphQL integration consideration
  - Caching strategies
  - Rate limiting and security
- [ ] **Security & Privacy**
  - Data encryption
  - GDPR compliance
  - Anti-cheat measures
  - Secure authentication flows

##### 8. Platform & Distribution
- [ ] **Multi-Platform Support**
  - Android optimization
  - Web version consideration
  - Desktop version (Windows/macOS)
  - Cross-platform save synchronization
- [ ] **App Store Optimization**
  - Screenshots and app store assets
  - Localization for multiple languages
  - App store compliance
  - Marketing materials

### 🎮 Game Balance & Design Notes

#### Current Balance Issues
- Training costs vs. rewards need adjustment
- Opponent difficulty scaling could be smoother
- Energy regeneration rate may be too slow
- Coin economy needs balancing for equipment system

#### Design Considerations
- Maintain authentic streetball culture and atmosphere
- Ensure progression feels rewarding but not grindy
- Balance competitive elements with casual accessibility
- Consider different player motivations (collectors, competitors, story-driven)

### 📊 Success Metrics
- Daily Active Users (DAU)
- Session length and frequency
- Player retention (1-day, 7-day, 30-day)
- In-app purchase conversion rates
- Match completion rates
- Social feature engagement

### 🛠 Technology Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL, Auth, Realtime)
- **State Management**: Provider (planned migration to Riverpod)
- **Local Storage**: SharedPreferences
- **Design System**: Cupertino (iOS-style)

### 📅 Development Roadmap

#### Phase 1: Foundation (Current)
- ✅ Core gameplay mechanics
- ✅ Basic progression system
- ✅ Local data persistence

#### Phase 2: Online Integration (Next 2-3 months)
- 🔄 Supabase backend setup
- 🔄 User authentication
- 🔄 Cloud save system
- 🔄 Basic multiplayer

#### Phase 3: Content & Polish (3-6 months)
- 🔄 Enhanced gameplay mechanics
- 🔄 Audio/visual improvements
- 🔄 Tournament system
- 🔄 Social features

#### Phase 4: Growth & Monetization (6+ months)
- 🔄 Advanced features
- 🔄 Platform expansion
- 🔄 Marketing campaigns
- 🔄 Community building

---

*This PRD is a living document that will be updated as the project evolves and new requirements emerge.*
