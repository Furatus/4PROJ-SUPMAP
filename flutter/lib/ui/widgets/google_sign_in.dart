import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:supmap/providers/user_provider.dart';

class GoogleLoginButton extends StatefulWidget {
  const GoogleLoginButton({super.key});

  @override
  _GoogleLoginButtonState createState() => _GoogleLoginButtonState();
}

class _GoogleLoginButtonState extends State<GoogleLoginButton> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: dotenv.env['GOOGLE_ANDROID_CLIENT_ID'],
    scopes: [
      'email',
      'profile',
    ],
  );
  late UserProvider userProvider;

  final String? apiUrl = dotenv.env['SERVER_API_URL'];

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
  }

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

        Navigator.pushReplacementNamed(context, '/');
        return jsonDecode(response.body);
      } else {
        print('Erreur de connexion backend : ${response.statusCode}');
        print('Erreur de connexion backend : ${response.body}');
      }
    } catch (error) {
      print('Erreur Google Sign-In : $error');
    }
  }



  @override
  Widget build(BuildContext context) {
    return SignInButton(
      Buttons.Google,
      text: 'Se connecter avec Google',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      onPressed: () => _handleGoogleSignIn(context),
    );
  }
}
