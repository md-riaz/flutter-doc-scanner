# Development Plan

## 18) Phase-by-Phase Development Plan

### Phase 0 — Discovery and Technical Validation

#### Goal
Reduce risk before full build.

#### Deliverables
* finalize backend API contract
* choose scanning approach:
  * `camera` + custom processing
  * or `flutter_doc_scanner`
* validate PDF generation
* test upload reliability
* validate offline queue recovery
* benchmark scan quality on target devices

**Duration:** 1-2 weeks

---

### Phase 1 — Foundation

#### Features
* Flutter project setup
* Folder structure
* State management setup (Riverpod)
* Routing (go_router)
* API client setup (dio)
* Secure storage setup
* Local database setup (drift)
* Environment configuration (dev/staging/prod)

#### Deliverables
* working app skeleton
* API integration ready
* local storage working

**Duration:** 1 week

---

### Phase 2 — Authentication

#### Features
* Login screen
* Login API integration
* Token storage
* Session management
* Role-based routing
* Logout
* Token refresh
* Error handling

#### Deliverables
* users can log in and stay logged in
* roles control access

**Duration:** 1 week

---

### Phase 3 — Scanning Core

#### Features
* Camera integration
* Document edge detection
* Auto-crop
* Manual crop adjustment
* Capture image
* Preview captured page
* Retake page
* Basic enhancement (brightness/contrast)

#### Deliverables
* users can capture single-page scans
* pages are cropped and readable

**Duration:** 2 weeks

---

### Phase 4 — Multi-Page Scanning

#### Features
* Add multiple pages to session
* Page list view
* Reorder pages
* Delete pages
* Review all pages before save

#### Deliverables
* users can build multi-page documents

**Duration:** 1 week

---

### Phase 5 — PDF Generation

#### Features
* Combine pages into PDF
* PDF compression
* Save PDF locally
* Generate metadata
* Local document storage

#### Deliverables
* multi-page PDFs generated and stored locally

**Duration:** 1 week

---

### Phase 6 — Upload System

#### Features
* Project/folder selection
* Upload API integration
* Auto-upload after scan
* Manual upload later
* Upload queue
* Upload status tracking
* Retry failed uploads
* Network detection
* Background upload (where supported)

#### Deliverables
* documents upload to server
* upload queue works offline
* failed uploads can retry

**Duration:** 2 weeks

---

### Phase 7 — Document Management

#### Features
* Document list
* Filter by project/status/date
* Rename document
* Add tags
* Add category
* PDF preview
* Download from server
* Share document
* Sync with server

#### Deliverables
* users can manage uploaded documents
* metadata syncs with server

**Duration:** 1.5 weeks

---

### Phase 8 — Security Enhancements

#### Features
* HTTPS enforcement
* Secure token handling
* Optional biometric unlock
* Session timeout handling
* Error logging (redacted)

#### Deliverables
* app meets security requirements

**Duration:** 1 week

---

### Phase 9 — Polish & Testing

#### Features
* UI/UX refinement
* Loading states
* Error messages
* Scan quality hints
* Performance optimization
* Integration testing
* User acceptance testing

#### Deliverables
* production-ready app

**Duration:** 1.5 weeks

---

### Phase 10 — Admin Dashboard (Optional/Parallel)

#### Features
* Web dashboard setup
* User list
* Upload monitoring
* Failed upload review
* Project/folder management
* Basic reporting

#### Deliverables
* admin can monitor app usage

**Duration:** 2-3 weeks (can be parallel)

---

### Total Estimate

**~12 to 17 weeks**, depending on:
* backend readiness
* scan quality expectations
* dashboard scope
* ERP/DMS integration complexity

---

## 20) Recommended MVP vs Full Version

### MVP
* login
* scan
* crop
* enhancement preset
* multi-page PDF
* auto/manual upload
* upload queue
* status tracking
* project/folder assignment
* document list
* rename/tag
* Android only

### Full Version
* advanced admin dashboard
* deep ERP/DMS integration
* biometric re-auth
* stronger reporting
* PDF passwording
* audit logs
* backup/recovery tooling
* OCR/search later if needed

---

## 21) Implementation Recommendation

### Best Practical Stack for This App

For your case, I'd recommend:
* **Flutter**
* **camera**
* **flutter_doc_scanner** only after device validation
* **image**
* **pdf**
* **dio**
* **flutter_secure_storage**
* **drift**
* **flutter_riverpod**
* **go_router**
* **connectivity_plus**
* **workmanager**
* **local_auth** (optional)

This stack matches the requirements well and gives you room to own the business workflow instead of being trapped inside a magical plugin castle built on sand.

---

## 22) Final Engineering Notes

### Key Risks
* scanner plugin behavior may vary by device
* shadow removal quality may need native/OpenCV tuning
* background upload behavior on Android depends on OS/device restrictions
* backend contract must be finalized early
* PDF passwording requirement needs business decision

### Strong Recommendation

Start with a **technical proof of concept** for:
1. scan quality,
2. multi-page PDF size,
3. upload reliability,
4. offline queue recovery.

That will save you from building a beautiful cathedral on top of a swamp.
