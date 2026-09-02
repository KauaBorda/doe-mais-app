import '../core/network/api_client.dart';
import '../models/doador_session.dart';

class AuthService {
  Future<DoadorSession> login({required String email, required String senha}) async {
    try {
      final response = await ApiClient.instance.dio.post('/auth/login', data: {
        'email': email,
        'senha': senha,
      });
      return DoadorSession.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }
}
