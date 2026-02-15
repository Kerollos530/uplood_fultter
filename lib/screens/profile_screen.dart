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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final isArabic = ref.watch(isArabicProvider);
    final isDark = ref.watch(isDarkModeProvider);
    final notificationsEnabled = ref.watch(notificationsProvider);
    final l10n = AppLocalizations.of(context)!;

    // Hardcoded user data for design match as per prompt "Ahmed Saeed"
    // In real app, stick to user.name.
    // Using user data if available, else mockup to match prompt request?
    // User requested "Bold name text: أحمد سعيد". I will show user.name but fallback to prompt example if null.
    // Actually, better to stick to real data for "functionality", but style it as requested.

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.profile,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        // RTL Layout: Leading is correctly placed on Right for Arabic.
        // We rely on standard Flutter RTL handling.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/planner'), // Or context.pop()
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

            // --- Profile Card ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(
                          0xFFE0F7FA,
                        ), // Light cyan bg
                        backgroundImage: const NetworkImage(
                          "https://i.pravatar.cc/300",
                        ), // Placeholder
                        // If image fails or null, child icon
                        onBackgroundImageError: (_, __) {},
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Color(0xFF1FAAF1),
                        ),
                      ),
                      // Small Edit Icon
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1FAAF1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? "أحمد سعيد",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? "ahmed.saeed@example.com",
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- Activity Section ---
            _buildSectionTitle(l10n.myActivity), // "نشاطي"
            const SizedBox(height: 16),
            _buildSettingsContainer(
              child: ListTile(
                leading: const Icon(Icons.history, color: Color(0xFF1FAAF1)),
                title: Text(
                  l10n.tripHistory,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: () => context.push('/history'),
              ),
            ),

            const SizedBox(height: 32),

            // --- Settings Section ---
            _buildSectionTitle(l10n.actions), // "الإعدادات"
            const SizedBox(height: 16),

            // Dark Mode
            _buildSettingsContainer(
              child: SwitchListTile(
                secondary: const Icon(
                  Icons.dark_mode_outlined,
                  color: Color(0xFF2C3E50),
                ),
                title: Text(
                  l10n.darkMode,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                value: isDark,
                onChanged: (val) =>
                    ref.read(isDarkModeProvider.notifier).state = val,
                activeColor: const Color(0xFF1FAAF1),
              ),
            ),
            const SizedBox(height: 16),

            // Language
            _buildSettingsContainer(
              child: ListTile(
                leading: const Icon(Icons.language, color: Color(0xFF1FAAF1)),
                title: Text(
                  l10n.language,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isArabic ? "العربية" : "English",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ],
                ),
                onTap: () {
                  ref.read(isArabicProvider.notifier).state = !isArabic;
                },
              ),
            ),
            const SizedBox(height: 16),

            // Notifications
            _buildSettingsContainer(
              child: SwitchListTile(
                secondary: const Icon(
                  Icons.notifications_none,
                  color: Colors.orange,
                ),
                title: Text(
                  l10n.notifications,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                value: notificationsEnabled,
                onChanged: (val) =>
                    ref.read(notificationsProvider.notifier).state = val,
                activeColor: const Color(0xFF1FAAF1),
              ),
            ),

            const SizedBox(height: 48),

            // --- Logout ---
            TextButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
              },
              child: Text(
                l10n.logout,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSettingsContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // No shadow for small items per prompt request "clean and minimal" or "rounded containers"
        // Prompt says "Create separate rounded containers".
      ),
      child: child,
    );
  }
}

// Extension for new keys if missing pending generation
extension AppLocalizationsExt on AppLocalizations {
  String get myActivity => "نشاطي";
  String get tripHistory => "سجل الرحلات";
}
