# Technology Stack

## 8) Suggested Flutter Tech Stack

### 8.1 Core App Stack

* **Flutter**
* **Dart**
* **Android-first deployment**
* **REST API backend**

### 8.2 Recommended Packages

Here's a practical package set.

#### Camera / Document Scanning

* **camera** for direct camera control, preview, capture, and image stream support.
* **flutter_doc_scanner** as a candidate package for document edge detection, cropping, filters, blemish cleanup, and PDF/JPEG scan output.

#### Image Processing

* **image** for Dart-side image manipulation such as brightness, contrast, resizing, and general processing.

#### PDF Generation

* **pdf** for creating multi-page PDF documents in Flutter/Dart.

#### Networking / Upload

* **dio** for API communication, multipart file upload, interceptors, timeout handling, and retries.

#### Secure Storage

* **flutter_secure_storage** for storing access tokens and other sensitive local values securely.

#### Local Database / Offline Queue

* **drift** for reactive relational local data storage, ideal for pending uploads, documents, and sync metadata.

#### State Management

* **flutter_riverpod** for scalable state management, dependency injection, and async data handling.

#### Routing

* **go_router** for structured app navigation and deep-link-friendly routing.

#### Connectivity Awareness

* **connectivity_plus** to observe connectivity changes, though network success must still be verified by real request handling.

#### Background Work / Retry

* **workmanager** for scheduling background work on Android and iOS, useful for queued upload retries.

#### Optional App Re-Authentication

* **local_auth** for fingerprint/face/device-auth unlock on supported devices.

---

## 9) Recommended Package Mapping by Feature

| Feature                        | Suggested Package(s)     | Notes                                         |
| ------------------------------ | ------------------------ | --------------------------------------------- |
| Camera preview & capture       | `camera`                 | Best for custom scanner UI                    |
| Document edge detection / crop | `flutter_doc_scanner`    | Fastest route if plugin quality suits project |
| Image enhancement              | `image`                  | Brightness/contrast/resize/compression        |
| PDF creation                   | `pdf`                    | Multi-page PDF assembly                       |
| API upload                     | `dio`                    | Multipart + interceptors + retry strategy     |
| Secure tokens                  | `flutter_secure_storage` | Avoid plain-text token storage                |
| Offline queue                  | `drift`                  | Reliable local persistence                    |
| State management               | `flutter_riverpod`       | Clean architecture friendly                   |
| Routing                        | `go_router`              | Structured navigation                         |
| Connectivity listener          | `connectivity_plus`      | For sync hints, not as absolute truth         |
| Background retry               | `workmanager`            | Re-attempt uploads later                      |
| Biometric unlock               | `local_auth`             | Optional security enhancement                 |
