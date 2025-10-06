import 'package:converter_app/screens/signin_screen.dart';
import 'package:converter_app/screens/signup_screen.dart';
import 'package:converter_app/theme/theme.dart';
import 'package:converter_app/widgets/custom_scaffold.dart';
import 'package:converter_app/widgets/welcome_button.dart';
import 'package:flutter/material.dart';
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
       children: [
         Flexible(
           flex: 1,
           child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 40.0),
             child: Center(
               child: RichText(
                 textAlign: TextAlign.center,
                 text: const TextSpan(
                   children:<InlineSpan>[
                     TextSpan(
                       text: 'Welcome \n',
                       style: TextStyle(
                         color: Colors.white,
                         fontSize: 45,
                         fontWeight: FontWeight.w600,
                       )),
                     TextSpan(
                       text:
                         '\n ',
                       style: TextStyle(
                       fontSize: 20,  
                     )),
                   ],
                 ),
             ),
           ),
         )),
         Flexible(
           flex: 1,
             child:Align(
               alignment: Alignment.bottomRight,
               child: Row(
                 children: [
                   Expanded(
                     child : WelcomeButton(
                       buttonText: 'Sign in',
                       onTap: SignInScreen(),
                       color: Colors.transparent,
                       textColor: lightColorScheme.primary,
                     ),
                   ),
                   Expanded(
                     child : WelcomeButton(
                       buttonText: 'Sign up',
                       onTap: const SignUpScreen(),
                       color: Colors.white,
                       textColor: lightColorScheme.primary,
                     ),
                   ),
                 ],
               ),
             )),
       ],
      ),
    );
  }
}
