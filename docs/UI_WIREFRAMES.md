# UI/UX Wireframes - Flutter Document Scanner

This document provides detailed wireframes and user interface descriptions for all screens in the Flutter Document Scanner application.

## Screen Dimensions & Layout

All screens follow Material 3 design guidelines with:
- **Status Bar**: 24dp height
- **App Bar**: 56dp height
- **Bottom Navigation**: 56dp height
- **FAB**: 56dp diameter
- **Safe Area**: Respects device notches and system UI

---

## 1. Splash Screen

**Purpose**: App initialization and authentication check
**Duration**: 1-2 seconds
**Navigation**: Auto-navigates to Login or Home

```
╔═════════════════════════════════════╗
║                                     ║
║                                     ║
║                                     ║
║              ┌─────┐                ║
║              │     │                ║
║              │ 📄  │                ║
║              │     │                ║
║              └─────┘                ║
║                                     ║
║        Document Scanner             ║
║                                     ║
║           ⚪ ⚪ ⚪                   ║
║          Loading...                 ║
║                                     ║
║                                     ║
║                                     ║
║         Version 1.0.0               ║
║                                     ║
╚═════════════════════════════════════╝
```

**Components**:
- App icon (centered, large)
- App name (typography: headline)
- Loading indicator (3 dots animation)
- Version number (footer, small text)

---

## 2. Login Screen

**Purpose**: User authentication
**Input Validation**: Real-time
**Mock Mode**: Enabled by default

```
╔═════════════════════════════════════╗
║ ← Login                             ║
╟─────────────────────────────────────╢
║                                     ║
║                                     ║
║            ┌─────────┐              ║
║            │    👤   │              ║
║            └─────────┘              ║
║                                     ║
║          Welcome Back!              ║
║     Sign in to continue             ║
║                                     ║
║  ╔═══════════════════════════════╗  ║
║  ║ 👤 Username                   ║  ║
║  ╚═══════════════════════════════╝  ║
║                                     ║
║  ╔═══════════════════════════════╗  ║
║  ║ 🔒 ••••••••                   ║  ║
║  ╚═══════════════════════════════╝  ║
║                                     ║
║  ┌─────────────────────────────┐   ║
║  │                             │   ║
║  │       🔐  LOGIN             │   ║
║  │                             │   ║
║  └─────────────────────────────┘   ║
║                                     ║
║  ┌───────────────────────────────┐ ║
║  │ ℹ️  Test Credentials:        │ ║
║  │                               │ ║
║  │ Admin:  admin / admin123     │ ║
║  │ User:   user / user123       │ ║
║  │ Viewer: viewer / viewer123   │ ║
║  └───────────────────────────────┘ ║
║                                     ║
╚═════════════════════════════════════╝
```

**Form Fields**:
- Username (text input, required)
- Password (secure input, required, toggle visibility)

**States**:
- Empty (show placeholder)
- Filled (show value)
- Error (red border, error message below)
- Loading (button shows spinner)

**Validation**:
- Username: min 3 characters
- Password: min 6 characters
- Both fields required

---

## 3. Home Screen

**Purpose**: Main dashboard and navigation hub
**Layout**: Profile card + 2x2 grid menu

```
╔═════════════════════════════════════╗
║ Document Scanner              ⚙️    ║
╟─────────────────────────────────────╢
║                                     ║
║  ┌─────────────────────────────┐   ║
║  │        ┌─────────┐           │   ║
║  │        │   👤    │           │   ║
║  │        └─────────┘           │   ║
║  │                              │   ║
║  │        John Doe              │   ║
║  │        ADMIN                 │   ║
║  │                              │   ║
║  └─────────────────────────────┘   ║
║                                     ║
║  ┌─────────────┐ ┌─────────────┐   ║
║  │             │ │             │   ║
║  │     📷      │ │     📁      │   ║
║  │             │ │             │   ║
║  │    Scan     │ │     My      │   ║
║  │  Document   │ │ Documents   │   ║
║  │             │ │             │   ║
║  └─────────────┘ └─────────────┘   ║
║                                     ║
║  ┌─────────────┐ ┌─────────────┐   ║
║  │             │ │             │   ║
║  │     📤      │ │     ℹ️      │   ║
║  │             │ │             │   ║
║  │   Upload    │ │  Settings   │   ║
║  │    Queue    │ │             │   ║
║  │             │ │             │   ║
║  └─────────────┘ └─────────────┘   ║
║                                     ║
╚═════════════════════════════════════╝
```

**Components**:

1. **Profile Card**:
   - Avatar (circular, 80dp)
   - Username (headline)
   - Role badge (caption, uppercase)

