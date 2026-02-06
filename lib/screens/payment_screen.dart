import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_transit/models/ticket_and_landmark_models.dart';
import 'package:smart_transit/widgets/app_card.dart';
import 'package:smart_transit/services/mock_payment_service.dart';
import 'package:smart_transit/state/app_state.dart';
import 'package:smart_transit/state/auth_provider.dart';
import 'package:smart_transit/theme/app_layout.dart';
import 'package:smart_transit/l10n/gen/app_localizations.dart';

final paymentServiceProvider = Provider((ref) => MockPaymentService());

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    final route = ref.watch(routeResultProvider);
    final user = ref.watch(authProvider);
    final isLoading = ref.watch(paymentLoadingProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          l10n.payment,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppLayout.pagePadding),
        child: Column(
          children: [
            // Credit Card Visualization
            Container(
              height: 200,
              padding: const EdgeInsets.all(
                AppLayout.cardPadding,
              ), // Was 24, using cardPadding(16) or pagePadding(24). Let's use pagePadding
              decoration: BoxDecoration(
                color: const Color(0xFF0056D2), // Darker blue card
                borderRadius: BorderRadius.circular(
                  20,
                ), // Keeping 20 or moving to radiusMedium/Large. Let's keep 20 for now as it wasn't in list or unify. Instructions said "Identify all...". I'll use radiusLarge(25) close enough
                gradient: const LinearGradient(
                  colors: [Color(0xFF1FAAF1), Color(0xFF0056D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        FontAwesomeIcons.simCard,
                        color: Colors.amber,
                        size: 40,
                      ),
                      Icon(Icons.wifi, color: Colors.white),
                    ],
                  ),
                  const Text(
                    "4242 4242 4242 4242",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      letterSpacing: 2,
                      fontFamily: 'Courier',
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.expiryDate,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                          const Text(
                            "12/25",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.cardHolder,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            user?.name.toUpperCase() ??
                                l10n.guestUser.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppLayout.spacingXLarge),

            // Fields in AppCard
            AppCard(
              padding: const EdgeInsets.all(AppLayout.pagePadding),
              child: Column(
                children: [
                  _buildField(
                    l10n.cardNumber,
                    "0000 0000 0000 0000",
                    Icons.credit_card,
                  ),
                  const SizedBox(height: AppLayout.spacingMedium),
                  _buildField(l10n.cardHolder, l10n.nameOnCard, null),
                  const SizedBox(height: AppLayout.spacingMedium),
                  Row(
                    children: [
                      Expanded(child: _buildField(l10n.cvv, "123", Icons.lock)),
                      const SizedBox(width: AppLayout.spacingMedium),
                      Expanded(
                        child: _buildField(l10n.expiryDate, "MM/YY", null),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(value: false, onChanged: (v) {}),
                Text(
                  l10n.futureUse,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: AppLayout.spacingXLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.total, style: const TextStyle(color: Colors.grey)),
                Text(
                  "${route?.totalCost ?? 0.00} EGP",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isLoading || route == null
                    ? null
                    : () async {
                        ref.read(paymentLoadingProvider.notifier).state = true;
                        try {
                          // Mock Process Payment
                          await ref
                              .read(paymentServiceProvider)
                              .processPayment(
                                route.totalCost,
                                "4242424242424242", // Mock card
                                "12/25",
                                "123",
                              );

                          // Create Ticket
                          final ticket = TicketModel(
                            ticketId: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            userId: user?.id ?? 'guest',
                            sourceStationId: route.segments.first.from.id,
                            destinationStationId: route.segments.last.to.id,
                            sourceNameEn: route.segments.first.from.nameEn,
                            destinationNameEn: route.segments.last.to.nameEn,
                            price: route.totalCost,
                            timestamp: DateTime.now(),
                            transportTypes: route.segments
                                .map((s) => s.mode.name)
                                .toSet()
                                .toList(),
                          );

                          // Check history loading? It's handled inside addTicket via side-car
                          await ref
                              .read(historyProvider.notifier)
                              .addTicket(ticket);

                          if (context.mounted) {
                            context.go('/ticket', extra: ticket);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceAll('Exception: ', ''),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          ref.read(paymentLoadingProvider.notifier).state =
                              false;
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1FAAF1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppLayout.radiusLarge),
                  ),
                ),
                icon: const Icon(Icons.lock),
                label: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        l10n.payNow,
                        style: const TextStyle(
                          fontSize: 16,
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

  Widget _buildField(String label, String hint, IconData? icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppLayout.radiusSmall),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
          ),
        ),
      ],
    );
  }
}
