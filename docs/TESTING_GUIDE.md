# Document Detection Features - Quick Testing Guide

This guide provides a quick checklist for testing all document detection features.

---

## Testing Checklist

### 1. Camera + Edge Detection ✅

**Feature:** Automatic document edge detection using OpenCV

**Test Steps:**
1. Open the app and login (admin/admin123)
2. Tap the floating action button to start scanning
3. Point camera at a document on a contrasting surface
4. Capture the photo
5. **Expected:** App automatically detects document edges

**Verification Points:**
- [ ] Camera preview loads correctly
- [ ] Flash toggle works
- [ ] Capture button responds
- [ ] Edge detection completes in < 1 second for simple documents
- [ ] Corners are detected at document boundaries
- [ ] Fallback rectangle appears if detection fails

**Files Involved:**
- `lib/features/scanner/data/services/edge_detection_service.dart`
- `lib/features/scanner/presentation/screens/camera_screen.dart`

---

### 2. Perspective Correction ✅

**Feature:** Transform skewed document photos into flat rectangular scans

**Test Steps:**
1. Capture a document at an angle (not perpendicular)
2. Wait for automatic processing
3. View the result in page preview
4. **Expected:** Document appears flat and rectangular

**Verification Points:**
- [ ] Skewed document is corrected
- [ ] Document edges are straight lines
- [ ] No distortion in text or images
- [ ] Aspect ratio is maintained
- [ ] Processing completes in < 1 second

**Files Involved:**
- `lib/features/scanner/data/services/edge_detection_service.dart` (applyPerspectiveTransform method)

---

### 3. Image Filters (12 Filters) ✅

**Feature:** Professional image enhancement filters

**Test Filters:**

#### 3.1 Black & White Document
- [ ] Converts to high-contrast B&W
- [ ] Text is sharp and readable
- [ ] Good for receipts and printed text
- **Best for:** Text documents, receipts, forms

#### 3.2 Grayscale
- [ ] Simple B&W conversion
- [ ] No thresholding
- **Best for:** Basic B&W needs

#### 3.3 Color Pop
- [ ] Colors are more vibrant
- [ ] Increased saturation (1.5x)
- [ ] Increased contrast (1.2x)
- **Best for:** Color documents, presentations

#### 3.4 Magic Color
- [ ] Auto-enhanced colors
- [ ] Better contrast
- **Best for:** General purpose enhancement

#### 3.5 Sharpen
- [ ] Edges are more defined
- [ ] Text appears crisper
- **Best for:** Blurry documents

#### 3.6 Denoise
- [ ] Reduced noise/grain
- [ ] Smoother image
- [ ] Takes 300-500ms (slower)
- **Best for:** Low-light photos

#### 3.7 Sepia
- [ ] Brown vintage tone applied
- **Best for:** Artistic effect

#### 3.8 Invert
- [ ] Colors are inverted (negative)
- **Best for:** Artistic effect, accessibility

#### 3.9 Vintage
- [ ] Old photo effect
- [ ] Sepia + reduced saturation
- **Best for:** Artistic effect

#### 3.10 Cool
- [ ] Blue tone applied
- **Best for:** Artistic effect

#### 3.11 Warm
- [ ] Orange/red tone applied
- **Best for:** Artistic effect

#### 3.12 Original
- [ ] No filter applied
- [ ] Original image preserved

**Test Steps:**
1. Capture a document
2. Scroll through filter selector at bottom
3. Tap each filter
4. **Expected:** Preview updates with filter applied
5. Test with different document types (text, color, photos)

**Verification Points:**
- [ ] All 12 filters are visible in selector
- [ ] Filter thumbnails display correctly
- [ ] Selected filter is highlighted
- [ ] Filter applies in < 500ms (except denoise)
- [ ] Filter persists when adding more pages

**Files Involved:**
- `lib/features/scanner/data/services/image_filters_service.dart`
- `lib/features/scanner/presentation/screens/page_preview_screen.dart`

---

### 4. Manual Corner Adjustment ✅

