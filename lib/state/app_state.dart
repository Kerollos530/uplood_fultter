import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_transit/models/route_model.dart';

import 'package:smart_transit/models/ticket_and_landmark_models.dart';
import 'package:smart_transit/services/routing_service.dart';
import 'package:smart_transit/data/repositories/station_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ROUTING
// ROUTING
final routingServiceProvider = Provider((ref) => RoutingService());
final stationRepositoryProvider = Provider((ref) => StationRepository());

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

  HistoryNotifier(this._ref) : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    _ref.read(historyLoadingProvider.notifier).state = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> list = prefs.getStringList('ticket_history') ?? [];
      state = list.map((e) => TicketModel.fromJson(jsonDecode(e))).toList();
    } catch (e) {
      _ref.read(historyErrorProvider.notifier).state = e.toString();
    } finally {
      _ref.read(historyLoadingProvider.notifier).state = false;
    }
  }

  Future<void> addTicket(TicketModel ticket) async {
    _ref.read(historyLoadingProvider.notifier).state =
        true; // Though often instant
    try {
      state = [...state, ticket];
      final prefs = await SharedPreferences.getInstance();
      final List<String> list = state
          .map((e) => jsonEncode(e.toJson()))
          .toList();
      await prefs.setStringList('ticket_history', list);
    } catch (e) {
      _ref.read(historyErrorProvider.notifier).state = "Failed to save ticket";
    } finally {
      _ref.read(historyLoadingProvider.notifier).state = false;
    }
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<TicketModel>>(
      (ref) => HistoryNotifier(ref),
    );
