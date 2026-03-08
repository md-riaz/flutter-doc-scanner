# Quick Visual Reference - All Screens at a Glance

Visual preview of all 10 screens in the Flutter Document Scanner app. For detailed views, see [SCREENSHOTS.md](SCREENSHOTS.md).

---

## 1. SPLASH SCREEN
```
╔═══════════════════╗
║                   ║
║                   ║
║       📄          ║
║  Document Scanner ║
║                   ║
║   ⚪ Loading...   ║
║                   ║
║   Version 1.0.0   ║
╚═══════════════════╝
```
**Purpose**: App initialization
**Duration**: 1-2 seconds
**Next**: Login or Home (based on auth status)

---

## 2. LOGIN SCREEN
```
╔═══════════════════╗
║ ← Login           ║
╟───────────────────╢
║       👤          ║
║   Welcome Back!   ║
║                   ║
║ ┌───────────────┐ ║
║ │ Username      │ ║
║ └───────────────┘ ║
║ ┌───────────────┐ ║
║ │ ••••••••      │ ║
║ └───────────────┘ ║
║ ┌───────────────┐ ║
║ │  🔐 LOGIN     │ ║
║ └───────────────┘ ║
║  Test: admin/    ║
║       admin123    ║
╚═══════════════════╝
```
**Credentials**: admin/admin123, user/user123, viewer/viewer123
**Features**: Form validation, mock mode
**Next**: Home Screen

---

## 3. HOME SCREEN
```
╔═══════════════════╗
║ Doc Scanner    ⚙️ ║
╟───────────────────╢
║ ┌───────────────┐ ║
║ │    👤         │ ║
║ │  John Doe     │ ║
║ │   ADMIN       │ ║
║ └───────────────┘ ║
║ ┌─────┬─────┐    ║
║ │ 📷  │ 📁  │    ║
║ │Scan │ Docs│    ║
║ └─────┴─────┘    ║
║ ┌─────┬─────┐    ║
║ │ 📤  │ ℹ️  │    ║
║ │Queue│ Set │    ║
║ └─────┴─────┘    ║
╚═══════════════════╝
```
**Layout**: Profile card + 2x2 menu grid
**Options**: Scan, Documents, Upload Queue, Settings

---

## 4. CAMERA SCREEN
```
╔═══════════════════╗
║ ← Scan Doc    📚2 ║
╟───────────────────╢
║ Position document ║
║  within frame     ║
║ ┌─┐         ┌─┐  ║
║                   ║
║   CAMERA FEED     ║
║   (Live View)     ║
║                   ║
║ └─┘         └─┘  ║
║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ║
║ 💡   ⚪   🖼️    ║
║Flash Capture Gal  ║
╚═══════════════════╝
```
**Features**: Live preview, flash, capture button
**Guides**: Corner brackets for alignment
**Counter**: Shows pages captured (badge)

---

## 5. PAGE PREVIEW SCREEN
```
╔═══════════════════╗
║ ← Page 1       🔄 ║
╟───────────────────╢
║ ╔═══════════════╗ ║
║ ║   CAPTURED    ║ ║
║ ║     PAGE      ║ ║
║ ║    IMAGE      ║ ║
║ ╚═══════════════╝ ║
║ (Pinch to zoom)   ║
╟───────────────────╢
║ ☑️ Auto-Enhance   ║
║ Optimize image    ║
║ ┌─────┬───────┐   ║
║ │+ Add│✓ Done │   ║
║ │More │       │   ║
║ └─────┴───────┘   ║
╚═══════════════════╝
```
**Actions**: Add more pages or finish
**Enhancement**: Toggle auto-enhance
**Zoom**: InteractiveViewer (pinch/zoom)

---

## 6. SCAN REVIEW SCREEN
```
╔═══════════════════╗
║ ← 3 Pages      📷 ║
╟───────────────────╢
║┌─────────────────┐║
║│☰ 📄 Page 1  🗑│║
║│  Enhanced 10:30 │║
║└─────────────────┘║
║┌─────────────────┐║
║│☰ 📄 Page 2  🗑│║
║│  Enhanced 10:31 │║
║└─────────────────┘║
║┌─────────────────┐║
║│☰ 📄 Page 3  🗑│║
║│  Original 10:32 │║
║└─────────────────┘║
╟───────────────────╢
║┌─────────────────┐║
║│📄 Generate PDF  │║
║└─────────────────┘║
╚═══════════════════╝
```
**Features**: Reorder (drag ☰), delete (🗑)
**Actions**: Add more pages, generate PDF
**List**: Thumbnail + metadata for each page

---

## 7. PDF GENERATION SCREEN

