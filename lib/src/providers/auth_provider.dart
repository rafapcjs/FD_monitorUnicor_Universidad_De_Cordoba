import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import '../core/exceptions.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'user_data';

  AuthProvider({required AuthRepository authRepository})
      : _authRepository = authRepository;

  AuthState _state = AuthState.initial;
  String? _accessToken;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthState get state => _state;
  String? get accessToken => _accessToken;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated && _accessToken != null;
  bool get isLoading => _state == AuthState.loading;

  Future<void> initializeAuth() async {
    try {
      _state = AuthState.loading;
      notifyListeners();

      final token = await _storage.read(key: _tokenKey);
      
      if (token != null && token.isNotEmpty) {
        if (!JwtDecoder.isExpired(token)) {
          _accessToken = token;
          await _loadUserFromToken(token);
          _state = AuthState.authenticated;
        } else {
          await logout();
        }
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      final authModel = await _authRepository.authenticate(username, password);
      
      if (!JwtDecoder.isExpired(authModel.accessToken)) {
        _accessToken = authModel.accessToken;
        await _loadUserFromToken(authModel.accessToken);
        
        // Verificar si es admin
        if (_currentUser?.role != 'admin') {
          throw AuthorizationException('Acceso denegado: No tienes permisos de administrador');
        }

        await _storage.write(key: _tokenKey, value: authModel.accessToken);
        if (_currentUser != null) {
          await _storage.write(key: _userKey, value: _currentUser!.toJson().toString());
        }

        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      } else {
        throw AuthenticationException('Token expirado');
      }
    } on AppException catch (e) {
      _state = AuthState.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'Error inesperado: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
    } catch (e) {
      debugPrint('Error clearing storage: $e');
    }

    _accessToken = null;
    _currentUser = null;
    _errorMessage = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  Future<void> _loadUserFromToken(String token) async {
    try {
      final decodedToken = JwtDecoder.decode(token);
      
      _currentUser = UserModel(
        id: decodedToken['sub']?.toString() ?? '',
        name: decodedToken['name']?.toString() ?? '',
        lastName: decodedToken['lastName']?.toString() ?? '',
        phone: decodedToken['phone']?.toString() ?? '',
        email: decodedToken['email']?.toString() ?? '',
        username: decodedToken['username']?.toString() ?? '',
        role: decodedToken['role']?.toString() ?? '',
        createdAt: decodedToken['createdAt']?.toString() ?? '',
        updatedAt: decodedToken['updatedAt']?.toString() ?? '',
      );
    } catch (e) {
      throw AuthenticationException('Error al procesar token de usuario');
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = _accessToken != null ? AuthState.authenticated : AuthState.unauthenticated;
    }
    notifyListeners();
  }
}