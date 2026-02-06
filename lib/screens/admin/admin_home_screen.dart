import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_transit/theme/app_layout.dart';
import 'package:smart_transit/l10n/gen/app_localizations.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminDashboard),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppLayout.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAdminCard(
              context,
              title: l10n.manageStations,
              icon: Icons.train,
              color: Colors.blueAccent,
              onTap: () => context.push('/admin/stations'),
            ),
            const SizedBox(height: AppLayout.spacingLarge),
            _buildAdminCard(
              context,
              title: l10n.managePricing,
              icon: Icons.attach_money,
              color: Colors.green,
              onTap: () => context.push('/admin/pricing'),
            ),
            const Spacer(),
            Text(
              l10n.adminModeWarning,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppLayout.radiusMedium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppLayout.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppLayout.spacingXLarge),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(width: AppLayout.spacingLarge),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
