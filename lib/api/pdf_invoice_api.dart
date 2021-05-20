import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf_invoice/api/pdf_api.dart';
import 'package:pdf_invoice/model/customer.dart';
import 'package:pdf_invoice/model/invoice.dart';
import 'package:pdf_invoice/model/supplier.dart';
import 'package:pdf_invoice/utils.dart';

class PdfInvoiceApi {
  static Future<Uint8List> generate(Invoice invoice) async {
    final pdf = Document();
    pdf.addPage(
      MultiPage(
        theme: ThemeData.withFont(
          base: Font.ttf(await rootBundle.load("fonts/arial.ttf")),
          bold: Font.ttf(await rootBundle.load("fonts/arial.ttf")),
        ),
        build: (context) => [
          buildHeader(invoice),
          SizedBox(height: 3 * PdfPageFormat.cm),
          buildTitle(invoice),
          buildInvoice(invoice),
          Divider(),
          buildTotal(invoice),
        ],
        footer: (context) => buildFooter(invoice),
      ),
    );

    return await PdfApi.saveDocument(pdf);
  }

  static Widget buildHeader(Invoice invoice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 1 * PdfPageFormat.cm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildSupplierAddress(invoice.supplier),
            Container(
              height: 50,
              width: 50,
              child: BarcodeWidget(
                data: invoice.info.number,
                barcode: Barcode.qrCode(),
              ),
            ),
          ],
        ),
        SizedBox(height: 1 * PdfPageFormat.cm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildCustomerAddress(invoice.customer),
            buildInvoiceInfo(invoice.info),
          ],
        ),
      ],
    );
  }

  static Widget buildCustomerAddress(Customer customer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(customer.name, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(customer.address),
      ],
    );
  }

  static Widget buildInvoiceInfo(InvoiceInfo info) {
    final paymentTerms = '${info.dueDate.difference(info.date).inDays} days';
    final titleValues = <String, String>{
      'Invoice Number:': info.number,
      'Invoice Date:': Utils.formatDate(info.date),
      'Payment Terms:': paymentTerms,
      'Due Date:': Utils.formatDate(info.dueDate),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var entry in titleValues.entries)
          buildText(title: entry.key, value: entry.value, width: 200),
      ],
    );
  }

  static Widget buildSupplierAddress(Supplier supplier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(supplier.name, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 1 * PdfPageFormat.cm),
        Text(supplier.address),
      ],
    );
  }

  static Widget buildTitle(Invoice invoice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('INVOICE',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 0.8 * PdfPageFormat.cm),
        Text(invoice.info.description),
        SizedBox(height: 0.8 * PdfPageFormat.cm),
      ],
    );
  }

  static Widget buildInvoice(Invoice invoice) {
    const headers = <String>[
      'Description',
      'Date',
      'Quantity',
      'Unit Price',
      'VAT',
      'Total'
    ];

    final entries = invoice.entries.map((e) {
      final total = e.quantity * e.unitPrice * (1 + e.vat);
      return <String>[
        e.description,
        Utils.formatDate(e.date),
        e.quantity.toString(),
        Utils.formatPrice(e.unitPrice),
        '${100 * e.vat} %',
        Utils.formatPrice(total.toInt()),
      ];
    }).toList();

    return Table.fromTextArray(
      headers: headers,
      data: entries,
      border: null,
      headerStyle: TextStyle(fontWeight: FontWeight.bold),
      headerDecoration: BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerRight,
        2: Alignment.centerRight,
        3: Alignment.centerRight,
        4: Alignment.centerRight,
        5: Alignment.centerRight,
      },
    );
  }

  static Widget buildTotal(Invoice invoice) {
    final netTotal = invoice.entries
        .map((e) => e.unitPrice * e.quantity)
        .reduce((v, e) => v + e);
    final vat = invoice.entries.first.vat;
    final vatAmount = (netTotal * vat).toInt();
    final total = netTotal + vatAmount;

    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Spacer(flex: 6),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildText(
                  title: 'Net Total',
                  value: Utils.formatPrice(netTotal),
                ),
                buildText(
                  title: 'Vat ${100 * vat} %',
                  value: Utils.formatPrice(vatAmount),
                ),
                Divider(),
                buildText(
                  title: 'Total Due',
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  value: Utils.formatPrice(total),
                  unite: true,
                ),
                SizedBox(height: 2 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
                SizedBox(height: 0.5 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildFooter(Invoice invoice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Divider(),
        SizedBox(height: 2 * PdfPageFormat.mm),
        buildSimpleText(title: 'Address', value: invoice.supplier.address),
        SizedBox(height: 1 * PdfPageFormat.mm),
        buildSimpleText(title: 'PayPal', value: invoice.supplier.paymentInfo),
      ],
    );
  }

  static Widget buildSimpleText({
    required String title,
    required String value,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: style),
        SizedBox(width: 2 * PdfPageFormat.mm),
        Text(value),
      ],
    );
  }

  static Widget buildText({
    required String title,
    required String value,
    double width = double.infinity,
    TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          Text(value, style: unite ? style : null),
        ],
      ),
    );
  }
}