**Feature:** Interactive corner adjustment UI with draggable points

**Test Steps:**
1. Capture a document
2. Navigate to Scan Review screen
3. Tap on a page thumbnail
4. Tap "Edit" button
5. Drag corner points to adjust document boundaries
6. Tap "Apply"
7. **Expected:** Document is transformed based on adjusted corners

**Verification Points:**
- [ ] Corner adjustment screen opens
- [ ] Auto-detection runs on load
- [ ] 4 corner markers visible (TL, TR, BR, BL)
- [ ] Corners are labeled
- [ ] Corners can be dragged smoothly
- [ ] Quadrilateral overlay updates in real-time
- [ ] Semi-transparent mask outside document
- [ ] Reset button re-runs detection
- [ ] Apply button transforms and saves
- [ ] Cancel button returns without changes

**Files Involved:**
- `lib/features/scanner/presentation/screens/corner_adjustment_screen.dart`

---

### 5. Multi-Page Documents ✅

**Feature:** Capture and manage multiple pages in one session

**Test Steps:**
1. Capture first page
2. Tap "Add More Pages" or "+" button
3. Capture 2-3 more pages
4. **Expected:** All pages shown in scan review

**Verification Points:**
- [ ] Multiple pages can be captured
- [ ] Page counter updates (e.g., "Page 3/5")
- [ ] All pages visible in scan review
- [ ] Page thumbnails display correctly
- [ ] Each page can be edited independently

**Test Reordering:**
1. Long-press a page in scan review
2. Drag to new position
3. **Expected:** Pages reorder correctly

**Verification Points:**
- [ ] Drag handle appears
- [ ] Pages can be reordered
- [ ] Page numbers update automatically

**Test Deletion:**
1. Swipe left on a page OR tap delete icon
2. Confirm deletion
3. **Expected:** Page is removed

**Verification Points:**
- [ ] Delete confirmation dialog appears
- [ ] Page is removed after confirmation
- [ ] Page numbers update
- [ ] Cannot delete if only one page remains (or shows warning)

**Files Involved:**
- `lib/features/scanner/domain/entities/scan_session.dart`
- `lib/features/scanner/presentation/providers/scan_session_provider.dart`
- `lib/features/scanner/presentation/screens/scan_review_screen.dart`

---

### 6. PDF Generation ✅

**Feature:** Generate multi-page PDFs from scanned pages

**Test Steps:**
1. Capture 2-5 pages
2. Navigate to scan review
3. Tap "Generate PDF" button
4. Enter title: "Test Document"
5. Select category: "Invoice"
6. Add tags: "test, demo"
7. Select project (optional)
8. Tap "Generate PDF"
9. **Expected:** PDF is generated and can be opened/shared

**Verification Points:**
- [ ] PDF generation screen opens
- [ ] Title field is required
- [ ] Category dropdown works
- [ ] Project dropdown loads projects
- [ ] Tags can be entered (comma-separated)
- [ ] Progress indicator shows during generation
- [ ] Success screen appears
- [ ] "Open PDF" opens in viewer
- [ ] "Share" opens system share dialog
- [ ] PDF contains all pages in correct order

**Files Involved:**
- `lib/features/pdf/data/services/pdf_service.dart`
- `lib/features/pdf/presentation/screens/pdf_generation_screen.dart`

---

### 7. Document Management ✅

**Feature:** View, search, open, share, and delete documents

**Test Steps:**
1. Navigate to Documents screen (from bottom nav)
2. Search for a document by title
3. Tap a document to view details
4. **Expected:** Document list, search, and actions work

**Verification Points:**
- [ ] Documents list displays
- [ ] Each document shows title, pages, size, category
- [ ] Search bar filters documents
- [ ] Tap "Open" opens PDF in viewer
- [ ] Tap "Share" opens system share dialog
- [ ] Tap "Delete" removes document (with confirmation)
- [ ] Pull-to-refresh works
- [ ] Empty state shows when no documents

