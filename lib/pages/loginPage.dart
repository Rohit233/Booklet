// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ignore: use_key_in_widget_constructors
class LoginForm extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  late AuthCredential _phoneAuthCredential;
  String? _verificationId;
  // ignore: unused_field
  late int _code;
  Future<void> _submitPhoneNumber() async {
    /// NOTE: Either append your phone number country code or add in the code itself
    /// Since I'm in India we use "+91 " as prefix `phoneNumber`
    String phoneNumber = "+91 ${_phoneNumberController.text.toString().trim()}";


    /// The below functions are the callbacks, separated so as to make code more redable
    void verificationCompleted(AuthCredential phoneAuthCredential) {
      
      _phoneAuthCredential = phoneAuthCredential;
    }

    void verificationFailed(var error) {
      
    }

    void codeSent(String verificationId, [int? code]) {
      _verificationId = verificationId;
      _code = code!;
      setState(() {
        
      });
    }

    void codeAutoRetrievalTimeout(String verificationId) {

    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      /// Make sure to prefix with your country code
      phoneNumber: phoneNumber,

      /// `seconds` didn't work. The underlying implementation code only reads in `millisenconds`
      timeout: const Duration(milliseconds: 10000),

      /// If the SIM (with phoneNumber) is in the current device this function is called.
      /// This function gives `AuthCredential`. Moreover `login` function can be called from this callback
      /// When this function is called there is no need to enter the OTP, you can click on Login button to sigin directly as the device is now verified
      verificationCompleted: verificationCompleted,

      /// Called when the verification is failed
      verificationFailed: verificationFailed,

      /// This is called after the OTP is sent. Gives a `verificationId` and `code`
      codeSent: codeSent,

      /// After automatic code retrival `tmeout` this function is called
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    ); // All the callbacks are above
  }

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance
          .signInWithCredential(_phoneAuthCredential)
          .then((var authRes) {});
    // ignore: empty_catches
    } catch (e) {
      
    }
  }

  void _submitOTP() {
    /// get the `smsCode` from the user
    String smsCode = _otpController.text.toString().trim();

    /// when used different phoneNumber other than the current (running) device
    /// we need to use OTP to get `phoneAuthCredential` which is inturn used to signIn/login
    _phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: _verificationId!, smsCode: smsCode);

    _login();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Center(
              child: Form(
                child: _verificationId != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextFormField(
                            controller: _otpController,
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.lock_clock),
                                hintText: 'Enter OTP'),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                _submitOTP();
                              },
                              child: const Text('Submit'))
                        ],
                      )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextFormField(
                            controller: _phoneNumberController,
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.phone),
                                hintText: 'Phone Number'),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                _submitPhoneNumber();
                              },
                              child: const Text('Get Otp'))
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
