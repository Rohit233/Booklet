import 'dart:io';

import 'package:booklet/services/user_servie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../model/book.dart';

class BookListing {
 static Future addBook(Book newBook) async {
   await FirebaseFirestore.instance.collection('BookCollection').add({
      'title': newBook.title ?? newBook.oTitle,
      'author': newBook.author ?? newBook.oAuth,
      'pages': newBook.pages,
      'link': newBook.link,
      'path': newBook.path,
      'storeLink': newBook.storeLink,
      'user_id': UserService.userData?.uid,
      'isReadingStart': newBook.isReadingStart,
      'isReadingComplete': newBook.isReadingComplete
    });
    return;
  }

  static Future completeBook(String? bookId)async{
      await FirebaseFirestore.instance.collection('BookCollection').doc(bookId).update({
         'isReadingComplete': true,
         'isReadingStart': false
      });
      return;
  }
  
  static Future startBook(String? bookId)async{
    await FirebaseFirestore.instance.collection('BookCollection').doc(bookId).update({
      'isReadingStart': true
    });
    return;
  } 
  static Stream<QuerySnapshot<Map<String, dynamic>>> getCurrentBook(){
   return  FirebaseFirestore.instance.collection('BookCollection').where('user_id',isEqualTo: UserService.userData?.uid).where('isReadingStart',isEqualTo: true).snapshots();
  }
  static Stream<QuerySnapshot<Map<String, dynamic>>> getFutureBook(){
    return FirebaseFirestore.instance.collection('BookCollection').where('user_id',isEqualTo: UserService.userData?.uid).where('isReadingStart',isEqualTo: false).where('isReadingComplete',isEqualTo: false).snapshots();
  }
  static Stream<QuerySnapshot<Map<String, dynamic>>> getCompletedBook(){
    return FirebaseFirestore.instance.collection('BookCollection').where('user_id',isEqualTo: UserService.userData?.uid).where('isReadingComplete',isEqualTo: true).snapshots();
  }
  
  static Future<TaskSnapshot> uploadPdf(String? path,String? fileName)async{
    TaskSnapshot uploadTask = await FirebaseStorage.instance.ref().child('PDF/$fileName').putFile(File(path!));
    
    return uploadTask;
  }

  static Future changeLocalPathOnFirestore(String? bookId,String? path)async{
     await FirebaseFirestore.instance.collection('BookCollection').doc(bookId).update({
        'path': path
     });
  }
}

