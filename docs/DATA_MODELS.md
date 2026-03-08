# Data Models

## 13) Data Model (Suggested)

### 13.1 User

* id
* name
* username
* role
* accessToken
* refreshToken
* assignedProjects

### 13.2 Project / Folder

* id
* name
* code
* type
* isActive

### 13.3 Scan Page

* localId
* imagePath
* pageIndex
* width
* height
* enhancementPreset
* cropPoints

### 13.4 Document

* localId
* serverId
* title
* projectId
* category
* tags
* pdfLocalPath
* pdfRemoteUrl
* pageCount
* fileSize
* createdAt
* createdBy
* uploadStatus
* failureReason

### 13.5 Upload Job

* jobId
* documentLocalId
* status
* attemptCount
* lastAttemptAt
* serverResponse
* errorMessage
