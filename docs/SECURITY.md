# Security Specification

## 15) Security Specification

### Mobile App

* Store tokens in secure storage only
* Do not store passwords after login
* Enforce HTTPS
* Redact file paths and secrets from logs
* Optional biometric lock on app open

### Backend

* Validate role per API request
* Virus/malware scan uploaded files if needed
* Keep audit logs
* Server-side backup and restore
* Access rules must be enforced on server, not trusted from client UI

### Document Protection Strategy

Recommended:
* authenticated access control on server first
* optional per-document password only if business requires exported PDF security

---

## 7) Non-Functional Requirements

### 7.1 Performance

* Scan capture should feel responsive
* PDF generation should complete within acceptable time for normal docs
* Upload must support medium-sized PDFs over unstable mobile networks
* App should avoid blocking UI during processing

### 7.2 Reliability

* No document loss if app closes unexpectedly after scan
* Retry mechanism for failed uploads
* Local queue persisted in database

### 7.3 Usability

* One primary workflow: **Scan → Review → Save PDF → Upload**
* Minimal training required
* Large buttons for capture/review in field use

### 7.4 Security

* Encrypted transport only
* Secure token storage
* Role-based access enforced by server, not only UI
* Sensitive logs redacted

### 7.5 Maintainability

* Modular architecture
* Feature-based folder structure
* Configurable API endpoints
* Environment separation:
  * dev
  * staging
  * production

### 7.6 Device Constraints

* Android-first
* Camera quality varies by device
* App should work on mid-range Android devices
* Higher megapixel helps image clarity but is not mandatory

---

## 16) Error Handling Specification

### Common Errors

* invalid login
* no camera permission
* scan failed
* low-quality image
* PDF generation failed
* network timeout
* upload failed
* token expired
* invalid project/folder
* server rejected file

### Expected Behavior

* show clear error message
* keep local data safe
* allow retry
* do not lose scan session
