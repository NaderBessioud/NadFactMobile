import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInApi{
  static final _googleSingIn= GoogleSignIn(scopes: ['email']);

  static Future<GoogleSignInAccount?> login() =>_googleSingIn.signIn(
  );


}