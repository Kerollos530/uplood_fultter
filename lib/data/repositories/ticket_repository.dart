import 'package:smart_transit/data/datasources/ticket_remote_source.dart';
import 'package:smart_transit/models/ticket_and_landmark_models.dart';

class TicketRepository {
  final TicketRemoteDataSource _remoteSource;

  // ignore: unused_field
  static const String _historyKey = 'ticket_history';

  TicketRepository({TicketRemoteDataSource? remoteSource})
    : _remoteSource = remoteSource ?? TicketRemoteDataSource();

  Future<List<TicketModel>> getTickets() async {
    // API Implementation
    return await _remoteSource.getTickets();

    // MOCK Implementation (Commented out for Rollback)
    /*
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList(_historyKey) ?? [];
    return list.map((e) => TicketModel.fromJson(jsonDecode(e))).toList();
    */
  }

  Future<void> saveTicket(TicketModel ticket) async {
    // API Implementation
    await _remoteSource.saveTicket(ticket);

    // MOCK Implementation (Commented out for Rollback)
    /*
    final prefs = await SharedPreferences.getInstance();
    final List<TicketModel> currentHistory = await getTickets(); // Careful: This would call API now

    final updatedHistory = [...currentHistory, ticket];
    final List<String> list = updatedHistory
        .map((e) => jsonEncode(e.toJson()))
        .toList();

    await prefs.setStringList(_historyKey, list);
    */
  }
}