### Form State:
```
╔═══════════════════╗
║ ← Generate PDF    ║
╟───────────────────╢
║ ┌───────────────┐ ║
║ │      📄       │ ║
║ │ 3 pages PDF   │ ║
║ └───────────────┘ ║
║ ┌───────────────┐ ║
║ │📝 Title*      │ ║
║ │Monthly Report │ ║
║ └───────────────┘ ║
║ ┌───────────────┐ ║
║ │📁 Category ▼  │ ║
║ └───────────────┘ ║
║ ┌───────────────┐ ║
║ │🏷️ Tags        │ ║
║ └───────────────┘ ║
║ ┌───────────────┐ ║
║ │✓ Generate PDF │ ║
║ └───────────────┘ ║
╚═══════════════════╝
```

### Progress State:
```
╔═══════════════════╗
║ ← Generate PDF    ║
╟───────────────────╢
║       ⚪          ║
║ Generating PDF... ║
║ ▓▓▓▓▓▓▓░░░░░     ║
║      75%          ║
╚═══════════════════╝
```

### Success State:
```
╔═══════════════════╗
║ ← Generate PDF    ║
╟───────────────────╢
║       ✅          ║
║ PDF Generated     ║
║   Successfully!   ║
║ ┌───────────────┐ ║
║ │Title: Report  │ ║
║ │Pages: 3       │ ║
║ │Size: 2.5 MB   │ ║
║ └───────────────┘ ║
║ ┌─────┬───────┐  ║
║ │Share│  Open │  ║
║ └─────┴───────┘  ║
║      Done         ║
╚═══════════════════╝
```

---

## 8. DOCUMENTS SCREEN

### With Documents:
```
╔═══════════════════╗
║ My Documents   🔄 ║
╟───────────────────╢
║ ┌───────────────┐ ║
║ │🔍 Search docs │ ║
║ └───────────────┘ ║
║┌─────────────────┐║
║│📕 Monthly Rpt ⋮│║
║│3 pages • 2.5 MB │║
║│[Invoice]        │║
║└─────────────────┘║
║┌─────────────────┐║
║│📕 Contract   ⋮ │║
║│5 pages • 4.2 MB │║
║│[Contract]       │║
║└─────────────────┘║
║┌─────────────────┐║
║│📕 Receipt    ⋮ │║
║│1 page • 850 KB  │║
║└─────────────────┘║
║             📷    ║
╚═══════════════════╝
```

### Empty State:
```
╔═══════════════════╗
║ My Documents   🔄 ║
╟───────────────────╢
║ ┌───────────────┐ ║
║ │🔍 Search docs │ ║
║ └───────────────┘ ║
║                   ║
║       📂          ║
║  No Documents     ║
║                   ║
║  Scan a document  ║
║   to get started  ║
║                   ║
║             📷    ║
╚═══════════════════╝
```
**Features**: Search, open, share, delete
**Menu**: Tap ⋮ for options per document

---

## 9. UPLOAD QUEUE SCREEN
```
╔═══════════════════╗
║ ← Upload Queue    ║
╟───────────────────╢
║                   ║
║       📤          ║
║                   ║
║   Upload Queue    ║
║                   ║
║ Upload management ║
║   will be         ║
║   available here  ║
║                   ║
║  (Phase 5)        ║
╚═══════════════════╝
```
**Status**: Placeholder
**Planned**: Queue list, progress, retry

---

## 10. SETTINGS SCREEN
```
╔═══════════════════╗
║ ← Settings        ║
╟───────────────────╢
║ Account           ║
║ ┌───────────────┐ ║
║ │👤 John Doe    │ ║
║ │  admin@email  │ ║
║ └───────────────┘ ║
║ Preferences       ║
║ ┌───────────────┐ ║
║ │🌙 Dark Mode ⚪│ ║
║ └───────────────┘ ║
║ ┌───────────────┐ ║
║ │📁 Auto Up  ⚪ │ ║
║ └───────────────┘ ║
║ Storage           ║
║ ┌───────────────┐ ║
║ │🗄️ Clear Cache│ ║
║ └───────────────┘ ║
║ ┌───────────────┐ ║
║ │  🚪 Logout    │ ║
║ └───────────────┘ ║
╚═══════════════════╝
```
**Sections**: Account, Preferences, Storage
**Actions**: Toggle settings, clear cache, logout

---

## NAVIGATION FLOW DIAGRAM

```
         [Splash]
             ↓
         [Login]
             ↓
          [Home]
         /  |  \  \
        /   |   \   \
   [Camera] |   [Queue] [Settings]
      ↓     |              ↓
  [Preview] |          [Logout]
      ↓     |              ↓
   [Review] |          [Login]
      ↓     |
  [Generate]|
      ↓     ↓
   [Documents]
      ↓
  [Open/Share]
```

## USER JOURNEYS

### Journey 1: Scan & Save
```
Home → Camera → Preview → Review → Generate → Success
```
**Time**: ~2-5 minutes
**Steps**: 6 screens
**Output**: PDF document saved

### Journey 2: Find & Share
```
Home → Documents → Search → Open/Share
```
**Time**: ~30 seconds
**Steps**: 3 screens
**Output**: Document shared

