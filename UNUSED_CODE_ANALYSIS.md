# Milap App - Unused Code Analysis Report

**Analysis Date:** February 3, 2026  
**Status:** Complete analysis with safe removal recommendations

---

## 1. UNUSED SCREENS (Never imported in root_screen.dart)

### 1.1 PlaceholderScreen ❌
- **File Path:** [lib/screens/placeholder_screen.dart](lib/screens/placeholder_screen.dart)
- **What's Unused:** Entire screen file
- **Why It's Unnecessary:** 
  - Generic placeholder component with "Under Construction" message
  - Not imported or used anywhere in the app
  - Not referenced in AppScreen enum
  - No navigation paths lead to this screen
  - Appears to be leftover development placeholder
- **Safe to Remove:** ✅ **YES** - Completely safe to remove
- **Impact:** Zero impact - no active features depend on it

### 1.2 LiveStreamingScreen ❌
- **File Path:** [lib/screens/live_streaming_screen.dart](lib/screens/live_streaming_screen.dart)
- **What's Unused:** Entire screen file
- **Why It's Unnecessary:**
  - Implements live streaming functionality with mock viewer count and comments
  - Not imported or used in any active flow
  - Not referenced in AppScreen enum
  - No navigation paths lead to this screen
  - Appears to be incomplete/abandoned feature
- **Safe to Remove:** ✅ **YES** - Completely safe to remove
- **Dependencies:** No other screens or services depend on this
- **Note:** Live streaming functionality is mentioned in IMPLEMENTATION_GUIDE.md as being in active_room_screen.dart instead

### 1.3 NearbyScreen ❌
- **File Path:** [lib/screens/nearby_screen.dart](lib/screens/nearby_screen.dart)
- **What's Unused:** Entire screen file
- **Why It's Unnecessary:**
  - Implements "nearby users" feature with map/list view modes
  - Already removed from navigation according to PROJECT_UPDATE_SUMMARY.md
  - Not imported in root_screen.dart
  - Not referenced in AppScreen enum
  - Not part of any active feature flow
- **Safe to Remove:** ✅ **YES** - Already documented as removed in project summary
- **Note:** PROJECT_UPDATE_SUMMARY.md confirms this was intentionally removed in Task 1

---

## 2. UNUSED MODEL FIELDS

### 2.1 Partner2 Fields (Couple Support) - ⚠️ CAUTION
- **File Path:** [lib/models/user_profile.dart](lib/models/user_profile.dart)
- **Fields:**
  - `partner2Name`
  - `partner2Age`
  - `partner2Gender`
  - `partner2Dob`
