import 'package:uuid/uuid.dart';

class MockPaymentService {
  Future<String?> processPayment(
    double amount,
    String cardNumber,
    String expiry,
    String cvv,
  ) async {
    await Future.delayed(const Duration(seconds: 2));
    if (cardNumber.length >= 15 && cvv.length == 3) {
      return const Uuid().v4(); // Return Transaction ID
    }
    throw Exception('فشلت عملية الدفع. تأكد من بيانات البطاقة'); // Fail
  }
}
