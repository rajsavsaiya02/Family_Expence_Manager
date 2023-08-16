import 'package:fem/Database/FireStore_Database/User_Profile/user_profile_manage.dart';
import 'package:fem/Screens/Home/home.dart';
import 'package:fem/Utility/Values.dart';
import 'package:fem/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utility/Colors.dart';
import '../OnBoarding/on_boarding.dart';

class UserSignIn extends StatefulWidget {
  const UserSignIn({Key? key}) : super(key: key);

  @override
  State<UserSignIn> createState() => _UserSignInState();
}

class _UserSignInState extends State<UserSignIn> {
  // Form Keys
  final _userEmailId = GlobalKey<FormFieldState>();
  final _userPassword = GlobalKey<FormFieldState>();

  //Email ID Validation
  late String _email;
  TextEditingController _emailController = TextEditingController();

  //Email Format Checking Function
  bool _validateEmail(String value) {
    // RegExp pattern to validate email
    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regExp = new RegExp(pattern);

    if (value.length == 0) {
      return false;
    } else if (!regExp.hasMatch(value)) {
      return false;
    } else {
      return true;
    }
  }

  //Password Validation
  bool _obscureText = true;
  late String _password;
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Welcome_Screen()));
          },
          style: ButtonStyle(
            shape: MaterialStateProperty.all<CircleBorder>(
              CircleBorder(),
            ),
          ),
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: ScreenWidth(context),
          constraints: BoxConstraints(
            maxHeight: ScreenHeight(context),
            maxWidth: ScreenWidth(context),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  Color.fromRGBO(129, 38, 198, 1),
                  Color.fromRGBO(27, 196, 231, 1)
                ]),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 18.0, horizontal: 46.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Login",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 46,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Welcome! \nPlease log in to continue",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      )),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Email ID text field
                        TextFormField(
                          key: _userEmailId,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            prefixIcon: Icon(Icons.email),
                            labelText: 'Email ID',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Email is required.';
                            } else if (!_validateEmail(value)) {
                              return 'Please enter a valid email address.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24.0),
                        // Password text field
                        TextFormField(
                          key: _userPassword,
                          controller: _passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: "Enter Your Password",
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Password is required.';
                            } else if (value.length < 6) {
                              return 'Password must be at least 6 characters long.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 4.0),
                        // Forgot password link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                var _forgotEmailId =
                                    _emailController.text.trim();
                                if (_userEmailId.currentState!.validate()) {
                                  showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ResetPasswordDialog(
                                          _forgotEmailId);
                                    },
                                  );
                                }
                              },
                              child: Text(
                                'Forgot password',
                                style: TextStyle(
                                    color: secondary, letterSpacing: 1),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 28.0),
                        // Login button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_userEmailId.currentState!.validate() &&
                                  _userPassword.currentState!.validate()) {
                                  userSignIn(context, _emailController.text, _passwordController.text);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18.0, vertical: 12.0),
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Colors.white, // Button text color
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              elevation: 4,
                              // Elevation to add shadow to the button
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8), // Button border radius
                              ),
                            ),
                          ),
                        ),
                        // SizedBox(height: 70.0,width: ScreenWidth(context),
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       Text('- OR -',style: TextStyle(fontSize: 18),),
                        //       SizedBox(height: 10,),
                        //       Text("Sing In With", style: TextStyle(fontWeight: FontWeight.w400),),
                        //     ],
                        //   ),
                        // ),
                        // // Google and Facebook login buttons
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     ElevatedButton(
                        //       onPressed: () {},
                        //       child: Padding(
                        //         padding: const EdgeInsets.all(8.0),
                        //         child: Logo(Logos.google),
                        //       ),
                        //       style: ElevatedButton.styleFrom(
                        //         backgroundColor: Colors.white,
                        //         shape: CircleBorder(), // Button border radius
                        //       ),
                        //     ),
                        //     ElevatedButton(
                        //       onPressed: () {},
                        //       child: Padding(
                        //         padding: const EdgeInsets.all(8.0),
                        //         child: Logo(Logos.facebook_f),
                        //       ),
                        //       style: ElevatedButton.styleFrom(
                        //           backgroundColor: Colors.white,
                        //           shape: CircleBorder() // Button border radius
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 12.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("I don't have an account?"),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => OnBoarding()));
                              },
                              child: Text(
                                "Create Account",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResetPasswordDialog extends StatelessWidget {
  var _forgotEmailId = "";

  ResetPasswordDialog(String forgotEmailId) {
    this._forgotEmailId = forgotEmailId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Reset Password?'),
      content: Text('Are you sure you want to reset your password?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await FirebaseAuth.instance
                .sendPasswordResetEmail(email: _forgotEmailId)
                .then((value) {
              Navigator.of(context).pop(false);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Password Reset"),
              ));
            }).onError((error, stackTrace) {
              print("Error (User Reset Password): ${error.toString()}");
            });
          },
          child: Text('Reset'),
        ),
      ],
    );
  }
}
