# Functional Specification

## 6.1 Authentication Module

### Features

* Login with user ID / username / email and password
* Session persistence
* Token refresh
* Logout
* Role retrieval from server
* Optional device lock / biometric unlock for app reopen

### Roles

* **Admin**
  * view all uploads/users/projects
  * monitor upload failures
  * manage metadata visibility as allowed by backend

* **User**
  * scan, upload, manage assigned documents

* **Viewer**
  * read-only access to allowed documents

### Acceptance Criteria

* User can sign in securely
* Role controls visible screens/actions
* Session remains valid until logout/token expiry
* Sensitive credentials not stored in plain text

---

## 6.2 Scanning Module

### Features

* Open device camera
* Live preview
* Detect document edges
* Auto-crop
* Manual crop correction
* Perspective correction
* Capture multiple pages in a session
* Retake page
* Reorder pages
* Delete page
* Preview per page

### Enhancement Controls

* Auto enhancement preset
* Brightness adjustment
* Contrast adjustment
* Shadow reduction
* Optional grayscale / B&W mode for readability and size reduction

### User Guidance

* Show scan tips:
  * keep page flat
  * avoid shadows
  * ensure good light
  * hold steady
* Warn when image is blurry / too dark / too tilted if feasible

### Acceptance Criteria

* User can scan one or more pages
* Each page can be corrected before save
* Final scan quality is readable for documents like invoices, forms, office papers

---

## 6.3 Document Assembly & PDF Module

### Features

* Combine multiple scanned pages into one PDF
* Maintain selected page order
* Compress PDF before upload
* Save PDF locally until upload completes
* Generate file metadata:
  * filename
  * project/folder
  * created time
  * page count
  * size
  * scan user

### Acceptance Criteria

* User can generate a valid multi-page PDF from scanned images
* File size is optimized enough for mobile upload
* Local copy survives app close/reopen until sync completes

---

## 6.4 Upload & Sync Module

### Upload Modes

1. **Auto-upload after scan**
2. **Manual upload later**

### Features

* Upload queued files to backend
* Retry failed uploads
* Resume pending sync on app restart
* Show upload status:
  * pending
  * uploading
  * uploaded
  * failed
* Network-aware behavior
* Metadata sync with server response
* Background upload where platform constraints allow

### Acceptance Criteria

* App can continue working offline
* Pending files are stored locally
* Failed uploads can be retried
* Uploaded documents reflect server status and IDs

---

## 6.5 Folder / Project-Based Storage

### Features

* User selects folder or project before upload
* App can fetch available projects/folders from API
* Documents stored against selected destination
* Search/filter by project/folder/status/date

### Acceptance Criteria

* Every document is associated with a destination context
* Project/folder metadata stays synced with server rules

---

## 6.6 Document Management Module

### Features

* Document list view
* Rename document
* Add tags
* Add category
* Open PDF preview
* Download from server
* Share document
* Filter and sort:
  * by date
  * by project
  * by upload status
  * by tag/category

### Acceptance Criteria

* User can find and manage uploaded and pending documents easily
* Metadata changes reflect locally and sync to server

---

## 6.7 Security Module

### Features

* HTTPS-only API communication
* Token-based authentication
* Secure local storage for tokens/secrets
* Optional app unlock with biometrics/PIN
* Password-protected document support:
  * either PDF encryption on device
  * or server-side access gating
* Audit-friendly upload and access logs on backend

### Important Note

"Password-protected documents" needs a final decision:
* **Option A:** protect the generated PDF itself
* **Option B:** protect access through authenticated server permissions

For enterprise systems, **Option B** is usually simpler and more maintainable.

---

## 6.8 Integration Module

### Features

* REST API integration with:
  * ERP
  * DMS
  * Accounting systems
* Standard payloads for document upload and metadata
* Webhooks or polling for processing result if backend requires it
* External document ID mapping

### Acceptance Criteria

* Uploaded file + metadata can be consumed by external enterprise systems
* Integration errors are surfaced clearly in admin logs

---

## 6.9 Admin Dashboard (Web)

This is best handled as:
* separate Flutter Web app, or
* backend admin panel (Laravel/React/etc.)

### Features

* User list
* Upload monitoring
* Failed upload review
* Project/folder management
* Basic reporting
* Search documents
* Role assignment
* Backup/recovery controls (server-side)

### Acceptance Criteria

* Admin can monitor operational health
* Admin can trace documents by user/project/status
