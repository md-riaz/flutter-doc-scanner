# Architecture Specification

## 5) Recommended Solution Architecture

### 5.1 High-Level Architecture

```
Mobile App (Flutter Android)
        ↕
REST API / Auth API / Upload API
        ↕
Cloud Storage + Database + Admin Dashboard
```

### 5.2 App Layers

Use a clean, maintainable architecture:

* **Presentation Layer**
  * screens
  * widgets
  * routing
  * state management

* **Domain Layer**
  * entities
  * use cases
  * business rules

* **Data Layer**
  * repositories
  * API clients
  * local database
  * file storage
  * upload queue

This keeps the app from turning into spaghetti in a tracksuit.

---

## 10) Architecture Recommendation for This Project

### Preferred Build Strategy

Use:
* `camera` for the custom scanning experience
* a scanning plugin only if it proves reliable on target devices
* `image` for enhancement
* `pdf` for assembly
* `dio` for uploads
* `drift` for offline queue
* `flutter_riverpod` for app state

### Why this is the safest plan

A pure "all-in-one scanner plugin solves everything" plan sounds dreamy, but those dreams often end in native-plugin chaos, device quirks, and debugging pain at 2:13 AM.

So:
* use a plugin for edge detection/cropping only if validated,
* keep PDF/upload/storage logic in your own architecture,
* own the business workflow completely.

---

## 11) Suggested App Modules and Folder Structure

```
lib/
  app/
    app.dart
    router.dart
    theme/
  core/
    constants/
    utils/
    network/
    storage/
    errors/
  features/
    auth/
      data/
      domain/
      presentation/
    scanner/
      data/
      domain/
      presentation/
    documents/
      data/
      domain/
      presentation/
    upload_queue/
      data/
      domain/
      presentation/
    projects/
      data/
      domain/
      presentation/
    settings/
      presentation/
  shared/
    widgets/
    models/
```
