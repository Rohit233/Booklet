// ignore_for_file: file_names

import 'package:booklet/components/single_book.dart' show SingleBook;
import 'package:booklet/services/book_listing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/book.dart';

class CompletedBookPage extends StatefulWidget {
  const CompletedBookPage({Key? key}) : super(key: key);

  @override
  State<CompletedBookPage> createState() => _CompletedBookPageState();
}

class _CompletedBookPageState extends State<CompletedBookPage> {
  List<Book?>? completedBooks = [];
  @override
  Widget build(BuildContext context) {
     return Scaffold(
       body: SafeArea(
         child: Column(
           children: [
             const Padding(
               padding: EdgeInsets.all(10.0),
               child: Center(
                 child: Text("Completed Books",style: TextStyle(
                   fontWeight: FontWeight.bold,
                   fontSize: 20
                 ),),
               ),
             ),
             Expanded(
               child: StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
                 stream: BookListing.getCompletedBook(),
                 builder: (context, snapshot) {
                   if(snapshot.connectionState == ConnectionState.waiting){
                     return const Center(
                       child: CircularProgressIndicator(),
                     );
                   }
                   if(snapshot.data != null && snapshot.data!.docs.isNotEmpty){
                      completedBooks = Book.getObject(snapshot.data);
                   }
                   return completedBooks!.isEmpty ? const Center(
                     child: Text("No book completed"),
                   ) : ListView.builder(
                     itemCount: completedBooks?.length,
                     itemBuilder: (context,int i){
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleBook(customBook: completedBooks![i], index: i,context: context,),
                        );
                     },
                   );
                 }
               ),
             ),
           ],
         ),
       ),
     );
  }
}