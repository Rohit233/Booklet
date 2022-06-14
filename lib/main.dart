import 'package:booklet/pages/home.dart';
import 'package:booklet/pages/loginPage.dart';
import 'package:booklet/services/user_servie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp().whenComplete((){
     runApp(const MyApp());

  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, AsyncSnapshot<User?> user) {
          if(user.connectionState == ConnectionState.waiting){
            return const Center(
                child: CircularProgressIndicator(),
            );
          }
          if(user.hasData){
            UserService.userData = user.data;
            return const Home();
          }
          return  LoginForm();
        }
      )
    );
  }
}

