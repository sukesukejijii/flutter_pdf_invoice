import 'dart:html';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_invoice/api/pdf_invoice_api.dart';
import 'package:pdf_invoice/main.dart';
import 'package:pdf_invoice/model/invoice.dart';
import 'package:pdf_invoice/model/supplier.dart';
import 'package:pdf_invoice/page/widget/table_widget.dart';
import 'package:pdf_invoice/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widget/dropdown_widget.dart';

final netTotalProvider = Provider.autoDispose<int>((ref) {
  return ref
      .watch(fakeEntriesProvider)
      .map((e) => e.quantity * e.unitPrice)
      .reduce((v, e) => v + e)
      .toInt();
});

class PdfPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      appBar: AppBar(
        title: Text(MyApp.title),
        centerTitle: true,
        leading:
            Text('Click on each header to sort the list. List is scrollable.'),
        leadingWidth: 260,
        actions: [
          TextButton.icon(
            label: Text(
              'Randomize Data',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            icon: Icon(
              Icons.refresh_rounded,
              color: Colors.white,
            ),
            onPressed: () => context.refresh(fakeEntriesProvider),
          ),
          SizedBox(width: 24),
          TextButton(
            onPressed: () => _launchURL(
                'https://github.com/sukesukejijii/flutter_pdf_invoice'),
            child: Image.asset('assets/github.png'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(60),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Consumer(
                      builder: (context, watch, child) {
                        final fakeEntries = watch(fakeEntriesProvider);
                        final itemCount = fakeEntries.length;
                        final netTotal = watch(netTotalProvider);
                        return Row(
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Net Total:   ',
                                children: [
                                  TextSpan(
                                    text: Utils.formatPrice(netTotal),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      color: Colors.indigo[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 60),
                            Text.rich(
                              TextSpan(
                                text: 'Item Count:   ',
                                children: [
                                  TextSpan(
                                    text: itemCount.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      color: Colors.indigo[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(width: 60),
                    DropdownWidget(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TableWidget(),
              const SizedBox(height: 45),
              ElevatedButton.icon(
                icon: Icon(Icons.picture_as_pdf),
                label: Text('Generate INVOICE'),
                onPressed: () async {
                  final date = DateTime.now();
                  final dueDate = date.add(Duration(days: 7));
                  await _generatePdf(context, date, dueDate);
                },
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                icon: Icon(Icons.email_rounded),
                label: Text('Share via Email'),
                onPressed: () async {
                  final netTotal =
                      Utils.formatPrice(context.read(netTotalProvider));
                  final client =
                      context.read(selectedCustomerProvider).state.name;
                  await _launchEmail(netTotal, client);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generatePdf(
      BuildContext context, DateTime date, DateTime dueDate) async {
    final invoice = Invoice(
      info: InvoiceInfo(
        description:
            'Give me money. Give me money. Give me money. Give me money. Give me money. Give me money. Give me money. Give me money. Give me money. Give me money. ',
        number: '${date.year}-0001',
        date: date,
        dueDate: dueDate,
      ),
      supplier: Supplier(
        name: 'Any Factory',
        address: 'Street 9, Beijing, China',
        paymentInfo: 'https://paypal.me/anyfactory',
      ),
      customer: context.read(selectedCustomerProvider).state,
      entries: [
        ...context.read(fakeEntriesProvider),
      ],
    );

    final pdfBytes = await PdfInvoiceApi.generate(invoice);
    print('pressed 2');

    AnchorElement(
        href:
            'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(pdfBytes)}')
      ..setAttribute('download', '${Utils.formatDate(date)}_invoice.pdf')
      ..click();
  }

  Future<void> _launchEmail(String netTotal, String client) async {
    final emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'someone@in.company',
      queryParameters: {
        'subject': 'Sharing Q4 sales of $client',
        'body': 'Net total was $netTotal',
      },
    );
    _launchURL(emailLaunchUri.toString());
  }

  Future<void> _launchURL(String url) async {
    await canLaunch(url)
        ? await launch(url)
        : throw Exception('Could not launch');
  }
}
