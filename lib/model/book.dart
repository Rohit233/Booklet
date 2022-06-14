// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  // ignore: prefer_final_fields
  String? _id;
  String? _title;
  // ignore: prefer_final_fields
  String? _oTitle;
  int? _pages;
  String? _author;
  // ignore: prefer_final_fields
  String? _oAuthor;
  bool? _isReadingStart;
  bool? _isReadingComplete;
  String? _link;
  String? _path;
  // ignore: prefer_final_fields
  String? _storeLink;

  Book(
      this._title,
      this._pages,
      this._author,
      this._isReadingStart,
      this._isReadingComplete,
      this._link,
      this._path,
      this._oTitle,
      this._oAuthor,
      this._id,
      this._storeLink
      );
  String? get storeLink => _storeLink;

  String? get id => _id;

  String? get oTitle => _oTitle;

  String? get oAuth => _oAuthor;

  set link(String? link) {
    _link = link;
  }

  // ignore: unnecessary_getters_setters
  String? get link => _link;

  set path(String? path) {
    _path = path;
  }

  // ignore: unnecessary_getters_setters
  String? get path => _path;

  set title(String? title) {
    _title = title;
  }

  // ignore: unnecessary_getters_setters
  String? get title => _title;

  set pages(int? pages) {
    _pages = pages;
  }

  // ignore: unnecessary_getters_setters
  int? get pages => _pages;

  set author(String? author) {
    _author = author;
  }

  // ignore: unnecessary_getters_setters
  String? get author => _author;

  set isReadingStart(bool? isReadingStart) {
    _isReadingStart = isReadingStart;
  }

  // ignore: unnecessary_getters_setters
  bool? get isReadingStart => _isReadingStart;

  set isReadingComplete(bool? isReadingComplete) {
    _isReadingComplete = isReadingComplete;
  }

  // ignore: unnecessary_getters_setters
  bool? get isReadingComplete => _isReadingComplete;

  static List<Book?>? getObject(QuerySnapshot<Map<String, dynamic>>? snapshot) {
    List<Book?> listBook = [];
    // ignore: avoid_function_literals_in_foreach_calls
    snapshot?.docs.forEach((element) {
      Book book = Book(
          element.data()['title'],
          element.data()['pages'],
          element.data()['author'],
          element.data()['isReadingStart'],
          element.data()['isReadingComplete'],
          element.data()['link'],
          element.data()['path'],
          element.data()['title'],
          element.data()['author'],
          element.id,
          element.data()['storeLink']
          );
      listBook.add(book);    
    });
    return listBook;
  }
}
