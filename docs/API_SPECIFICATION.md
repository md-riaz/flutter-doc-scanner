# API Specification

## 14) API Requirements for Backend

### 14.1 Authentication APIs

* POST `/auth/login`
* POST `/auth/refresh`
* POST `/auth/logout`
* GET `/me`

### 14.2 Metadata APIs

* GET `/projects`
* GET `/folders`
* GET `/categories`
* GET `/tags`

### 14.3 Document APIs

* POST `/documents/upload`
* POST `/documents/{id}/metadata`
* GET `/documents`
* GET `/documents/{id}`
* GET `/documents/{id}/download`
* PATCH `/documents/{id}`
* DELETE `/documents/{id}` (if allowed)

### 14.4 Admin APIs

* GET `/admin/uploads`
* GET `/admin/users`
* GET `/admin/reports`
* GET `/admin/failed-uploads`

### 14.5 Integration APIs

* outbound webhook or internal sync for ERP/DMS/accounting
* mapping fields:
  * document ID
  * project
  * uploader
  * upload time
  * tags/category
  * external reference ID
