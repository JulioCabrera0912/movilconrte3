import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfView extends StatefulWidget {
  final File path;
  const PdfView({Key? key, required this.path}) : super(key: key);

  @override
  _PdfViewState createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  late PDFViewController pdfViewController;
  int pages = 0;
  int indexPage = 1;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF View'),
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.path.path,
            autoSpacing: true,
            enableSwipe: true,
            pageSnap: true,
            swipeHorizontal: true,
            nightMode: false,
            onError: (e) {
              setState(() {
                errorMessage = e.toString();
              });
              print(errorMessage);
            },
            onRender: (pages) {
              setState(() {
                isReady = true;
                this.pages = pages!;
              });
            },
            onViewCreated: (controller) {
              setState(() {
                pdfViewController = controller;
              });
            },
            onPageChanged: (indexPage, _) {
              setState(() {
                this.indexPage = indexPage!;
              });
            },
            onPageError: (page, e) {},
          ),
          !isReady
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Offstage(),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          indexPage > 0
              ? FloatingActionButton.extended(
                  onPressed: () {
                    pdfViewController.setPage(indexPage - 1);
                  },
                  label: Text('Go to ${indexPage - 1}'),
                )
              : Offstage(),
          indexPage + 1 < pages
              ? FloatingActionButton.extended(
                  onPressed: () {
                    pdfViewController.setPage(indexPage + 1);
                  },
                  label: Text('Go to ${indexPage + 1}'),
                )
              : Offstage(),
        ],
      ),
    );
  }
}
