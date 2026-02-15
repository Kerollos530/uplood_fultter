import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_transit/models/ticket_and_landmark_models.dart';

class TicketRepository {
  // ignore: unused_field
  static const String _historyKey = 'ticket_history';

  TicketRepository();

  Future<List<TicketModel>> getTickets() async {
    // MOCK Implementation
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList(_historyKey) ?? [];
    return list.map((e) => TicketModel.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveTicket(TicketModel ticket) async {
    await saveTickets([ticket]);
  }

  Future<void> saveTickets(List<TicketModel> tickets) async {
    // MOCK Implementation
    final prefs = await SharedPreferences.getInstance();
    // We fetch current history to append; in a real app this might be optimized
    final List<TicketModel> currentHistory = await getTickets();

    final updatedHistory = [...currentHistory, ...tickets];
    final List<String> list = updatedHistory
        .map((e) => jsonEncode(e.toJson()))
        .toList();

    await prefs.setStringList(_historyKey, list);
  }
}