2. **Menu Grid** (2x2):
   - Each card: 160x160dp
   - Icon: 48dp, centered
   - Label: 2 lines, centered
   - Ripple effect on tap

**Interaction**:
- Tap any card to navigate
- Settings icon in app bar
- Card elevation increases on hover/press

---

## 4. Camera/Scanner Screen

**Purpose**: Capture document photos
**Layout**: Fullscreen camera with overlay controls

```
╔═════════════════════════════════════╗
║ ← Scan Document              📚 2   ║
╟─────────────────────────────────────╢
║ ╔═══════════════════════════════╗   ║
║ ║ Position the document within  ║   ║
║ ║         the frame             ║   ║
║ ╚═══════════════════════════════╝   ║
║                                     ║
║  ┌─┐                         ┌─┐   ║
║  │ │                         │ │   ║
║  │ │                         │ │   ║
║  └─┘                         └─┘   ║
║                                     ║
║                                     ║
║       CAMERA PREVIEW AREA           ║
║       (Live feed from camera)       ║
║         Document visible            ║
║                                     ║
║                                     ║
║  ┌─┐                         ┌─┐   ║
║  │ │                         │ │   ║
║  │ │                         │ │   ║
║  └─┘                         └─┘   ║
║                                     ║
║ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ║
║                                     ║
║     💡         ⚪         🖼️       ║
║   Flash      Capture    Gallery    ║
║                                     ║
╚═════════════════════════════════════╝
```

**Overlay Elements**:

1. **Corner Guides** (4 corners):
   - L-shaped white brackets
   - 40dp margin from edges
   - 30dp length per line
   - 2dp stroke width
   - Semi-transparent overlay

2. **Top Bar** (gradient overlay):
   - Back button
   - Title "Scan Document"
   - Page counter badge (if pages > 0)

3. **Bottom Controls** (gradient overlay):
   - Flash button (left)
   - Capture button (center, 72dp)
   - Gallery button (right)

**Camera States**:
- Initializing (loading spinner)
- Ready (show controls)
- Capturing (freeze frame, flash white)
- Error (show error message, retry button)

**Capture Button States**:
- Default: White circle with camera icon
- Pressed: Slightly smaller, animated
- Loading: Spinner inside circle

---

## 5. Page Preview Screen

**Purpose**: Review and enhance captured page
**Layout**: Image viewer + enhancement controls

```
╔═════════════════════════════════════╗
║ ← Page 1                       🔄   ║
╟─────────────────────────────────────╢
║                                     ║
║   ╔═══════════════════════════╗     ║
║   ║                           ║     ║
║   ║                           ║     ║
║   ║      CAPTURED IMAGE       ║     ║
║   ║                           ║     ║
║   ║    (Pinch to zoom in)     ║     ║
║   ║                           ║     ║
║   ║                           ║     ║
║   ╚═══════════════════════════╝     ║
║                                     ║
╟─────────────────────────────────────╢
║                                     ║
║  ⚙️ Enhancement Options             ║
║                                     ║
║  ┌─────────────────────────────┐   ║
║  │ ☑️ Auto-Enhance              │   ║
║  │                             │   ║
║  │ Automatically optimize      │   ║
║  │ brightness, contrast, and   │   ║
║  │ sharpness for best results  │   ║
║  └─────────────────────────────┘   ║
║                                     ║
║  ┌───────────┐  ┌───────────────┐  ║
║  │           │  │               │  ║
║  │ + Add     │  │  ✓ Done      │  ║
║  │   More    │  │               │  ║
║  │   Pages   │  │               │  ║
║  │           │  │               │  ║
║  └───────────┘  └───────────────┘  ║
║                                     ║
╚═════════════════════════════════════╝
```

**Image Viewer**:
- InteractiveViewer widget
- Min scale: 0.5x
- Max scale: 4.0x
- Double-tap to zoom in/out
- Pan gesture when zoomed

**Enhancement Panel**:
- Switch tile for auto-enhance
- Descriptive subtitle
- Toggle state persists

**Action Buttons**:
- **Add More Pages**: Outlined button
- **Done**: Elevated button (primary)
- Both full-width on mobile
- Side-by-side on tablet

---

## 6. Scan Review Screen

**Purpose**: Manage all pages before PDF generation
**Layout**: Reorderable list + bottom action

