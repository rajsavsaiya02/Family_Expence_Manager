import 'package:fem/Database/FireStore_Database/User_Profile/user_profile_manage.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../Utility/Colors.dart';
import '../../Utility/Values.dart';
import '../UserSignIn/user_sign_in.dart';

class UserSignUp extends StatefulWidget {
  const UserSignUp({Key? key}) : super(key: key);

  @override
  State<UserSignUp> createState() => _UserSignUpState();
}

class _UserSignUpState extends State<UserSignUp> {
  // Form Keys
  final _userName = GlobalKey<FormFieldState>();
  final _userEmailId = GlobalKey<FormFieldState>();
  final _userPhoneNumber = GlobalKey<FormFieldState>();
  final _userPassword = GlobalKey<FormFieldState>();
  final _userConfirmPassword = GlobalKey<FormFieldState>();

  //User Name
  TextEditingController _NameController = TextEditingController();

  //Email ID
  String _email = "";
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

  //Phone Number
  TextEditingController _phoneNumberController = TextEditingController();

  //Password Validation
  bool _obscureText = true;
  String _password = "";
  TextEditingController _passwordController = TextEditingController();

  //Confirm Password Validation
  TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: TextButton(
        onPressed: () {
          Navigator.pop(context);
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
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 18.0, horizontal: 46.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              "Create Account",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 46,
                                  fontWeight: FontWeight.w700),
                            ),
                          )),
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
                        // User Name
                        TextFormField(
                          key: _userName,
                          controller: _NameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter Full Name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 16,
                        ),
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
                        SizedBox(height: 16.0),
                        // Phone Number Text field
                        TextFormField(
                          key: _userPhoneNumber,
                          controller: _phoneNumberController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Enter your phone number',
                            prefixIcon: Icon(Bootstrap.phone),
                            labelText: 'Phone Number (Optional)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return null;
                            } else if (!RegExp(r"^(?:[+0]9)?[0-9]{10}$")
                                .hasMatch(value)) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        // Password text form field
                        TextFormField(
                          key: _userPassword,
                          controller: _passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: "Enter Your Password",
                            prefixIcon: Icon(Bootstrap.key_fill),
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
                        SizedBox(height: 16.0),
                        // Confirm Password text form field
                        TextFormField(
                          key: _userConfirmPassword,
                          controller: _confirmPasswordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            hintText: "Retype Your Password",
                            prefixIcon: Icon(Bootstrap.key_fill),
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
                              return 'Confirm Password is required.';
                            } else if (value.toString() !=
                                _passwordController.text.toString()) {
                              return 'Password not match';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24.0),
                        // Login button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_userName.currentState!.validate() &&
                                        _userEmailId.currentState!.validate() &&
                                        _userPhoneNumber.currentState!.validate() &&
                                        _userPassword.currentState!.validate() &&
                                        _userConfirmPassword.currentState!
                                            .validate()) {
                                userSignUp(context,_NameController.text,
                                  _emailController.text,
                                  _phoneNumberController.text,
                                  _passwordController.text,);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18.0, vertical: 12.0),
                              child: Text(
                                'Sign Up',
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
                        //
                        // SizedBox(
                        //   height: 70.0,
                        //   width: ScreenWidth(context),
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       Text(
                        //         '- OR -',
                        //         style: TextStyle(fontSize: 18),
                        //       ),
                        //       SizedBox(
                        //         height: 10,
                        //       ),
                        //       Text(
                        //         "Sing Up With",
                        //         style: TextStyle(fontWeight: FontWeight.w400),
                        //       ),
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
                        //           ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 6.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("I already have an account?"),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => UserSignIn()));
                              },
                              child: Text(
                                "Sign In",
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
