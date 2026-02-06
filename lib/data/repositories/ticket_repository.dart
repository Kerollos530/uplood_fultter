import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_transit/models/ticket_and_landmark_models.dart';

class TicketRepository {
  static const String _historyKey = 'ticket_history';

  Future<List<TicketModel>> getTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList(_historyKey) ?? [];
    return list.map((e) => TicketModel.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveTicket(TicketModel ticket) async {
    final prefs = await SharedPreferences.getInstance();
    final List<TicketModel> currentHistory = await getTickets();

    final updatedHistory = [...currentHistory, ticket];
    final List<String> list = updatedHistory
        .map((e) => jsonEncode(e.toJson()))
        .toList();

    await prefs.setStringList(_historyKey, list);
  }
}