- **What's Unused:** 
  - These fields are defined in UserProfile model
  - Present in constructor and copyWith method
  - **NOT used anywhere in screens**
  - Appears to support couple profiles (isCouple exists but partner fields aren't used)
- **Why It's Unnecessary:** 
  - App shows individual profiles, not couple information in UI
  - No screens access or display these fields
  - Only mentioned in model but never rendered
- **Safe to Remove:** ⚠️ **CONDITIONAL** 
  - Safe to remove IF couple profiles aren't a future requirement
  - Backend may still need these fields
  - Keep if planning multi-person profile support
- **Recommendation:** Keep for now (future feature support)

### 2.2 Unused Profile Fields - ⚠️ CAUTION
- **File Path:** [lib/models/user_profile.dart](lib/models/user_profile.dart)
- **Fields:**
  - `videos` - Defined but rarely used (only in edit_profile and public profile view)
  - `socialLinks` - Defined but never accessed in any screen
  - `matchRequests` - Defined but never displayed or accessed
  - `profileVisitors` - Defined but only used in hookup_mode_screen for mock data
- **Current Usage:**
  - `videos`: Used in [edit_profile_screen.dart](lib/screens/edit_profile_screen.dart#L172), [profile_screen.dart](lib/screens/profile_screen.dart#L58), [public_profile_view.dart](lib/screens/public_profile_view.dart#L48)
  - `socialLinks`: **NEVER USED** ❌
  - `matchRequests`: **NEVER USED** ❌
  - `profileVisitors`: Minimal use only in [hookup_mode_screen.dart](lib/screens/hookup_mode_screen.dart#L55) for mock data
- **Safe to Remove:** 
  - `socialLinks`: ✅ **YES** - Completely unused
  - `matchRequests`: ✅ **YES** - Never accessed
  - `profileVisitors`: ⚠️ **PARTIAL** - Only used for mock data in one screen
  - `videos`: ⚠️ **NO** - Used in multiple screens
- **Recommendation:** Remove `socialLinks` and `matchRequests` safely

---

## 3. UNUSED SERVICES/FUNCTIONS

### 3.1 MockDataService Instance Methods ⚠️
- **File Path:** [lib/services/mock_data_service.dart](lib/services/mock_data_service.dart)
- **Unused Methods:**
  - `getSocialFeed()` - **NEVER CALLED** (static `mockProfiles` is used instead)
  - `getMockEvents()` - Instance method, but could use static getter directly
  - `getSentRequests()` - Instance method, but rarely used
- **What's Unnecessary:**
  - These are instance method wrappers around static getters
  - Code uses `MockDataService().getMockEvents()` instead of direct static access
  - Inconsistent pattern: some code uses static `MockDataService.mockProfiles`, others use `MockDataService().getMockEvents()`
- **Safe to Remove:** ⚠️ **PARTIAL** - Safe to consolidate
- **Recommendation:** 
  - Make all properties consistent (either static getters or instance methods)
  - Or use `getSocialFeed()` consistently instead of mixing patterns

### 3.2 Duplicate Screenshot Detection Logic ⚠️
- **File Path:** [lib/services/screenshot_detection_service.dart](lib/services/screenshot_detection_service.dart)
- **Issue:**
  - Multiple methods that could be consolidated:
    - `getWarningCount()` - Returns 0, never updated
    - `isAccountSuspended()` - Returns false, never updated
    - `hasExceededScreenshotLimit()` - Returns warning count > 5
  - These are mock implementations with no persistence
- **Safe to Remove:** ⚠️ **NO** - These are framework methods
- **Recommendation:** Keep as-is (mocked pending backend integration)

---

## 4. UNUSED IMPORTS IN FILES

### 4.1 Truly Unused Imports

None found in active screens. All imports in frequently used screens are referenced.

### 4.2 Potentially Redundant Imports
- **File Path:** [lib/screens/root_screen.dart](lib/screens/root_screen.dart)
- **Import:** `import '../services/mock_data_service.dart';` if considering removal
- **Currently Used:** Not imported, so N/A
- **Note:** Various screens import `mock_data_service` and use it appropriately

---

## 5. UNUSED METHODS IN SCREENS

### 5.1 Placeholder Methods (Low Priority)

#### Dashboard.onViewProfile() ❌
- **File Path:** [lib/screens/dashboard.dart](lib/screens/dashboard.dart#L80)
- **Method:** `void _navigateToPublicProfile(UserProfile profile)`
- **Status:** Actually **USED** - Called in [dashboard.dart](lib/screens/dashboard.dart#L198)
- **Verdict:** ✅ Used, keep it

#### PlaceholderScreen Methods ❌
- **File Path:** [lib/screens/placeholder_screen.dart](lib/screens/placeholder_screen.dart)
- **Methods:** All methods in this screen
- **Why Unused:** Screen itself is unused
- **Safe to Remove:** ✅ **YES** - Remove entire file

#### LiveStreamingScreen Methods ❌
- **File Path:** [lib/screens/live_streaming_screen.dart](lib/screens/live_streaming_screen.dart)
- **Methods:** `_startSimulation()`, comment handling logic
- **Why Unused:** Screen itself is unused
- **Safe to Remove:** ✅ **YES** - Remove entire file

---

## SUMMARY TABLE

| Item | Type | Safe to Remove | Priority | Impact |
|------|------|---|----------|--------|
| PlaceholderScreen | Screen File | ✅ YES | HIGH | Zero impact |
| LiveStreamingScreen | Screen File | ✅ YES | HIGH | Zero impact |
| NearbyScreen | Screen File | ✅ YES | MEDIUM | Already documented as removed |
| `socialLinks` field | Model Field | ✅ YES | LOW | No usage |
| `matchRequests` field | Model Field | ✅ YES | LOW | No usage |
| `partner2Name/Age/Gender/Dob` | Model Fields | ⚠️ KEEP | LOW | Couple support feature |
| `getSocialFeed()` | Service Method | ⚠️ REFACTOR | LOW | Can consolidate pattern |
| `getMockEvents()` | Service Method | ⚠️ REFACTOR | LOW | Can consolidate pattern |

---

## RECOMMENDATIONS

### Immediate Removals (Safe & High Impact)
1. **Delete** [lib/screens/placeholder_screen.dart](lib/screens/placeholder_screen.dart)
2. **Delete** [lib/screens/live_streaming_screen.dart](lib/screens/live_streaming_screen.dart)
3. **Delete** [lib/screens/nearby_screen.dart](lib/screens/nearby_screen.dart)
4. **Remove** `socialLinks` field from UserProfile model
5. **Remove** `matchRequests` field from UserProfile model

### Keep (Future Features or Backend Integration)
- Partner2 fields (couple support may be needed)
- All service mock methods (pending real backend)
- Screenshot detection framework methods (mocked, awaiting real implementation)

### Refactor (Nice to Have)
- Consolidate MockDataService access pattern (use static getters consistently)
- Make screenshot detection service methods persistent (add storage layer)

---

## VERIFICATION

### What's Confirmed As Core & Safe
✅ Dashboard - Core feature, fully used  
✅ Messages/Chat - Core feature, fully used  
✅ Profile - Core feature, fully used  
✅ Events - Core feature, fully used  
✅ Rooms - Core feature, fully used  
✅ Wallet/Hearts - Core feature, fully used  
✅ All service classes - Framework ready for backend  

### What's Confirmed As Unused
❌ PlaceholderScreen - No navigation path  
❌ LiveStreamingScreen - No navigation path  
❌ NearbyScreen - Already documented as removed  
❌ socialLinks/matchRequests - No UI access points  

---

**Safe Removal Total:** 3 screen files + 2 model fields = ~600 lines of code  
**Recommendation:** Proceed with immediate removals in priority order
