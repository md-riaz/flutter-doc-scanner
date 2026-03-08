import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tables.dart';

part 'app_database.g.dart';

// Provider for the database
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

@DriftDatabase(tables: [
  Documents,
  UploadQueue,
  Projects,
  ScanSessions,
  ScannedPages,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future migrations here
      },
    );
  }

  // Documents queries
  Future<List<Document>> getAllDocuments() => select(documents).get();

  Future<Document?> getDocumentById(String id) =>
      (select(documents)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<List<Document>> getDocumentsByProject(String projectId) =>
      (select(documents)..where((tbl) => tbl.projectId.equals(projectId))).get();

  Future<List<Document>> getPendingUploads() =>
      (select(documents)..where((tbl) => tbl.isUploaded.equals(false))).get();

  Future<int> insertDocument(DocumentsCompanion document) =>
      into(documents).insert(document);

  Future<bool> updateDocument(DocumentsCompanion document) =>
      update(documents).replace(document);

  Future<int> deleteDocument(String id) =>
      (delete(documents)..where((tbl) => tbl.id.equals(id))).go();

  // Upload queue queries
  Future<List<UploadQueueData>> getAllQueueItems() => select(uploadQueue).get();

  Future<UploadQueueData?> getQueueItemById(String id) =>
      (select(uploadQueue)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<List<UploadQueueData>> getPendingQueueItems() =>
      (select(uploadQueue)..where((tbl) => tbl.status.equals('pending'))).get();

  Future<int> insertQueueItem(UploadQueueCompanion item) =>
      into(uploadQueue).insert(item);

  Future<bool> updateQueueItem(UploadQueueCompanion item) =>
      update(uploadQueue).replace(item);

  Future<int> deleteQueueItem(String id) =>
      (delete(uploadQueue)..where((tbl) => tbl.id.equals(id))).go();

  // Projects queries
  Future<List<Project>> getAllProjects() => select(projects).get();

  Future<Project?> getProjectById(String id) =>
      (select(projects)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<int> insertProject(ProjectsCompanion project) =>
      into(projects).insert(project);

  Future<bool> updateProject(ProjectsCompanion project) =>
      update(projects).replace(project);

  Future<int> deleteProject(String id) =>
      (delete(projects)..where((tbl) => tbl.id.equals(id))).go();

  // Scan sessions queries
  Future<List<ScanSession>> getAllSessions() => select(scanSessions).get();

  Future<ScanSession?> getSessionById(String id) =>
      (select(scanSessions)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<List<ScanSession>> getActiveSessions() =>
      (select(scanSessions)..where((tbl) => tbl.status.equals('active'))).get();

  Future<int> insertSession(ScanSessionsCompanion session) =>
      into(scanSessions).insert(session);

  Future<bool> updateSession(ScanSessionsCompanion session) =>
      update(scanSessions).replace(session);

  Future<int> deleteSession(String id) =>
      (delete(scanSessions)..where((tbl) => tbl.id.equals(id))).go();

  // Scanned pages queries
  Future<List<ScannedPage>> getPagesBySession(String sessionId) =>
      (select(scannedPages)..where((tbl) => tbl.sessionId.equals(sessionId))
        ..orderBy([(t) => OrderingTerm(expression: t.pageNumber)])).get();

  Future<ScannedPage?> getPageById(String id) =>
      (select(scannedPages)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<int> insertPage(ScannedPagesCompanion page) =>
      into(scannedPages).insert(page);

  Future<bool> updatePage(ScannedPagesCompanion page) =>
      update(scannedPages).replace(page);

  Future<int> deletePage(String id) =>
      (delete(scannedPages)..where((tbl) => tbl.id.equals(id))).go();

  Future<int> deletePagesBySession(String sessionId) =>
      (delete(scannedPages)..where((tbl) => tbl.sessionId.equals(sessionId))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'doc_scanner.db'));
    return NativeDatabase(file);
  });
}