**Files Involved:**
- `lib/features/documents/presentation/screens/documents_screen.dart`

---

### 8. Gallery Import ✅

**Feature:** Import images from device gallery

**Test Steps:**
1. From camera screen, tap gallery icon
2. Select an image from gallery
3. **Expected:** Image is imported and edge detection runs

**Verification Points:**
- [ ] Gallery picker opens
- [ ] Selected image is imported
- [ ] Edge detection runs automatically
- [ ] Can adjust corners if needed
- [ ] Can apply filters
- [ ] Can add to existing session

**Files Involved:**
- `lib/features/scanner/presentation/screens/camera_screen.dart`

---

### 9. Upload Queue ✅

**Feature:** Upload documents to cloud with retry mechanism

**Test Steps:**
1. Generate a PDF
2. Navigate to Upload Queue screen
3. **Expected:** Document appears in queue
4. Wait for upload (or tap "Upload All")
5. **Expected:** Upload completes with progress

**Verification Points:**
- [ ] Document added to queue after generation
- [ ] Upload statistics displayed (pending/uploaded/failed)
- [ ] Progress bar shows upload progress
- [ ] Retry works for failed uploads
- [ ] "Clear Uploaded" removes completed items
- [ ] Upload works in mock mode

**Files Involved:**
- `lib/features/upload_queue/presentation/screens/upload_queue_screen.dart`
- `lib/features/upload_queue/data/services/upload_service.dart`

---

### 10. Projects/Folders ✅

**Feature:** Organize documents into projects

**Test Steps:**
1. Navigate to Projects screen
2. Tap "+" to create new project
3. Enter name: "Test Project"
4. Select color
5. Save project
6. **Expected:** Project appears in list
7. Generate PDF and assign to this project
8. Tap project to view filtered documents

**Verification Points:**
- [ ] Projects grid displays
- [ ] Can create new project
- [ ] Color picker works
- [ ] Project displays with selected color
- [ ] Document count updates
- [ ] Tapping project filters documents
- [ ] Can edit/delete projects

**Files Involved:**
- `lib/features/projects/presentation/screens/projects_screen.dart`

---

## Performance Benchmarks

Expected performance on mid-range Android device:

| Operation | Expected Time | Acceptable Range |
|-----------|--------------|------------------|
| Edge detection | 100-300ms | 50-500ms |
| Perspective transform | 100-200ms | 50-300ms |
| Filter application | 50-200ms | 50-500ms |
| Denoise filter | 300-500ms | 300-800ms |
| PDF generation (5 pages) | 1-2 seconds | 1-5 seconds |

---

## Test Document Types

Test with various document types for comprehensive coverage:

### Text Documents
- [ ] Receipts (small text, low contrast)
- [ ] Contracts (black text on white)
- [ ] Book pages
- [ ] Printed forms
- [ ] Handwritten notes

### Color Documents
- [ ] Brochures (colorful graphics)
- [ ] Presentation slides
- [ ] Color photos
- [ ] ID cards
- [ ] Product packaging

### Challenging Cases
- [ ] Curved or wrinkled pages
- [ ] Documents with shadows
- [ ] Low contrast documents
- [ ] Documents on patterned backgrounds
- [ ] Multiple objects in frame
- [ ] Very small documents
- [ ] Very large documents

---

## Recommended Filter for Each Document Type

| Document Type | Primary Filter | Alternative Filter |
|--------------|----------------|-------------------|
| Receipts | B&W Document | Sharpen |
| Contracts | B&W Document | Grayscale |
| Forms | B&W Document | Grayscale |
| Books | Grayscale | B&W Document |
| Brochures | Color Pop | Magic Color |
| Presentations | Color Pop | Sharpen |
| Photos | Magic Color | Color Pop |
| ID Cards | Sharpen | Magic Color |
| Old documents | Denoise → B&W | Sharpen |
| Low-light photos | Denoise | Magic Color |

---

## Common Issues and Solutions

### Issue: Edge detection fails
**Solutions:**
- Ensure good lighting
- Use contrasting background
- Hold document flat
- Use manual corner adjustment

