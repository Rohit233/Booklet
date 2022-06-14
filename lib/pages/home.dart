import 'dart:io';

import 'package:booklet/components/single_book.dart';
import 'package:booklet/model/book.dart';
import 'package:booklet/pages/completedBookPage.dart';
import 'package:booklet/services/book_listing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pdf_text/pdf_text.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FilePickerResult? result;
  late TextEditingController? titleEditingController = TextEditingController();
  late TextEditingController? authorEditingController = TextEditingController();
  ValueNotifier<bool> isValid = ValueNotifier(false);
  String? storeLink;
  List<Book?> listCustomBook = [];
  Book? currentReadingBook;
  bool isLinkPdf = false;
  TextEditingController? linkEditingController = TextEditingController();
  bool isUploading = false;
  bool isUploaded = true;
  Future addBook() async {
    PDFDoc? doc = result == null
        ? null
        : await PDFDoc.fromFile(File((result?.files[0].path)!));
    Book newBook = Book(
        doc?.info.title,
        doc?.pages.length,
        doc?.info.author,
        currentReadingBook == null ? true : false,
        false,
        linkEditingController?.text,
        '',
        titleEditingController?.text,
        authorEditingController?.text,
        null,
        storeLink);
    // ignore: unnecessary_null_comparison
    if (currentReadingBook == null) {
      BookListing.addBook(newBook);
    } else {
      BookListing.addBook(newBook);
    }
    setState(() {});
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    result = null;
    return;
  }

  bookCompleteDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actions: [
              ElevatedButton(
                child: const Text("Close"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
            content: SizedBox(
              height: 250,
              child: listCustomBook.isEmpty
                  ? const Center(
                      child: Text('Add Books First'),
                    )
                  : Column(
                    children: [
                     const Padding(
                       padding:  EdgeInsets.all(8.0),
                       child:  Center(
                          child: Text('Choose next book',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                          ),
                        ),
                     ),
                      Expanded(
                        child: ListView.builder(
                            itemCount: listCustomBook.length,
                            itemBuilder: ((context, i) {
                              return InkWell(
                                onTap: () async {
                                  await BookListing.completeBook(
                                      currentReadingBook?.id);
                                  await BookListing.startBook(listCustomBook[i]?.id);
                                  // ignore: use_build_context_synchronously
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      const Padding(
                                        padding:
                                            EdgeInsets.only(right: 8.0, left: 6.0),
                                        child: Icon(Icons.book_rounded),
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                (listCustomBook[i]?.title ??
                                                    listCustomBook[i]?.oTitle)!,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                (listCustomBook[i]?.author ??
                                                        listCustomBook[i]?.oAuth)
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 13, color: Colors.grey),
                                              ),
                                            ),
                                            listCustomBook[i]?.pages == null
                                                ? Container()
                                                : Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text(
                                                      "${listCustomBook[i]?.pages} pages",
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.grey),
                                                    ))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            })),
                      ),
                    ],
                  ),
            ),
          );
        });
  }

  addBookDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actions: [
              ValueListenableBuilder(
                  valueListenable: isValid,
                  builder: (context, bool isValid, Widget? widget) {
                    return ElevatedButton(
                        onPressed: !isValid
                            ? null
                            : () {
                                addBook();
                              },
                        child: const Text("Add"));
                  })
            ],
            content: SingleChildScrollView(
              child: StatefulBuilder(builder: (context, state) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Link'),
                        Switch(
                            value: isLinkPdf,
                            onChanged: (value) {
                              state(() {
                                isLinkPdf = value;
                              });
                            }),
                      ],
                    ),
                    TextField(
                      controller: titleEditingController,
                      onChanged: (val) {
                        if (val.isNotEmpty && result != null &&  authorEditingController!.text.isNotEmpty && (!isLinkPdf || linkEditingController!.text.isNotEmpty)) {
                          isValid.value = true;
                        } else {
                          isValid.value = false;
                        }
                        state(() {});
                      },
                      decoration: const InputDecoration(helperText: "Title"),
                    ),
                    TextField(
                      controller: authorEditingController,
                      onChanged: (val) {
                        if (val.isNotEmpty && result != null && titleEditingController!.text.isNotEmpty && (!isLinkPdf || linkEditingController!.text.isNotEmpty)) {
                          isValid.value = true;
                        } else {
                          isValid.value = false;
                        }
                      },
                      decoration: const InputDecoration(helperText: "Author"),
                    ),
                    isLinkPdf
                        ? TextField(
                            onChanged: (val) {
                              if (val.isNotEmpty && titleEditingController!.text.isNotEmpty && (authorEditingController!.text.isNotEmpty)) {
                                isValid.value = true;
                              } else {
                                isValid.value = false;
                              }
                            },
                            controller: linkEditingController,
                            decoration:
                                const InputDecoration(helperText: "Link"),
                          )
                        : Row(
                            children: [
                              result != null && isUploaded
                                  ? Expanded(
                                      child: Text(result!.paths[0]!.split('/')[
                                          result!.paths[0]!.split('/').length -
                                              1]))
                                  : Container(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                    onPressed: () async {
                                      result = await FilePicker.platform
                                          .pickFiles(
                                              type: FileType.custom,
                                              allowedExtensions: ['pdf']);
                                      if (result != null) {
                                        state(() {
                                          isUploading = true;
                                        });
                                        TaskSnapshot taskSnapshot =
                                            await BookListing.uploadPdf(
                                                result?.paths[0],
                                                result?.files[0].name);

                                        if (taskSnapshot.state ==
                                            TaskState.error) {
                                          isUploaded = false;
                                          // ignore: use_build_context_synchronously
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  backgroundColor: Colors.red,
                                                  content: Text(
                                                      'Failed to upload.Try again')));
                                        } else if (taskSnapshot.state ==
                                            TaskState.success) {
                                          isUploaded = true;
                                          storeLink = await taskSnapshot.ref
                                              .getDownloadURL();
                                          isValid.value = true;    
                                          // ignore: use_build_context_synchronously
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  backgroundColor: Colors.green,
                                                  content: Text(
                                                      'Uploaded Successfully')));
                                        }
                                      }
                                      isUploading = false;
                                      state(() {});
                                    },
                                    child: const Text("Choose File")),
                              )
                            ],
                          ),
                    isUploading
                        ? Column(
                            children: const [
                              LinearProgressIndicator(),
                              Text("Please wait....")
                            ],
                          )
                        : Container()
                  ],
                );
              }),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Align(
          alignment: Alignment.bottomRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () async {
                  result = null;
                  titleEditingController = TextEditingController();
                  authorEditingController = TextEditingController();
                  linkEditingController = TextEditingController();
                  storeLink = null;
                  addBookDialog();
                },
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
              ),
              FloatingActionButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const CompletedBookPage();
                  }));
                },
                child: const Icon(Icons.check),
              )
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Center(
                  child: Text("Current Book",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ),
              ),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: BookListing.getCurrentBook(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.data != null &&
                        snapshot.data!.docs.isNotEmpty) {
                      currentReadingBook = Book(
                          snapshot.data?.docs.first.data()['title'],
                          snapshot.data!.docs.first.data()['pages'],
                          snapshot.data!.docs.first.data()['author'],
                          snapshot.data!.docs.first.data()['isReadingStart'],
                          snapshot.data!.docs.first.data()['isReadingComplete'],
                          snapshot.data!.docs.first.data()['link'],
                          snapshot.data!.docs.first.data()['path'],
                          snapshot.data!.docs.first.data()['title'],
                          snapshot.data!.docs.first.data()['author'],
                          snapshot.data!.docs.first.id,
                          snapshot.data!.docs.first.data()['storeLink']);
                    }
                    return currentReadingBook == null
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SingleBook(
                              context: context,
                              customBook: currentReadingBook,
                              index: 0,
                              completeBook: bookCompleteDialog,
                            ),
                          );
                  }),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: BookListing.getFutureBook(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      listCustomBook = Book.getObject(snapshot.data)!;
                      return listCustomBook.isEmpty
                          ? const Center(
                              child: Text('Add Books'),
                            )
                          : Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Center(
                                    child: Text(
                                      "Next Books",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                      itemCount: listCustomBook.length,
                                      itemBuilder: (context, int i) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              SingleBook(
                                                context: context,
                                                customBook: listCustomBook[i],
                                                index: i == 0 ? 1 : i,
                                                completeBook:
                                                    bookCompleteDialog,
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                ),
                              ],
                            );
                    }),
              ),
            ],
          ),
        ));
  }
}
