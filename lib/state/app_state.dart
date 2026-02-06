import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_transit/models/route_model.dart';

import 'package:smart_transit/models/ticket_and_landmark_models.dart';
import 'package:smart_transit/services/routing_service.dart';
import 'package:smart_transit/data/repositories/station_repository.dart';

import 'package:smart_transit/data/repositories/ticket_repository.dart';

// ROUTING
// ROUTING
final routingServiceProvider = Provider((ref) => RoutingService());
final stationRepositoryProvider = Provider((ref) => StationRepository());
final ticketRepositoryProvider = Provider((ref) => TicketRepository());

final routeLoadingProvider = StateProvider<bool>((ref) => false);
final routeErrorProvider = StateProvider<String?>((ref) => null);

final routeResultProvider = StateProvider<RouteModel?>((ref) => null);

// PAYMENT (Local or scoped, but defining global companion for ease)
final paymentLoadingProvider = StateProvider<bool>((ref) => false);

// HISTORY
final historyLoadingProvider = StateProvider<bool>((ref) => false);
final historyErrorProvider = StateProvider<String?>((ref) => null);

class HistoryNotifier extends StateNotifier<List<TicketModel>> {
  final Ref _ref;
  final TicketRepository _repository;

  HistoryNotifier(this._ref, this._repository) : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    _ref.read(historyLoadingProvider.notifier).state = true;
    try {
      state = await _repository.getTickets();
    } catch (e) {
      _ref.read(historyErrorProvider.notifier).state = e.toString();
    } finally {
      _ref.read(historyLoadingProvider.notifier).state = false;
    }
  }

  Future<void> addTicket(TicketModel ticket) async {
    _ref.read(historyLoadingProvider.notifier).state = true;
    try {
      await _repository.saveTicket(ticket);
      // OPTIMISTIC UPDATE: Update UI state immediately after successful save
      // Alternatively, re-fetch from repo to ensure sync
      state = [...state, ticket];
    } catch (e) {
      _ref.read(historyErrorProvider.notifier).state = "Failed to save ticket";
    } finally {
      _ref.read(historyLoadingProvider.notifier).state = false;
    }
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<TicketModel>>((ref) {
      final repo = ref.watch(ticketRepositoryProvider);
      return HistoryNotifier(ref, repo);
    });