### Journey 3: Manage Settings
```
Home → Settings → Toggle Preferences → Logout
```
**Time**: ~1 minute
**Steps**: 3 screens
**Output**: Settings updated

## SCREEN STATISTICS

| Screen | Complexity | User Actions | Navigation Options |
|--------|-----------|--------------|-------------------|
| Splash | Simple | 0 (auto) | 1 (auto-navigate) |
| Login | Simple | 2 (input + submit) | 1 (to home) |
| Home | Simple | 1 (tap card) | 4 (menu options) |
| Camera | Medium | 3 (flash, capture, gallery) | 2 (back, review) |
| Preview | Medium | 2 (enhance, action) | 2 (retake, continue) |
| Review | Complex | 4 (tap, drag, delete, add) | 3 (back, add, generate) |
| Generate | Medium | 3 (form inputs) | 2 (back, done) |
| Documents | Medium | 3 (search, tap, menu) | 2 (back, scan) |
| Queue | Simple | 0 (placeholder) | 1 (back) |
| Settings | Simple | 4 (toggles, logout) | 1 (back) |

## DESIGN METRICS

### Colors Used
- **Primary Blue**: Navigation, buttons, links
- **Red**: PDF icons, errors, delete actions
- **Green**: Success states, checkmarks
- **Gray**: Text, borders, disabled states
- **Black/White**: Backgrounds, text

### Typography
- **6 levels**: Display → Caption
- **Line heights**: 1.2-1.5x font size
- **Font weights**: 400 (regular), 500 (medium), 600 (semibold)

### Spacing
- **Base unit**: 4dp
- **Most common**: 8dp, 16dp, 24dp
- **Large gaps**: 32dp, 48dp

### Components
- **10 screens** total
- **15+ unique widgets** (buttons, cards, lists, etc.)
- **20+ icons** from Material Design
- **3 themes**: Light, dark, high contrast (planned)

## INTERACTION COUNTS

### Taps Required
- **Scan document**: 5-8 taps (camera → capture → enhance → generate → done)
- **View document**: 2 taps (documents → select)
- **Share document**: 3 taps (documents → select → menu → share)
- **Logout**: 3 taps (settings → logout → confirm)

### Form Fields
- **Login**: 2 fields (username, password)
- **Generate PDF**: 3 fields (title, category, tags)
- **Settings**: 2 toggles (dark mode, auto upload)

### Lists/Collections
- **Review pages**: Up to 50+ items
- **Documents**: Unlimited (paginated)
- **Upload queue**: Up to 100 items

## PERFORMANCE TARGETS

### Loading Times
- **Splash**: < 2 seconds
- **Login**: < 1 second
- **Camera init**: < 2 seconds
- **PDF generate**: < 5 seconds (for 5 pages)
- **Search**: < 500ms

### Animation Durations
- **Page transitions**: 300ms
- **Button press**: 100ms
- **Dialog**: 200ms
- **Loading spinner**: Continuous

### File Sizes
- **Images**: 1-3 MB each
- **PDFs**: 2-10 MB (typical)
- **App size**: ~50 MB installed

---

## QUICK COMPARISON TABLE

| Feature | Screen Count | Input Fields | Interactive Elements |
|---------|-------------|--------------|---------------------|
| **Authentication** | 2 | 2 | 1 button |
| **Scanning** | 4 | 0 | 5 buttons, drag-drop |
| **PDF Generation** | 1 | 3 | 3 buttons |
| **Documents** | 1 | 1 | 3 actions per doc |
| **Settings** | 1 | 0 | 4 toggles/buttons |
| **TOTAL** | 10 | 6 | 20+ |

---

## ACCESSIBILITY SUMMARY

### ✅ Implemented
- Color contrast WCAG AA
- Touch targets ≥ 48dp
- Clear labels on all buttons
- Semantic HTML (web)

### 🔄 Planned
- Screen reader optimization
- Keyboard navigation
- Voice commands
- High contrast theme

---

## NOTES FOR DEVELOPERS

### Key Screens to Implement First
1. **Login** - Entry point
2. **Home** - Navigation hub
3. **Camera** - Core feature
4. **Documents** - Content management

### Integration Points
- **Camera ↔ Storage**: Save captured images
- **Review ↔ PDF**: Generate from pages
- **PDF ↔ Database**: Persist documents
- **Documents ↔ Share**: External apps

### State Management
- **Riverpod** for all screens
- **Local state** for form inputs
- **Global state** for user session
- **Persisted state** for documents

---

**For more details, see:**
- [SCREENSHOTS.md](SCREENSHOTS.md) - Full mockups with descriptions
- [UI_WIREFRAMES.md](UI_WIREFRAMES.md) - Design specifications
- [VISUAL_GUIDE_INDEX.md](VISUAL_GUIDE_INDEX.md) - Quick reference

---

**Last Updated**: March 8, 2026
**Version**: 1.0.0
**Status**: All screens documented
