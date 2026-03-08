import 'package:drift/drift.dart';

/// Documents table for storing generated PDFs and their metadata
class Documents extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get filePath => text()();
  IntColumn get pageCount => integer()();
  IntColumn get fileSizeBytes => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get projectId => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get tags => text().nullable()(); // JSON array as string
  TextColumn get uploadStatus => text().withDefault(const Constant('pending'))();
  BoolColumn get isUploaded => boolean().withDefault(const Constant(false))();
  DateTimeColumn get uploadedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Upload queue table for tracking pending uploads
class UploadQueue extends Table {
  TextColumn get id => text()();
  TextColumn get documentId => text()();
  TextColumn get status => text()(); // pending, uploading, uploaded, failed
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  TextColumn get errorMessage => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Projects/Folders table for organizing documents
class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Scan sessions table for saving incomplete scanning sessions
class ScanSessions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().nullable()();
  TextColumn get projectId => text().nullable()();
  IntColumn get pageCount => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get status => text()(); // active, completed, abandoned

  @override
  Set<Column> get primaryKey => {id};
}

/// Scanned pages table for storing individual page data
class ScannedPages extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  IntColumn get pageNumber => integer()();
  TextColumn get imagePath => text()(); // Path to saved image
  BoolColumn get isProcessed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get capturedAt => dateTime()();
  TextColumn get corners => text().nullable()(); // JSON string of corner coordinates

  @override
  Set<Column> get primaryKey => {id};
}
