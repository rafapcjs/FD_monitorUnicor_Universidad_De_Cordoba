import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../core/exceptions.dart';
import 'models/auth_model.dart';

class NetworkService {
  static const Duration _timeout = Duration(seconds: 30);

  Future<AuthModel> login(String username, String password) async {
    try {
      final url = Uri.parse('${Constants.baseUrl}${Constants.loginEndpoint}');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(_timeout);

      return _handleAuthResponse(response);
    } on SocketException {
      throw NetworkException('Sin conexión a internet. Verifica tu red.');
    } on HttpException {
      throw NetworkException('Error de conexión al servidor.');
    } on FormatException {
      throw NetworkException('Respuesta inválida del servidor.');
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw UnknownException('Error inesperado: ${e.toString()}');
    }
  }

  AuthModel _handleAuthResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        try {
          return AuthModel.fromJson(json.decode(response.body));
        } catch (e) {
          throw ServerException('Respuesta del servidor malformada.');
        }
      case 400:
        throw ValidationException('Datos de login inválidos.');
      case 401:
        throw AuthenticationException('Credenciales incorrectas.');
      case 403:
        throw AuthorizationException('No tienes permisos para acceder.');
      case 404:
        throw NetworkException('Servicio no encontrado.');
      case 500:
        throw ServerException('Error interno del servidor.');
      case 502:
        throw NetworkException('Servidor no disponible.');
      case 503:
        throw NetworkException('Servicio temporalmente no disponible.');
      default:
        throw NetworkException(
          'Error del servidor (${response.statusCode})',
          statusCode: response.statusCode,
        );
    }
  }
}