```
╔═════════════════════════════════════╗
║ ← 3 Pages                      📷   ║
╟─────────────────────────────────────╢
║                                     ║
║ ┌─────────────────────────────────┐ ║
║ │ ☰ ┌───┐  Page 1          🗑️   │ ║
║ │   │   │                        │ ║
║ │   │ 📄│  Enhanced              │ ║
║ │   │   │  10:30 AM              │ ║
║ │   └───┘                        │ ║
║ └─────────────────────────────────┘ ║
║                                     ║
║ ┌─────────────────────────────────┐ ║
║ │ ☰ ┌───┐  Page 2          🗑️   │ ║
║ │   │   │                        │ ║
║ │   │ 📄│  Enhanced              │ ║
║ │   │   │  10:31 AM              │ ║
║ │   └───┘                        │ ║
║ └─────────────────────────────────┘ ║
║                                     ║
║ ┌─────────────────────────────────┐ ║
║ │ ☰ ┌───┐  Page 3          🗑️   │ ║
║ │   │   │                        │ ║
║ │   │ 📄│  Original              │ ║
║ │   │   │  10:32 AM              │ ║
║ │   └───┘                        │ ║
║ └─────────────────────────────────┘ ║
║                                     ║
╟─────────────────────────────────────╢
║ ┌─────────────────────────────────┐ ║
║ │                                 │ ║
║ │     📄  Generate PDF            │ ║
║ │                                 │ ║
║ └─────────────────────────────────┘ ║
╚═════════════════════════════════════╝
```

**List Item Components**:
- **Drag Handle**: ☰ icon (left, 24dp)
- **Thumbnail**: 80x100dp, bordered
- **Info Column**:
  - Page number (medium, bold)
  - Status (small, gray)
  - Time (small, gray)
- **Delete Button**: Icon button (right)

**Interactions**:
- Tap item: Show full-screen dialog
- Long-press + drag: Reorder pages
- Tap delete: Show confirmation dialog
- Tap app bar camera: Add more pages

**Bottom Button**:
- Fixed at bottom (sticky)
- Full-width with padding
- Elevated, primary color
- Disabled if loading

---

## 7. PDF Generation Screen

**Purpose**: Add metadata and create PDF
**States**: Form → Progress → Success

### State 1: Form Input

```
╔═════════════════════════════════════╗
║ ← Generate PDF                      ║
╟─────────────────────────────────────╢
║                                     ║
║  ┌─────────────────────────────┐   ║
║  │         ┌───────┐            │   ║
║  │         │       │            │   ║
║  │         │  📄   │            │   ║
║  │         │       │            │   ║
║  │         └───────┘            │   ║
║  │                              │   ║
║  │   Creating PDF with 3 pages  │   ║
║  │                              │   ║
║  └─────────────────────────────┘   ║
║                                     ║
║  ╔═══════════════════════════════╗  ║
║  ║ 📝 Document Title *           ║  ║
║  ║ Monthly Report                ║  ║
║  ╚═══════════════════════════════╝  ║
║                                     ║
║  ╔═══════════════════════════════╗  ║
║  ║ 📁 Category            ▼      ║  ║
║  ║ Invoice                       ║  ║
║  ╚═══════════════════════════════╝  ║
║                                     ║
║  ╔═══════════════════════════════╗  ║
║  ║ 🏷️  Tags (comma-separated)   ║  ║
║  ║ invoice, 2024, monthly        ║  ║
║  ╚═══════════════════════════════╝  ║
║                                     ║
║  ┌─────────────────────────────┐   ║
║  │                             │   ║
║  │    ✓  Generate PDF          │   ║
║  │                             │   ║
║  └─────────────────────────────┘   ║
║                                     ║
╚═════════════════════════════════════╝
```

### State 2: Processing

```
╔═════════════════════════════════════╗
║ ← Generate PDF                      ║
╟─────────────────────────────────────╢
║                                     ║
║                                     ║
║                                     ║
║             ⚪ ⚪ ⚪                 ║
║                                     ║
║        Generating PDF...            ║
║                                     ║
║  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░      ║
║                                     ║
║              75%                    ║
║                                     ║
║                                     ║
║                                     ║
║                                     ║
╚═════════════════════════════════════╝
```

### State 3: Success

```
╔═════════════════════════════════════╗
║ ← Generate PDF                      ║
╟─────────────────────────────────────╢
║                                     ║
║                                     ║
║           ┌─────────┐               ║
║           │    ✅   │               ║
║           └─────────┘               ║
║                                     ║
║      PDF Generated Successfully!    ║
║                                     ║
║  ┌─────────────────────────────┐   ║
║  │                             │   ║
║  │ Title:    Monthly Report    │   ║
║  │ ─────────────────────────   │   ║
║  │ Pages:    3                 │   ║
║  │ ─────────────────────────   │   ║
║  │ Size:     2.5 MB            │   ║
║  │ ─────────────────────────   │   ║
║  │ Category: Invoice           │   ║
║  │                             │   ║
║  └─────────────────────────────┘   ║
║                                     ║
║  ┌──────────┐      ┌──────────┐    ║
║  │          │      │          │    ║
║  │  Share   │      │   Open   │    ║
║  │          │      │          │    ║
║  └──────────┘      └──────────┘    ║
║                                     ║
║            Done                     ║
║                                     ║
╚═════════════════════════════════════╝
```

