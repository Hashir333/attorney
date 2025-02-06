import 'package:attorney/services/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewer extends StatefulWidget {
  const PdfViewer({Key? key}) : super(key: key);

  @override
  _PdfViewerState createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  String path = 'https://app.attorneyofficial.com/how-it-works.pdf';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utility.textBlackColor,
      body: Stack(
        children: [
          SafeArea(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                  flex: 8,
                  child: Stack(children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                                alignment: Alignment.centerLeft,
                                width: 40,
                                height: 45,
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: Utility.whiteColor,
                                )),
                          ),
                          Container(
                            color: Utility.primaryColor,
                            alignment: Alignment.center,
                            height: 45,
                            child: Text(
                              'About of App'.toUpperCase(),
                              style: TextStyle(
                                  color: Utility.whiteColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            width: 40,
                            child: null,
                          ),
                        ],
                      ),
                    ),
                  ])),
              Expanded(
                  flex: 90,
                  child: Center(
                      child: (PDF(
                    swipeHorizontal: false,
                  ).cachedFromUrl(path)
                          // SfPdfViewer.network('https://app.attorneyofficial.com/how-it-works.pdf'),
                          )))
            ],
          ))
        ],
      ),
    );
  }

// Container(
// height: MediaQuery.of(context).size.height,
// width: MediaQuery.of(context).size.width,
// child: SfPdfViewer.network(
// 'http://attorney.bushrainternationaltrading.com/how-it-works.pdf'),
// )
}
