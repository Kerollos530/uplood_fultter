import 'package:smart_transit/core/api/api_client.dart';
import 'package:smart_transit/models/ticket_and_landmark_models.dart';

class TicketRemoteDataSource {
  final ApiClient _apiClient;

  TicketRemoteDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<List<TicketModel>> getTickets() async {
    try {
      final response = await _apiClient.client.get('/tickets');
      final List<dynamic> list = response.data;
      return list.map((e) => TicketModel.fromJson(e)).toList();
    } catch (e) {
      // Return empty or throw based on strategy. Throwing is better for "Remote" source.
      throw Exception('Failed to load tickets: ${e.toString()}');
    }
  }

  Future<void> saveTicket(TicketModel ticket) async {
    try {
      await _apiClient.client.post(
        '/tickets',
        data: ticket.toJson(), // toJson() sends "ticketId" (camelCase).
        // If Backend needs snake_case, we need a DTO or modified toJson.
        // For now, assuming backend ignores extra fields or handles camelCase via Pydantic alias.
        // Or we rely on the modification we might make to toJson or just explicit map here.
      );
    } catch (e) {
      throw Exception('Failed to save ticket: ${e.toString()}');
    }
  }
}