**Form Validation**:
- Title: Required, min 1 character
- Category: Optional, dropdown selection
- Tags: Optional, comma-separated

**Progress Tracking**:
- Linear progress bar
- Percentage display
- Cannot be cancelled

**Success Actions**:
- Share: Opens system share sheet
- Open: Launches PDF in viewer
- Done: Returns to home, clears session

---

## 8. Documents Screen

**Purpose**: Browse and manage saved PDFs
**Layout**: Search bar + scrollable list

```
╔═════════════════════════════════════╗
║ My Documents                    🔄  ║
╟─────────────────────────────────────╢
║                                     ║
║  ╔═══════════════════════════════╗  ║
║  ║ 🔍 Search documents...        ║  ║
║  ╚═══════════════════════════════╝  ║
║                                     ║
║ ┌─────────────────────────────────┐ ║
║ │  ┌───┐                          │ ║
║ │  │   │  Monthly Report      ⋮  │ ║
║ │  │ 📕│                          │ ║
║ │  │   │  3 pages • 2.5 MB        │ ║
║ │  └───┘                          │ ║
║ │        [Invoice]                │ ║
║ └─────────────────────────────────┘ ║
║                                     ║
║ ┌─────────────────────────────────┐ ║
║ │  ┌───┐                          │ ║
║ │  │   │  Contract Document   ⋮  │ ║
║ │  │ 📕│                          │ ║
║ │  │   │  5 pages • 4.2 MB        │ ║
║ │  └───┘                          │ ║
║ │        [Contract]               │ ║
║ └─────────────────────────────────┘ ║
║                                     ║
║ ┌─────────────────────────────────┐ ║
║ │  ┌───┐                          │ ║
║ │  │   │  Receipt 2024        ⋮  │ ║
║ │  │ 📕│                          │ ║
║ │  │   │  1 page • 850 KB         │ ║
║ │  └───┘                          │ ║
║ │        [Receipt]                │ ║
║ └─────────────────────────────────┘ ║
║                                     ║
║                                  ┌─┐║
║                                  │📷│║
║                                  └─┘║
╚═════════════════════════════════════╝
```

### Empty State:

```
╔═════════════════════════════════════╗
║ My Documents                    🔄  ║
╟─────────────────────────────────────╢
║                                     ║
║  ╔═══════════════════════════════╗  ║
║  ║ 🔍 Search documents...        ║  ║
║  ╚═══════════════════════════════╝  ║
║                                     ║
║                                     ║
║             ┌─────┐                 ║
║             │     │                 ║
║             │ 📂  │                 ║
║             │     │                 ║
║             └─────┘                 ║
║                                     ║
║          No Documents               ║
║                                     ║
║     Scan a document to              ║
║         get started                 ║
║                                     ║
║                                     ║
║                                  ┌─┐║
║                                  │📷│║
║                                  └─┘║
╚═════════════════════════════════════╝
```

**Document Card**:
- Icon: PDF icon (48dp, red)
- Title: 1 line, ellipsis overflow
- Meta: Pages + Size (small, gray)
- Category: Chip (optional)
- Menu: PopupMenuButton (⋮)

**Menu Options**:
- Open (launches viewer)
- Share (system share)
- Delete (confirmation dialog)

**Search**:
- Real-time filtering
- Searches title and tags
- Clear button when text entered

---

## 9. Upload Queue Screen

**Purpose**: Monitor document upload status
**Status**: Placeholder (Phase 5 implementation)

```
╔═════════════════════════════════════╗
║ ← Upload Queue                      ║
╟─────────────────────────────────────╢
║                                     ║
║                                     ║
║                                     ║
║             ┌─────┐                 ║
║             │     │                 ║
║             │ 📤  │                 ║
║             │     │                 ║
║             └─────┘                 ║
║                                     ║
║         Upload Queue                ║
║                                     ║
║      Upload management will         ║
║      be available here              ║
║                                     ║
║                                     ║
║                                     ║
║                                     ║
║                                     ║
╚═════════════════════════════════════╝
```

**Planned Features**:
- Queue list with status
- Progress indicators
- Retry buttons
- Clear completed
- Network status

