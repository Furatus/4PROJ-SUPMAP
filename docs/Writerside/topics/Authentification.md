# Authentification

### Technologies utilisées
- http : envoi de requêtes réseau pour se connecter au backend.
- flutter_secure_storage : stockage sécurisé du token JWT et des données utilisateur.
- provider : gestion de l’état global de l’utilisateur connecté.
- dart:convert : encodage/décodage des objets JSON.
- Navigator : navigation après authentification.
- google_sign_in : pour une connection avec google

### Fonctionnement
Connexion via login(email, password) :
- Envoie les identifiants en POST à l’API.
- Si les identifiants sont valides, récupère un token JWT et les données de l'utilisateur.
- Utilise UserProvider pour stocker ces données et maintenir l'état de session.

UserProvider :
- Stocke de façon sécurisée les données utilisateur et le token.
- Charge automatiquement ces données au démarrage.
- Vérifie la validité du token JWT (date d’expiration incluse).
- Fournit des getters utiles pour accéder au nom, email, rôle, etc.

```dart
class UserProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Map<String, dynamic>? _user;
  String? _token;

  Map<String, dynamic>? get user => _user;

  bool get isLogged => _user != null;

  String? get userId => _user?['id'];

  String? get userName => _user?['pseudo'];

  String? get userEmail => _user?['email'];

  String? get userRole => _user?['role'];

  String? get userPicture => _user?['picture'];

  String? get token => _token;

  UserProvider() {
    _loadUserFromStorage(); // auto init
    _loadTokenFromStorage(); // auto init
    _checkTokenValidity();
  }

  Future<void> _checkTokenValidity() async {
    if (_token == null) return;

    try {
      final parts = _token!.split('.');
      if (parts.length != 3) {
        removeUser(); // Token invalide
        return;
      }

      final payload = jsonDecode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final exp = payload['exp'] as int?;
      if (exp == null || DateTime.now().millisecondsSinceEpoch / 1000 > exp) {
        removeUser(); // Token expiré
      }
    } catch (e) {
      removeUser(); // Erreur lors de la vérification
    }
  }

  Future<void> setUser(Map<String, dynamic> user) async {
    _user = user;
    await _storage.write(key: 'user', value: jsonEncode(user));
    notifyListeners();
  }

  void removeUser() async {
    _user = null;
    await _storage.delete(key: 'user');
    await _storage.delete(key: 'token');
    notifyListeners();
  }

  Future<void> _loadUserFromStorage() async {
    final userJson = await _storage.read(key: 'user');
    if (userJson != null) {
      _user = jsonDecode(userJson);
      notifyListeners();
    }
  }

  Future<void> setToken(String token) async {
    _token = token;
    await _storage.write(key: 'token', value: token);
    notifyListeners();
  }

  Future<void> _loadTokenFromStorage() async {
    final token = await _storage.read(key: 'token');
    if (token != null) {
      _token = token;
      notifyListeners();
    }
  }
}
```

Voici la connection avec google

```dart
Future<void> _handleGoogleSignIn(BuildContext context) async {
try {
final GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();
if (googleAccount == null) return;
final GoogleSignInAuthentication googleAuthentication =
await googleAccount.authentication;
final idToken = googleAuthentication.idToken;

      // Envoi du token à ton backend
      final response = await http.post(
        Uri.parse('$apiUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );

      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['token'];
        userProvider.setToken(token);

        final user = jsonDecode(response.body)['user'];
        userProvider.setUser(user);

        Navigator.pushNamed(context, '/');
        return jsonDecode(response.body);
      } else {
        print('Erreur de connexion backend : ${response.statusCode}');
        print('Erreur de connexion backend : ${response.body}');
      }
    } catch (error) {
      print('Erreur Google Sign-In : $error');
    }
}
```