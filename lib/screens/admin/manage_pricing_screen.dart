import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_transit/state/admin_providers.dart';

class ManagePricingScreen extends ConsumerStatefulWidget {
  const ManagePricingScreen({super.key});

  @override
  ConsumerState<ManagePricingScreen> createState() =>
      _ManagePricingScreenState();
}

class _ManagePricingScreenState extends ConsumerState<ManagePricingScreen> {
  final _baseCtrl = TextEditingController();
  final _zoneCtrl = TextEditingController();
  final _premiumCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current state
    final pricing = ref.read(adminPricingProvider);
    _baseCtrl.text = pricing.basePrice.toString();
    _zoneCtrl.text = pricing.pricePerZone.toString();
    _premiumCtrl.text = pricing.premiumMultiplier.toString();
  }

  void _save() async {
    final base = double.tryParse(_baseCtrl.text) ?? 5.0;
    final zone = double.tryParse(_zoneCtrl.text) ?? 2.0;
    final premium = double.tryParse(_premiumCtrl.text) ?? 1.5;

    await ref
        .read(adminPricingProvider.notifier)
        .updatePricing(
          PricingModel(
            basePrice: base,
            pricePerZone: zone,
            premiumMultiplier: premium,
          ),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pricing Configuration Saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch for updates (though we manipulate local state before saving,
    // watching allows us to see if other admins changed it... mock-wise)
    // Actually, ideally we bind fields to local state and push to global on save.

    final isLoading = ref.watch(adminLoadingProvider);

    ref.listen<String?>(adminErrorProvider, (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Pricing'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        bottom: isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(color: Colors.white),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Base Fares', Icons.money),
            const SizedBox(height: 16),
            _buildNumberField(
              _baseCtrl,
              'Base Ticket Price (EGP)',
              'Starting price for any trip',
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Distance Multipliers', Icons.commute),
            const SizedBox(height: 16),
            _buildNumberField(
              _zoneCtrl,
              'Price Per Zone (EGP)',
              'Added for every 5 stations',
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Premium Services', Icons.star),
            const SizedBox(height: 16),
            _buildNumberField(
              _premiumCtrl,
              'Premium Multiplier (x)',
              'Multiplier for First Class',
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.save),
                label: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Configuration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField(
    TextEditingController ctrl,
    String label,
    String hint,
  ) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        helperText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
