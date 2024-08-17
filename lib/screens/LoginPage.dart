import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nadfact2/api/GoogleSignInApi.dart';
import 'package:nadfact2/utils/global.colors.dart';
import 'package:nadfact2/widgets/FormButton.dart';
import 'package:nadfact2/widgets/SocialLogin.dart';
import 'package:nadfact2/widgets/TextForm.dart';

class Loginpage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}


class _LoginPageState extends State<Loginpage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future signInGoogle() async{
    await GoogleSignInApi.login();
  }

  @override
  void initState() {
    super.initState();
    emailController.addListener(_updateButtonState);
    passwordController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {});
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 150),
                  Container(
                    alignment: Alignment.center,
                    child:  Text("NadFact",
                      style: TextStyle(
                          color: GlobalColors.mainColor,
                          fontSize: 35,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  Text("Login to your account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: GlobalColors.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextForm(
                      controller: emailController,
                      text: "Email",
                      textInputType: TextInputType.emailAddress,
                      obscure: false),
                  const SizedBox(height: 6),
                  TextForm(
                      controller: passwordController,
                      text: "Password",
                      textInputType: TextInputType.text,
                      obscure: true),
                  const SizedBox(height: 6),

                  FormButton(context: context,email: emailController.text,pass: passwordController.text,),
                  SizedBox(height: 25),
                  SignInScreen()
                ],
              )

          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 50,
        color: Colors.white,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Vous n'avez pas un compte? "),
            Text(
              "Contactez FamyTech",
              style: TextStyle(
                  color: GlobalColors.mainColor
              ),
            )
          ],
        ),
      ),

    );
  }
}




