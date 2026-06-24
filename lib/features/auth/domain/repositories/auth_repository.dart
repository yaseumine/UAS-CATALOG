abstract class AuthRepository {
  //supaya nanti kalau aku mau ganti
  //implementasi repository, aku gak perlu ganti
  // di banyak tempat, cukup ganti di sini aja
  Future<String> verifyFirebaseToken(String firebaseToken);
}
