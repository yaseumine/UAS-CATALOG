import 'package:catalog/core/constants/api_constrants.dart';
import 'package:catalog/core/services/dio_clients.dart';
import 'package:catalog/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<String> verifyFirebaseToken(String firebaseToken) async {
    final response = await DioClient.instance.post(
      ApiConstants.verifyToken,
      data: {'firebase_token': firebaseToken},
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return data['access_token'] as String;
  }
}
