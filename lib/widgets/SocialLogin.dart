


import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:nadfact2/DataService.dart';

import 'package:nadfact2/utils/global.colors.dart';


class SignInScreen extends StatelessWidget {
  DataService service=new DataService();



  Future<void> _handleSignOut() async {


  }
  Future<void> _handleSignIn(BuildContext context) async {
    service.handleGoogleSignIn(context);

  }
  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: Text(
            "or sign in with-",
            style: TextStyle(
                color: GlobalColors.textColor,
                fontWeight: FontWeight.w600
            ),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: MediaQuery.of(context).size.width * 0.2,
          child:  Row(
            children: [
              Expanded(
                  child:Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap : (){
                        _handleSignIn(context);
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        alignment: Alignment.center,
                        height: 55,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(.1),
                                  blurRadius: 10
                              )
                            ]
                        ),
                        child: SvgPicture.asset('assets/images/google.svg',height: 20),
                      ),
                    ),
                  )
              ),



            ],
          ),
        )
      ],
    );
  }

}


