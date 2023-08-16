import 'package:flutter/material.dart';

// Screen Full Height & Weight function
double ScreenHeight(context) {
  double screenHeight = MediaQuery.of(context).size.height;
  return screenHeight;
}
double ScreenWidth(context) {
  double screenWeight = MediaQuery.of(context).size.width;
  return screenWeight;
}

// User SingIn State
var UserSignInOrNot;
void setUserState(value) {
  if(value == null){
    UserSignInOrNot = false;
  } else{
    UserSignInOrNot = value;
  }
}
bool getUserState() {
  return UserSignInOrNot;
}

