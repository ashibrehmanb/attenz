import 'package:attenz/screens/login.dart';
import 'package:attenz/screens/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ScreenPercentage extends StatefulWidget {
  final List rollno, regno, name, percentage;
  final String batch, sem;
  const ScreenPercentage(
      this.batch, this.sem, this.rollno, this.regno, this.name, this.percentage,
      {super.key});

  @override
  State<ScreenPercentage> createState() => _ScreenPercentageState();
}

class _ScreenPercentageState extends State<ScreenPercentage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '${widget.batch}   |   ${widget.sem}',
          style: const TextStyle(fontSize: 23),
        ),
        actions: [
          // Padding(
          //   padding: const EdgeInsets.only(right: 17.0, top: 8, bottom: 15),
          //   child: (!percentage.any((element) => element == 'NaN%'))
          //       ? MaterialButton(
          //           shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(18)),
          //           textColor: Colors.green,
          //           color: Colors.white,
          //           onPressed: () async {
          //             await _sharepdf();
          //           },
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //             children: const [
          //               Text(
          //                 'Share   ',
          //                 style: TextStyle(fontWeight: FontWeight.bold),
          //               ),
          //               Icon(Icons.share),
          //             ],
          //           ),
          //         )
          //       : null,
          // )
          Padding(
            padding: const EdgeInsets.only(right: 17),
            child: PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              onSelected: handleClick,
              itemBuilder: (BuildContext context) {
                return {'Search', 'Share Pdf', 'Print Pdf'}
                    .map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ),
        ],
      ),
      body: (widget.percentage.any((element) => element == 'NaN%'))
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset("assets/markattendance empty.json", height: 500),
                  Text(
                    "List is Empty!\nAdd Attendance to ${widget.batch} ${widget.sem}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text(
                        'Roll No.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Register No.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Percentage',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: List.generate(
                      widget.rollno.length,
                      (index) => DataRow(cells: [
                            DataCell(Text(widget.rollno[index])),
                            DataCell(Text(widget.regno[index])),
                            DataCell(Text(widget.name[index])),
                            DataCell(Text(widget.percentage[index])),
                          ])),
                ),
              ),
            ),
    );
  }

  void handleClick(String value) async {
    switch (value) {
      case 'Search':
        Navigator.push(
          (context),
          MaterialPageRoute(
              builder: (_) => ScreenSearch(
                  widget.rollno, widget.regno, widget.name, widget.percentage)),
        );
        break;
      case 'Share Pdf':
        await _sharepdf(false);
        break;
      case 'Print Pdf':
        _sharepdf(true);
        break;
    }
  }

  Future _sharepdf(bool print) async {
    final pdf = pw.Document();
    final ByteData bytes = await rootBundle.load('assets/kulogo.png');
    final Uint8List byteList = bytes.buffer.asUint8List();

    pdf.addPage(pw.MultiPage(
        footer: (context) {
          return pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                    '${widget.batch} ${widget.sem} attendance percentage sheet'),
                pw.Text('Page ${context.pageNumber} of ${context.pagesCount}')
              ]);
        },
        margin: const pw.EdgeInsets.all(35),
        pageFormat: PdfPageFormat.letter,
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center,
                // mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Image(
                      pw.MemoryImage(
                        byteList,
                      ),
                      height: 50,
                      fit: pw.BoxFit.fitHeight),
                  pw.Text('University Institute of Technology',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text('University of Kerala\nKottarakara',
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 12)),
                  pw.Text(
                      'Ph: 0474-2452220\t\t|\t\tEmail: uitktr@gmail.com\t\t|\t\tWebsite: www.uitktr.in',
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Divider(),
                ]),
            pw.Row(children: [
              pw.Expanded(
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                    pw.Text('Batch : ${widget.batch}',
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 12)),
                    pw.Text('Sem : ${widget.sem}',
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 12)),
                  ])),
              pw.Expanded(
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                    pw.Text('Generated by : $user',
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 12)),
                    pw.Text('Generated on : ${DateTime.now()}',
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 12)),
                  ])),
            ]),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Table(border: pw.TableBorder.all(), children: [
                pw.TableRow(children: [
                  pw.Text('Roll No.',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 14)),
                  pw.Text('Reg No.',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 14)),
                  pw.Text('Name',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 14)),
                  pw.Text('Percentage',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 14)),
                ]),
                for (int i = 0; i < widget.rollno.length; i++)
                  pw.TableRow(children: [
                    pw.Text(widget.rollno[i],
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 14)),
                    pw.Text(widget.regno[i],
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 14)),
                    pw.Text('\t\t\t${widget.name[i]}',
                        textAlign: pw.TextAlign.left,
                        style: const pw.TextStyle(fontSize: 14)),
                    pw.Text(widget.percentage[i],
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 14)),
                  ]),
              ]),
            ),
          ];
        }));
    (print)
        ? await Printing.layoutPdf(
            onLayout: (PdfPageFormat format) async => pdf.save(),
            name: '${widget.batch} ${widget.sem} - percentage.pdf')
        : await Printing.sharePdf(
            bytes: await pdf.save(),
            filename: '${widget.batch} ${widget.sem} - percentage.pdf');
  }
}
