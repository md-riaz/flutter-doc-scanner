import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/scanner/presentation/screens/home_screen.dart';
import '../features/scanner/presentation/screens/camera_screen.dart';
import '../features/scanner/presentation/screens/page_preview_screen.dart';
import '../features/scanner/presentation/screens/scan_review_screen.dart';
import '../features/scanner/presentation/screens/corner_adjustment_screen.dart';
import '../features/pdf/presentation/screens/pdf_generation_screen.dart';
import '../features/documents/presentation/screens/documents_screen.dart';
import '../features/upload_queue/presentation/screens/upload_queue_screen.dart';
import '../features/projects/presentation/screens/projects_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/scanner',
        name: 'scanner',
        routes: [
          GoRoute(
            path: 'camera',
            name: 'scanner-camera',
            builder: (context, state) => const CameraScreen(),
          ),
          GoRoute(
            path: 'preview',
            name: 'scanner-preview',
            builder: (context, state) => const PagePreviewScreen(),
          ),
          GoRoute(
            path: 'review',
            name: 'scanner-review',
            builder: (context, state) => const ScanReviewScreen(),
          ),
          GoRoute(
            path: 'corner-adjustment/:pageId',
            name: 'scanner-corner-adjustment',
            builder: (context, state) {
              final pageId = state.pathParameters['pageId']!;
              return CornerAdjustmentScreen(pageId: pageId);
            },
          ),
        ],
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: '/pdf',
        name: 'pdf',
        routes: [
          GoRoute(
            path: 'generate',
            name: 'pdf-generate',
            builder: (context, state) => const PdfGenerationScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/documents',
        name: 'documents',
        builder: (context, state) {
          final projectId = state.uri.queryParameters['projectId'];
          final projectName = state.uri.queryParameters['projectName'];
          return DocumentsScreen(
            projectId: projectId,
            projectName: projectName,
          );
        },
      ),
      GoRoute(
        path: '/upload-queue',
        name: 'upload-queue',
        builder: (context, state) => const UploadQueueScreen(),
      ),
      GoRoute(
        path: '/projects',
        name: 'projects',
        builder: (context, state) => const ProjectsScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
