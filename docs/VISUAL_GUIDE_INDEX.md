# Visual Guide Index - Flutter Document Scanner

Quick reference guide to all visual documentation and screen designs.

## 📱 Quick Screen Reference

| # | Screen | Purpose | Key Features | Documentation |
|---|--------|---------|--------------|---------------|
| 1 | **Splash** | App launch | Loading, auto-navigation | [View →](SCREENSHOTS.md#splash-screen) |
| 2 | **Login** | Authentication | Mock credentials, validation | [View →](SCREENSHOTS.md#login-screen) |
| 3 | **Home** | Dashboard | 4-card menu, profile | [View →](SCREENSHOTS.md#home-screen) |
| 4 | **Camera** | Scan docs | Live preview, flash, capture | [View →](SCREENSHOTS.md#camerascanner-screen) |
| 5 | **Preview** | Review page | Zoom, enhance toggle | [View →](SCREENSHOTS.md#page-preview-screen) |
| 6 | **Review** | Manage pages | Reorder, delete, edit | [View →](SCREENSHOTS.md#scan-review-screen) |
| 7 | **Generate** | Create PDF | Metadata form, progress | [View →](SCREENSHOTS.md#pdf-generation-screen) |
| 8 | **Documents** | Browse PDFs | Search, open, share | [View →](SCREENSHOTS.md#documents-screen) |
| 9 | **Queue** | Upload status | Monitor uploads (Phase 5) | [View →](SCREENSHOTS.md#upload-queue-screen) |
| 10 | **Settings** | Configuration | Account, preferences | [View →](SCREENSHOTS.md#settings-screen) |

## 🎨 Design Resources

### Complete Guides
- **[SCREENSHOTS.md](SCREENSHOTS.md)** - Full screen mockups with descriptions
- **[UI_WIREFRAMES.md](UI_WIREFRAMES.md)** - Detailed design specifications

### Quick Links

#### 🎯 For Product Managers
- [User Flows](SCREENSHOTS.md#navigation-flow) - How users navigate
- [Key Capabilities](SCREENSHOTS.md#current-capabilities) - What the app does
- [Design System](SCREENSHOTS.md#design-system) - Visual standards

#### 🎨 For Designers
- [Wireframes](UI_WIREFRAMES.md) - All screens with dimensions
- [Design Tokens](UI_WIREFRAMES.md#design-tokens) - Spacing, colors, typography
- [Component States](UI_WIREFRAMES.md#interaction-states) - Hover, pressed, disabled

#### 💻 For Developers
- [Screen Components](UI_WIREFRAMES.md) - Widget breakdown
- [Layout Specs](UI_WIREFRAMES.md#screen-dimensions--layout) - Exact measurements
- [Animation Guide](UI_WIREFRAMES.md#animation-guidelines) - Duration and easing

#### ♿ For Accessibility
- [Color Contrast](UI_WIREFRAMES.md#accessibility) - WCAG compliance
- [Touch Targets](UI_WIREFRAMES.md#touch-targets) - Minimum sizes
- [Screen Reader](UI_WIREFRAMES.md#screen-reader) - Labels and descriptions

## 📸 Screen Preview Gallery

### Authentication Flow
```
┌────────────┐    ┌────────────┐    ┌────────────┐
│  Splash    │ → │   Login    │ → │    Home    │
│            │    │            │    │            │
│     📄     │    │     👤     │    │   📷 📁   │
│  Loading   │    │  Sign In   │    │   📤 ⚙️   │
└────────────┘    └────────────┘    └────────────┘
```

### Scanning Flow
```
┌────────────┐    ┌────────────┐    ┌────────────┐    ┌────────────┐
│   Camera   │ → │  Preview   │ → │   Review   │ → │  Generate  │
│            │    │            │    │            │    │            │
│    📷      │    │     📄     │    │  📄📄📄   │    │     ✅     │
│  Capture   │    │  Enhance   │    │  Reorder   │    │  Success   │
└────────────┘    └────────────┘    └────────────┘    └────────────┘
```

### Document Management Flow
```
┌────────────┐    ┌────────────┐    ┌────────────┐
│ Documents  │ ⇄ │    Open    │ ⇄ │   Share    │
│            │    │            │    │            │
│  📕📕📕   │    │     📄     │    │     📤     │
│   List     │    │   Viewer   │    │    Send    │
└────────────┘    └────────────┘    └────────────┘
```

## 🔍 Find What You Need

### By User Role

**Admin Users**
- Can access: All features
- Key screens: Home, Camera, Documents, Settings, Upload Queue
- Special features: All management capabilities

**Regular Users**
- Can access: Scanning and document management
- Key screens: Home, Camera, Documents, Settings
- Special features: Personal document library

**Viewers**
- Can access: Document viewing only
- Key screens: Home, Documents
- Special features: View and share (no editing)

### By Task

**"I want to scan a document"**
1. [Home Screen](SCREENSHOTS.md#home-screen) - Tap "Scan Document"
2. [Camera Screen](SCREENSHOTS.md#camerascanner-screen) - Position and capture
3. [Preview Screen](SCREENSHOTS.md#page-preview-screen) - Review and enhance
4. [Review Screen](SCREENSHOTS.md#scan-review-screen) - Manage pages
5. [Generate Screen](SCREENSHOTS.md#pdf-generation-screen) - Create PDF

**"I want to find a document"**
1. [Home Screen](SCREENSHOTS.md#home-screen) - Tap "My Documents"
2. [Documents Screen](SCREENSHOTS.md#documents-screen) - Search or browse
3. Open or share as needed

**"I want to configure the app"**
1. [Home Screen](SCREENSHOTS.md#home-screen) - Tap "Settings"
2. [Settings Screen](SCREENSHOTS.md#settings-screen) - Adjust preferences

## 🎨 Visual Design Elements

### Color Palette
- **Primary**: Blue (Material 3 default)
- **Success**: Green (#4CAF50)
- **Error**: Red (#F44336)
- **Warning**: Orange (#FF9800)
- **Surface**: White/Dark (theme dependent)
- **Background**: Gray variants

### Typography
- **Display**: 57sp - App titles
- **Headline**: 32sp - Section headers
- **Title**: 22sp - Card headers
- **Body**: 16sp - Regular text
- **Label**: 14sp - Buttons
- **Caption**: 12sp - Metadata

### Icons
All screens use Material Icons from Google's icon library:
- 📷 Camera - camera_alt
- 📄 Document - description
- 📁 Folder - folder
- 📤 Upload - cloud_upload
- ⚙️ Settings - settings
- 👤 User - person
- 🔍 Search - search
- 🗑️ Delete - delete
- ↗️ Share - share

### Layout Grid
- **Mobile**: 4dp base unit
- **Padding**: 16dp standard
- **Margins**: 16dp between cards
- **Gutter**: 8dp between elements
- **Safe Area**: Respects system UI

## 📐 Measurements

### Screen Dimensions
- **Status Bar**: 24dp
- **App Bar**: 56dp
- **Tab Bar**: 48dp
- **Bottom Nav**: 56dp
- **FAB**: 56dp diameter
- **List Item**: 72dp height
- **Card**: 120-160dp height

### Touch Targets
- **Minimum**: 48x48dp (WCAG)
- **Recommended**: 56x56dp
- **Icon Button**: 48x48dp
- **FAB**: 56x56dp
- **Chip**: 32dp height

### Spacing
- **xxs**: 4dp
- **xs**: 8dp
- **sm**: 12dp
- **md**: 16dp
- **lg**: 24dp
- **xl**: 32dp
- **xxl**: 48dp

## 🎬 Animations

### Transitions
- **Page Transitions**: 300ms slide
- **Dialog**: 200ms fade + scale
- **Bottom Sheet**: 250ms slide up
- **Snackbar**: 150ms slide up
- **Menu**: 200ms fade + scale

### Interactions
- **Button Press**: 100ms scale down
- **Ripple**: 300ms expand + fade
- **Drag**: Follow gesture
- **Scroll**: Native platform
- **Swipe**: 200ms slide

## 📱 Responsive Design

### Breakpoints
- **Mobile**: < 600dp
- **Tablet**: 600-840dp
- **Desktop**: > 840dp

### Layout Adaptations
- **Mobile**: Single column, bottom nav
- **Tablet**: Grid layout, side rail
- **Desktop**: Multi-column, persistent drawer

## ♿ Accessibility Features

### Implemented
- ✅ Semantic labels on all buttons
- ✅ Color contrast meets WCAG AA
- ✅ Touch targets min 48dp
- ✅ Text scales with system settings
- ✅ Error messages with icons

### Planned
- 🔄 Screen reader optimization
- 🔄 Keyboard navigation
- 🔄 Voice commands
- 🔄 High contrast mode
- 🔄 Reduced motion option

## 🔗 External Resources

### Flutter Documentation
- [Material 3 Design](https://m3.material.io/)
- [Flutter Widgets](https://docs.flutter.dev/ui/widgets)
- [Accessibility](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)

### Design Guidelines
- [Material Design](https://material.io/design)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [WCAG 2.1](https://www.w3.org/WAI/WCAG21/quickref/)

## 📝 Notes for Implementation

### With Flutter SDK
When Flutter SDK is available, generate actual screenshots:
```bash
flutter run
# Use Flutter DevTools or device screenshot
```

### Automated Screenshots
Use integration tests to capture all screens:
```bash
flutter test integration_test/screenshot_test.dart
```

### Platform Variations
- Android: Material Design
- iOS: Cupertino (future)
- Web: Responsive design (future)

---

**Last Updated**: March 8, 2026
**Version**: 1.0.0
**Status**: Visual documentation complete (60% MVP implemented)

For code implementation details, see [Implementation Status](IMPLEMENTATION_STATUS.md).
