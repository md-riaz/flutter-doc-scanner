# Flutter Document Scanner - App Screenshots & UI Guide

This document provides a visual guide to the Flutter Document Scanner app, showing all screens and their functionality.

## Table of Contents
1. [Splash Screen](#splash-screen)
2. [Login Screen](#login-screen)
3. [Home Screen](#home-screen)
4. [Camera/Scanner Screen](#camerascanner-screen)
5. [Page Preview Screen](#page-preview-screen)
6. [Scan Review Screen](#scan-review-screen)
7. [PDF Generation Screen](#pdf-generation-screen)
8. [Documents Screen](#documents-screen)
9. [Upload Queue Screen](#upload-queue-screen)
10. [Settings Screen](#settings-screen)

---

## Splash Screen

**File**: `lib/features/auth/presentation/screens/splash_screen.dart`

The first screen users see when opening the app. Shows the app logo and checks authentication status.

```
┌─────────────────────────┐
│                         │
│                         │
│         📄              │
│    Document Scanner     │
│                         │
│    ⚪ Loading...        │
│                         │
│                         │
│                         │
└─────────────────────────┘
```

**Features**:
- Displays app branding
- Checks if user is logged in
- Auto-navigates to Login or Home based on session

---

## Login Screen

**File**: `lib/features/auth/presentation/screens/login_screen.dart`

Clean, modern login interface with form validation.

```
┌─────────────────────────┐
│  ←  Login              │
├─────────────────────────┤
│                         │
│      👤                 │
│   Welcome Back!         │
│                         │
│  ┌───────────────────┐  │
│  │ 👤 Username      │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ 🔒 Password      │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │   🔐 Login       │  │
│  └───────────────────┘  │
│                         │
│   Test Credentials:     │
│   admin / admin123      │
│   user / user123        │
│                         │
└─────────────────────────┘
```

**Features**:
- Username and password fields
- Form validation
- Error messages for invalid credentials
- Mock mode with test credentials
- Material 3 design
- Secure token storage after login

**Mock Credentials**:
- Admin: `admin` / `admin123`
- User: `user` / `user123`
- Viewer: `viewer` / `viewer123`

---

## Home Screen

**File**: `lib/features/scanner/presentation/screens/home_screen.dart`

Dashboard with quick access to all main features.

```
┌─────────────────────────┐
│  Document Scanner    ⚙️ │
├─────────────────────────┤
│  ┌───────────────────┐  │
│  │       👤          │  │
│  │     John Doe      │  │
│  │      ADMIN        │  │
│  └───────────────────┘  │
│                         │
│  ┌─────────┬─────────┐  │
│  │   📷    │   📁    │  │
│  │  Scan   │   My    │  │
│  │Document │Documents│  │
│  └─────────┴─────────┘  │
│                         │
│  ┌─────────┬─────────┐  │
│  │   📤    │   ℹ️    │  │
│  │ Upload  │Settings │  │
│  │  Queue  │         │  │
│  └─────────┴─────────┘  │
│                         │
└─────────────────────────┘
```

**Features**:
- User profile card showing name and role
- Grid menu with 4 main options:
  - **Scan Document**: Opens camera to scan
  - **My Documents**: View all saved PDFs
  - **Upload Queue**: Manage pending uploads
  - **Settings**: App settings and logout
- Material 3 card design
- Icon-based navigation

---

## Camera/Scanner Screen

**File**: `lib/features/scanner/presentation/screens/camera_screen.dart`

Full-screen camera interface for document scanning.

```
┌─────────────────────────┐
│  ← Scan Document    📚2 │
├─────────────────────────┤
│ ┌───────────────────┐   │
│ │ Position document │   │
│ │  within the frame │   │
│ └───────────────────┘   │
│                         │
│  ┌─┐             ┌─┐   │
│  │ │             │ │   │
│  └─┘             └─┘   │
│                         │
│   CAMERA PREVIEW        │
│   (Live Document)       │
│                         │
│  ┌─┐             ┌─┐   │
│  │ │             │ │   │
│  └─┘             └─┘   │
│                         │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  │
│  💡    ⚪📷⚪    🖼️   │
│ Flash  Capture  Gallery │
└─────────────────────────┘
```

**Features**:
- Full-screen camera preview
- Corner guide overlay (4 corners with L-shaped brackets)
- Flash toggle button
- Large circular capture button
- Gallery import button (placeholder)
- Page counter badge (shows number of captured pages)
- Hint text at top
- Gradient overlay at bottom for controls
- Lifecycle management (pauses/resumes camera)

**Controls**:
- **Flash**: Toggle flash on/off
- **Capture**: Take photo of document
- **Gallery**: Import from gallery (future feature)
- **Page Counter**: Shows captured pages, tapping navigates to review

---

## Page Preview Screen

**File**: `lib/features/scanner/presentation/screens/page_preview_screen.dart`

Preview individual captured page with enhancement options.

```
┌─────────────────────────┐
│  ← Page 1           🔄  │
├─────────────────────────┤
│                         │
│                         │
│   ╔═══════════════╗     │
│   ║               ║     │
│   ║   CAPTURED    ║     │
│   ║     PAGE      ║     │
│   ║    IMAGE      ║     │
│   ║               ║     │
│   ╚═══════════════╝     │
│                         │
│  (Pinch to zoom)        │
│                         │
├─────────────────────────┤
│ ⚙️ Enhancement          │
│                         │
│ ☑️ Auto-Enhance         │
│ Optimize brightness,    │
│ contrast, and sharpness │
│                         │
│ ┌─────────┬─────────┐   │
│ │ + Add   │✓ Done  │   │
│ │  More   │        │   │
│ └─────────┴─────────┘   │
└─────────────────────────┘
```

**Features**:
- Full-screen image preview
- Pinch-to-zoom support (InteractiveViewer)
- Auto-enhance toggle switch
- Two action buttons:
  - **Add More Pages**: Process and return to camera
  - **Done**: Process and go to review
- Retake button in app bar
- Loading indicator during processing

---

## Scan Review Screen

**File**: `lib/features/scanner/presentation/screens/scan_review_screen.dart`

Review and manage all scanned pages before PDF generation.

```
┌─────────────────────────┐
│  ← 3 Pages         📷   │
├─────────────────────────┤
│                         │
│ ┌───────────────────┐   │
│ │☰ 📄 Page 1      🗑│   │
│ │  Enhanced           │   │
│ │  10:30 AM           │   │
│ └───────────────────┘   │
│                         │
│ ┌───────────────────┐   │
│ │☰ 📄 Page 2      🗑│   │
│ │  Enhanced           │   │
│ │  10:31 AM           │   │
│ └───────────────────┘   │
│                         │
│ ┌───────────────────┐   │
│ │☰ 📄 Page 3      🗑│   │
│ │  Original           │   │
│ │  10:32 AM           │   │
│ └───────────────────┘   │
│                         │
├─────────────────────────┤
│ ┌───────────────────┐   │
│ │  📄 Generate PDF │   │
│ └───────────────────┘   │
└─────────────────────────┘
```

**Features**:
- List of all captured pages
- Thumbnail preview for each page
- Page number and status (Enhanced/Original)
- Timestamp for each capture
- Drag handle (☰) for reordering pages
- Delete button (🗑) for each page
- Tap page to view full-screen
- Add more pages button in app bar
- Generate PDF button at bottom
- ReorderableListView for drag-to-reorder

**Page Actions**:
- Tap to view full-screen with zoom
- Drag to reorder
- Delete with confirmation dialog
- Edit (future feature)

---

## PDF Generation Screen

**File**: `lib/features/pdf/presentation/screens/pdf_generation_screen.dart`

Form to add metadata and generate PDF from scanned pages.

### Form View:
```
┌─────────────────────────┐
│  ← Generate PDF         │
├─────────────────────────┤
│  ┌───────────────────┐  │
│  │       📄          │  │
│  │ Creating PDF with │  │
│  │     3 pages       │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ 📝 Document Title*│  │
│  │ Monthly Report    │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ 📁 Category ▼    │  │
│  │ Invoice          │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ 🏷️ Tags          │  │
│  │ invoice, 2024    │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │  ✓ Generate PDF  │  │
│  └───────────────────┘  │
└─────────────────────────┘
```

### Progress View:
```
┌─────────────────────────┐
│  ← Generate PDF         │
├─────────────────────────┤
│                         │
│         ⚪              │
│                         │
│   Generating PDF...     │
│                         │
│  ▓▓▓▓▓▓▓▓▓▓░░░░░░░     │
│         75%             │
│                         │
└─────────────────────────┘
```

### Success View:
```
┌─────────────────────────┐
│  ← Generate PDF         │
├─────────────────────────┤
│                         │
│         ✅              │
│                         │
│  PDF Generated          │
│    Successfully!        │
│                         │
│  ┌───────────────────┐  │
│  │ Title: Report     │  │
│  │ Pages: 3          │  │
│  │ Size: 2.5 MB      │  │
│  │ Category: Invoice │  │
│  └───────────────────┘  │
│                         │
│  ┌─────────┬─────────┐  │
│  │ Share  │  Open   │  │
│  └─────────┴─────────┘  │
│                         │
│        Done             │
│                         │
└─────────────────────────┘
```

**Features**:
- **Form**: Title (required), category dropdown, tags input
- **Progress**: Circular indicator with percentage
- **Success**: Document details, share and open buttons
- Categories: Invoice, Receipt, Contract, Report, Letter, ID Document, Other
- Tags: Comma-separated input
- Saves to local database
- Adds to upload queue
- Share via system share sheet
- Open with system PDF viewer

---

## Documents Screen

**File**: `lib/features/documents/presentation/screens/documents_screen.dart`

View and manage all saved PDF documents.

```
┌─────────────────────────┐
│  My Documents       🔄  │
├─────────────────────────┤
│  ┌───────────────────┐  │
│  │ 🔍 Search docs... │  │
│  └───────────────────┘  │
│                         │
│ ┌───────────────────┐   │
│ │ 📕 Monthly Report  ⋮│  │
│ │ 3 pages • 2.5 MB     │  │
│ │ [Invoice]            │  │
│ └───────────────────┘   │
│                         │
│ ┌───────────────────┐   │
│ │ 📕 Contract Doc    ⋮│  │
│ │ 5 pages • 4.2 MB     │  │
│ │ [Contract]           │  │
│ └───────────────────┘   │
│                         │
│ ┌───────────────────┐   │
│ │ 📕 Receipt 2024    ⋮│  │
│ │ 1 page • 850 KB      │  │
│ │ [Receipt]            │  │
│ └───────────────────┘   │
│                         │
│              📷         │
│             Scan        │
└─────────────────────────┘
```

### Empty State:
```
┌─────────────────────────┐
│  My Documents       🔄  │
├─────────────────────────┤
│                         │
│         📂              │
│                         │
│    No Documents         │
│                         │
│  Scan a document to     │
│     get started         │
│                         │
│                         │
│              📷         │
│             Scan        │
└─────────────────────────┘
```

**Features**:
- Search bar with real-time filtering
- List of all documents with:
  - PDF icon with red accent
  - Document title
  - Page count and file size
  - Category chip
  - Menu button (⋮)
- Menu options for each document:
  - Open (launches PDF viewer)
  - Share (system share sheet)
  - Delete (with confirmation)
- Refresh button in app bar
- Floating action button to scan new document
- Empty state when no documents
- Automatic refresh after generation

---

## Upload Queue Screen

**File**: `lib/features/upload_queue/presentation/screens/upload_queue_screen.dart`

Manage pending document uploads (placeholder, to be fully implemented).

```
┌─────────────────────────┐
│  ← Upload Queue         │
├─────────────────────────┤
│                         │
│                         │
│         📤              │
│                         │
│    Upload Queue         │
│                         │
│  Upload management      │
│   will be available     │
│       here             │
│                         │
│                         │
│                         │
└─────────────────────────┘
```

**Planned Features** (Phase 5):
- List of pending uploads
- Upload status (pending, uploading, failed)
- Progress bars
- Retry failed uploads
- Clear completed uploads
- Network status indicator
- Background upload support

---

## Settings Screen

**File**: `lib/features/settings/presentation/screens/settings_screen.dart`

App settings and user account management.

```
┌─────────────────────────┐
│  ← Settings             │
├─────────────────────────┤
│                         │
│  Account                │
│  ┌───────────────────┐  │
│  │ 👤 John Doe       │  │
│  │    admin@email    │  │
│  └───────────────────┘  │
│                         │
│  Preferences            │
│  ┌───────────────────┐  │
│  │ 🌙 Dark Mode  ⚪  │  │
│  └───────────────────┘  │
│  ┌───────────────────┐  │
│  │ 📁 Auto Upload ⚪ │  │
│  └───────────────────┘  │
│                         │
│  Storage                │
│  ┌───────────────────┐  │
│  │ 🗄️ Clear Cache   │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │   🚪 Logout       │  │
│  └───────────────────┘  │
│                         │
└─────────────────────────┘
```

**Features**:
- User profile display
- Dark mode toggle (future)
- Auto-upload toggle (future)
- Clear cache option (future)
- Logout button with confirmation
- Material 3 list tiles
- Dividers between sections

---

## Navigation Flow

```
Splash Screen
     ↓
Login Screen
     ↓
Home Screen
     ├─→ Camera Screen
     │        ↓
     │   Page Preview
     │        ↓
     │   Scan Review
     │        ↓
     │   PDF Generation
     │        ↓
     ├─→ Documents Screen
     │        ├─→ Open PDF
     │        └─→ Share PDF
     ├─→ Upload Queue
     └─→ Settings
              └─→ Logout → Login Screen
```

---

## Design System

### Colors
- **Primary**: Material 3 default (blue)
- **Success**: Green (#4CAF50)
- **Error**: Red (#F44336)
- **Warning**: Orange (#FF9800)
- **Background**: Dynamic (light/dark theme)

### Typography
- **Headlines**: Material 3 headlineSmall, headlineMedium
- **Body**: Material 3 bodyMedium, bodySmall
- **Titles**: Material 3 titleMedium, titleLarge

### Components
- **Cards**: Elevated cards with rounded corners (12px)
- **Buttons**: ElevatedButton, OutlinedButton, TextButton
- **Icons**: Material Icons with 24-32px size
- **Spacing**: 8, 16, 24, 32px increments

### Layout
- **Padding**: 16px standard, 24px for screens
- **Margins**: 8px between items, 16px between sections
- **Grid**: 2-column for home menu
- **Lists**: Full-width with dividers

---

## Screenshots Generation Notes

Since this is a Flutter app without a running instance in this environment, actual screenshots would need to be taken by:

1. **Using Flutter Screenshot Tools**:
   ```bash
   flutter run
   # Then use Flutter DevTools or device screenshot
   ```

2. **Using Emulator**:
   ```bash
   flutter emulators --launch <emulator_id>
   flutter run
   # Take screenshots via emulator controls
   ```

3. **Using Physical Device**:
   ```bash
   flutter run -d <device_id>
   # Use device screenshot buttons
   ```

4. **Automated Screenshots**:
   - Use `integration_test` package
   - Add screenshot capabilities
   - Generate screenshots for all screens

For now, this documentation provides detailed mockups and descriptions of every screen in the app.

---

## Key User Flows

### 1. Scan and Save Document
1. Login with credentials
2. Tap "Scan Document" on home
3. Position document in camera view
4. Tap capture button
5. Review captured page
6. Tap "Add More Pages" or "Done"
7. Reorder pages if needed
8. Tap "Generate PDF"
9. Fill in title, category, tags
10. Tap "Generate PDF"
11. Document saved and ready to share/open

### 2. View Saved Documents
1. Tap "My Documents" on home
2. Search or browse documents
3. Tap document to open in PDF viewer
4. Use menu to share or delete

### 3. Manage Settings
1. Tap "Settings" on home
2. Toggle preferences
3. Tap "Logout" to sign out

---

**Note**: This app is built with Material 3 design system and follows Flutter best practices for a clean, modern, and intuitive user experience.