---

## 10. Settings Screen

**Purpose**: App configuration and account
**Layout**: Grouped list with sections

```
╔═════════════════════════════════════╗
║ ← Settings                          ║
╟─────────────────────────────────────╢
║                                     ║
║  Account                            ║
║  ┌─────────────────────────────┐   ║
║  │  ┌───┐                       │   ║
║  │  │ 👤│  John Doe             │   ║
║  │  └───┘  admin@email.com      │   ║
║  │                              │   ║
║  └─────────────────────────────┘   ║
║                                     ║
║  Preferences                        ║
║  ┌─────────────────────────────┐   ║
║  │  🌙  Dark Mode          ⚪   │   ║
║  └─────────────────────────────┘   ║
║  ┌─────────────────────────────┐   ║
║  │  📁  Auto Upload        ⚪   │   ║
║  └─────────────────────────────┘   ║
║                                     ║
║  Storage                            ║
║  ┌─────────────────────────────┐   ║
║  │  🗄️   Clear Cache       →   │   ║
║  └─────────────────────────────┘   ║
║                                     ║
║  ┌─────────────────────────────┐   ║
║  │                             │   ║
║  │      🚪  Logout             │   ║
║  │                             │   ║
║  └─────────────────────────────┘   ║
║                                     ║
╚═════════════════════════════════════╝
```

**Section Headers**:
- Typography: caption, uppercase
- Color: gray
- Padding: 16dp top, 8dp bottom

**List Tiles**:
- Leading icon: 24dp
- Title: body text
- Trailing: Switch or arrow
- Tap ripple effect
- Divider between items

**Logout**:
- Prominent button at bottom
- Confirmation dialog
- Clears all session data
- Returns to login screen

---

## Design Tokens

### Spacing Scale
- **xxs**: 4dp
- **xs**: 8dp
- **sm**: 12dp
- **md**: 16dp
- **lg**: 24dp
- **xl**: 32dp
- **xxl**: 48dp

### Border Radius
- **Small**: 4dp (chips)
- **Medium**: 8dp (cards)
- **Large**: 12dp (buttons)
- **Round**: 999dp (avatars, FAB)

### Elevation
- **Level 0**: 0dp (flat)
- **Level 1**: 1dp (cards at rest)
- **Level 2**: 2dp (cards raised)
- **Level 3**: 4dp (FAB)
- **Level 4**: 8dp (dialogs)

### Typography Scale
- **Display**: 57sp / 64sp line height
- **Headline**: 32sp / 40sp line height
- **Title**: 22sp / 28sp line height
- **Body**: 16sp / 24sp line height
- **Label**: 14sp / 20sp line height
- **Caption**: 12sp / 16sp line height

### Iconography
- **Small**: 16dp
- **Medium**: 24dp
- **Large**: 32dp
- **XLarge**: 48dp

---

## Interaction States

### Buttons
- **Default**: Base color, elevation 1
- **Hover**: Slightly darker, elevation 2
- **Pressed**: Much darker, elevation 0
- **Disabled**: Gray, no elevation
- **Loading**: Spinner, disabled

### List Items
- **Default**: White background
- **Hover**: Light gray background
- **Pressed**: Darker gray background
- **Selected**: Primary color tint
- **Disabled**: Gray text, no interaction

### Input Fields
- **Default**: Gray border
- **Focus**: Primary color border, thick
- **Error**: Red border, error text below
- **Disabled**: Gray background, gray text
- **Filled**: Primary color hint

---

## Accessibility

### Color Contrast
- Text on background: 4.5:1 minimum
- Large text: 3:1 minimum
- Interactive elements: 3:1 minimum

### Touch Targets
- Minimum: 48x48dp
- Recommended: 56x56dp
- Spacing: 8dp between targets

### Screen Reader
- All interactive elements labeled
- Image descriptions provided
- State changes announced
- Navigation hints included

### Keyboard Navigation
- Tab order logical
- Focus indicators visible
- Shortcuts for common actions
- Escape to dismiss

---

## Animation Guidelines

### Duration
- **Quick**: 100ms (state changes)
- **Normal**: 200ms (transitions)
- **Slow**: 300ms (page changes)

### Easing
- **Standard**: Cubic bezier for most
- **Decelerate**: Entering screen
- **Accelerate**: Exiting screen
- **Sharp**: Attention-grabbing

### Motion
- Fade in/out for overlays
- Slide for navigation
- Scale for emphasis
- Rotate for loading

---

This wireframe document provides complete visual specifications for implementing or understanding the Flutter Document Scanner application's user interface.
