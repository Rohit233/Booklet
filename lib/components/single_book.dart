import 'dart:io';

import 'package:booklet/services/book_listing.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../model/book.dart';

class SingleBook extends StatefulWidget {
  final Book? customBook;
  final BuildContext context;
  final int index;
  final Function? completeBook;
  const SingleBook(
      {Key? key,
      required this.customBook,
      required this.index,
      this.completeBook,
      required this.context})
      : super(key: key);

  @override
  State<SingleBook> createState() => _SingleBookState();
}

class _SingleBookState extends State<SingleBook> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (widget.customBook?.path == null ||
            widget.customBook?.storeLink == null) {
          await launchUrl(Uri.parse((widget.customBook?.link)!));
        } else {
          OpenFile.open(widget.customBook?.path).then((result) async {
            if (result.type == ResultType.fileNotFound) {
              if (await Permission.storage.request().isGranted) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(widget.context).showSnackBar(
                    const SnackBar(
                        backgroundColor: Colors.green,
                        content: Text("Downloading please wait...")));
                http.Response response =
                    await http.get(Uri.parse((widget.customBook?.storeLink)!));
                Directory? dir = await getExternalStorageDirectory();
                String? baseDir =
                    '${(dir?.parent.parent.parent.parent.path)!}/Booklet';
                Directory(baseDir).create(recursive: true);
                File downloadedFile =
                    await File("$baseDir/${widget.customBook?.title}.pdf")
                        .writeAsBytes(response.bodyBytes);
                BookListing.changeLocalPathOnFirestore(
                    widget.customBook?.id, downloadedFile.path);
                OpenFile.open(downloadedFile.path);
              }
            }
          });
        }
      },
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8.0, left: 6.0),
            child: Icon(Icons.book_rounded),
          ),
          Expanded(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    (widget.customBook?.title ?? widget.customBook?.oTitle)!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    (widget.customBook?.author ?? widget.customBook?.oAuth)
                        .toString(),
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
                widget.customBook?.pages == null
                    ? Container()
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "${widget.customBook?.pages} pages",
                          style:
                              const TextStyle(fontSize: 13, color: Colors.grey),
                        ))
              ],
            ),
          ),
          widget.index == 0 && widget.completeBook != null
              ? IconButton(
                  icon: const Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    widget.completeBook!();
                  },
                )
              : Container()
        ],
      ),
    );
  }
}
