class TokenManager {
  static String? token;

  static void setToken(String newToken) {
    token = newToken;
  }

  static String? getToken() {
    return token;
  }
}