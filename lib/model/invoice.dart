import 'dart:math';

import 'package:pdf_invoice/data/invoice_entry_data.dart';

import 'supplier.dart';
import 'customer.dart';

class InvoiceEntry {
  final String description;
  final DateTime date;
  final int quantity;
  final double vat;
  final int unitPrice;

  const InvoiceEntry({
    required this.description,
    required this.date,
    required this.quantity,
    this.vat = 0.1,
    required this.unitPrice,
  });

  factory InvoiceEntry.fromMap(Map<String, dynamic> map) {
    final random = Random();
    return InvoiceEntry(
      description: map['description'],
      date: DateTime.now().add(Duration(days: random.nextInt(365))),
      quantity: (map['quantity'] + random.nextInt(1000) - 500).clamp(1, 2000),
      unitPrice: map['unitPrice'],
    );
  }

  static List<InvoiceEntry> getFakeInvoiceEntries() {
    final randomInt = 12 + Random().nextInt(10);
    final itemList = [
      for (var entryMap in entryData) InvoiceEntry.fromMap(entryMap),
    ]..shuffle();
    return itemList.take(randomInt).toList();
  }
}

class InvoiceInfo {
  final String description;
  final String number;
  final DateTime date;
  final DateTime dueDate;

  const InvoiceInfo({
    required this.description,
    required this.number,
    required this.date,
    required this.dueDate,
  });

  static List<InvoiceInfo> getFakeInvoiceInfo() {
    return [];
  }
}

class Invoice {
  final InvoiceInfo info;
  final Supplier supplier;
  final Customer customer;
  final List<InvoiceEntry> entries;

  const Invoice({
    required this.info,
    required this.supplier,
    required this.customer,
    required this.entries,
  });

  static List<Invoice> getFakeInvoices() {
    return [];
  }
}