### Issue: Text is blurry after scanning
**Solutions:**
- Apply Sharpen filter
- Ensure camera is in focus when capturing
- Use B&W Document filter for text

### Issue: Document has shadows
**Solutions:**
- Use Magic Color filter
- Improve lighting when capturing
- Use B&W Document filter (adaptive threshold helps)

### Issue: Colors look washed out
**Solutions:**
- Apply Color Pop filter
- Apply Magic Color filter
- Adjust device camera settings

### Issue: Too much noise/grain
**Solutions:**
- Apply Denoise filter
- Improve lighting conditions
- Use lower ISO if camera allows

---

## Mock Mode Testing

**Default Mock Credentials:**
- Admin: `admin` / `admin123`
- User: `user` / `user123`
- Viewer: `viewer` / `viewer123`

**Mock Mode Features:**
- ✅ Authentication works
- ✅ All scanning features work
- ✅ PDF generation works
- ✅ Document storage works (local database)
- ✅ Upload simulation works (no actual upload)
- ✅ Projects work
- ⚠️ Cloud sync does not work (no backend)

---

## Automated Testing (Future)

Consider adding these automated tests:

### Unit Tests
- [ ] EdgeDetectionService.detectDocumentEdges()
- [ ] EdgeDetectionService.applyPerspectiveTransform()
- [ ] ImageFiltersService.applyFilter() for each filter
- [ ] Corner sorting algorithm
- [ ] Coordinate transformation

### Integration Tests
- [ ] Complete scanning workflow
- [ ] Multi-page capture and reorder
- [ ] PDF generation from pages
- [ ] Document search and filter

### Widget Tests
- [ ] Camera screen UI
- [ ] Corner adjustment UI
- [ ] Filter selector UI
- [ ] Scan review UI

---

## Quality Assurance Checklist

Before releasing a new version:

### Functional Testing
- [ ] All 12 filters work correctly
- [ ] Edge detection works on various document types
- [ ] Perspective correction produces flat scans
- [ ] Manual corner adjustment is smooth and responsive
- [ ] Multi-page capture and reordering works
- [ ] PDF generation includes all pages
- [ ] Document management (search, filter, delete) works
- [ ] Gallery import works
- [ ] Upload queue functions correctly
- [ ] Projects organization works

### Performance Testing
- [ ] Edge detection completes in acceptable time
- [ ] Filter application is responsive
- [ ] App doesn't lag when switching filters
- [ ] PDF generation completes in reasonable time
- [ ] No memory leaks during extended use

### UI/UX Testing
- [ ] All screens are accessible
- [ ] Loading indicators show during processing
- [ ] Error messages are clear and helpful
- [ ] Buttons are responsive
- [ ] Navigation flows logically
- [ ] Help text is visible where needed

### Edge Cases
- [ ] App handles camera permission denial
- [ ] App handles storage permission denial
- [ ] App handles very large images (> 10MB)
- [ ] App handles very small images (< 100KB)
- [ ] App handles rapid captures (stress test)
- [ ] App handles low memory conditions
- [ ] App handles network errors gracefully

### Device Testing
- [ ] Test on Android 7.0 (API 24) - minimum version
- [ ] Test on Android 10 (API 29) - common version
- [ ] Test on Android 12+ (API 31+) - latest versions
- [ ] Test on low-end device (2GB RAM)
- [ ] Test on mid-range device (4GB RAM)
- [ ] Test on high-end device (8GB+ RAM)
- [ ] Test in both portrait and landscape

---

## Conclusion

This testing guide ensures all document detection features work as expected. Follow the checklist systematically to verify the implementation matches the problem statement requirements.

For detailed technical information, see:
- [DOCUMENT_DETECTION_GUIDE.md](./DOCUMENT_DETECTION_GUIDE.md)
- [FEATURE_VERIFICATION.md](./FEATURE_VERIFICATION.md)

---

**Last Updated:** March 9, 2026
**Version:** 1.0
