import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_transit/state/auth_provider.dart';
import 'package:smart_transit/state/settings_provider.dart';
import 'package:smart_transit/l10n/gen/app_localizations.dart';

// Mock provider for notification setting (UI only)
final notificationsProvider = StateProvider<bool>((ref) => true);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final isArabic = ref.watch(isArabicProvider);
    final isDark = ref.watch(isDarkModeProvider);
    final notificationsEnabled = ref.watch(notificationsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- User Information Section ---
            _buildUserInfoSection(context, user),
            const SizedBox(height: 24),

            // --- User Statistics Section ---
            _buildStatisticsSection(context),
            const SizedBox(height: 24),

            // --- Account Settings Section ---
            _buildSettingsSection(
              context,
              ref,
              isArabic,
              isDark,
              notificationsEnabled,
            ),
            const SizedBox(height: 24),

            // --- Admin Actions Section ---
            if (user?.isAdmin == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Card(
                  color: Colors.indigo.shade50,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.security, color: Colors.indigo),
                    title: Text(
                      l10n.adminDashboard,
                      style: const TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.indigo,
                    ),
                    onTap: () {
                      context.push('/admin');
                    },
                  ),
                ),
              ),

            // --- Account Actions Section ---
            _buildActionsSection(context, ref),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(BuildContext context, dynamic user) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? l10n.guestUser,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? 'guest@example.com',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  label: Text(
                    'ID: ${user?.id ?? "N/A"}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(width: 8),
                Chip(
                  avatar: Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green[700],
                  ),
                  label: Text(
                    user?.status ?? 'Active',
                    style: TextStyle(
                      color: Colors.green[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: Colors.green[100],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Mock Data
    const totalTrips = '42';
    const totalSpent = '\$124.50';
    const lastTrip = 'Central St ➔ North St';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.statistics,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  l10n.totalTrips,
                  totalTrips,
                  Icons.directions_bus,
                ),
                _buildContainerLine(context),
                _buildStatItem(
                  context,
                  l10n.totalSpent,
                  totalSpent,
                  Icons.attach_money,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1FAAF1).withAlpha(
                  (255 * 0.1).round(),
                ), // Replaced .withOpacity(0.3) with .withAlpha((255 * 0.1).round())
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.lastTrip,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withAlpha(
                              (255 * 0.3).round(),
                            ), // Replaced .withOpacity(0.3) with .withAlpha((255 * 0.3).round())
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          lastTrip,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildContainerLine(BuildContext context) {
    return Container(height: 40, width: 1, color: Colors.grey[300]);
  }

  Widget _buildSettingsSection(
    BuildContext context,
    WidgetRef ref,
    bool isArabic,
    bool isDark,
    bool notificationsEnabled,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.language),
            title: Text(l10n.language),
            value: isArabic,
            onChanged: (val) => ref.read(isArabicProvider.notifier).state = val,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: Text(l10n.darkMode),
            value: isDark,
            onChanged: (val) =>
                ref.read(isDarkModeProvider.notifier).state = val,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: Text(l10n.notifications),
            value: notificationsEnabled,
            onChanged: (val) =>
                ref.read(notificationsProvider.notifier).state = val,
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(l10n.resetPassword),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              context.push('/reset_password');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              l10n.logout,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              // Show confirmation dialog? Or just logout.
              // For simplicity, just logout as per existing flow.
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                // The router redirect should handle this, but just in case:
                // context.go('/welcome');
              }
            },
          ),
        ],
      ),
    );
  }
}
