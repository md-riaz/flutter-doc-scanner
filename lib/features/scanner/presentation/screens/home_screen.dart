import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/scan_session_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        user?.name.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'User',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      user?.role.toUpperCase() ?? 'USER',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context,
                    ref: ref,
                    icon: Icons.camera_alt,
                    title: 'Scan Document',
                    onTap: () {
                      // Start a new scan session
                      ref.read(scanSessionProvider.notifier).startSession();
                      context.push('/scanner/camera');
                    },
                  ),
                  _buildMenuCard(
                    context,
                    ref: ref,
                    icon: Icons.folder,
                    title: 'My Documents',
                    onTap: () => context.push('/documents'),
                  ),
                  _buildMenuCard(
                    context,
                    ref: ref,
                    icon: Icons.folder_special,
                    title: 'Projects',
                    onTap: () => context.push('/projects'),
                  ),
                  _buildMenuCard(
                    context,
                    ref: ref,
                    icon: Icons.upload_file,
                    title: 'Upload Queue',
                    onTap: () => context.push('/upload-queue'),
                  ),
                  _buildMenuCard(
                    context,
                    ref: ref,
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () => context.push('/settings'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
