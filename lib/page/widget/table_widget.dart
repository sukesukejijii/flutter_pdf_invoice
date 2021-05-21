import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_invoice/data/invoice_entry_data.dart';
import 'package:pdf_invoice/model/invoice.dart';
import 'package:pdf_invoice/utils.dart';

final fakeEntriesProvider = Provider.autoDispose<List<InvoiceEntry>>((ref) {
  ref.maintainState = true;
  return InvoiceEntry.getFakeInvoiceEntries();
});
final sortIndexProvider = StateProvider.autoDispose<int?>((ref) => null);
final sortAscendingProvider = StateProvider.autoDispose<bool>((ref) => false);

class TableWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, watch) {
    final fakeEntries = watch(fakeEntriesProvider);
    final sortIndex = watch(sortIndexProvider).state;
    final sortAscending = watch(sortAscendingProvider).state;

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            sortColumnIndex: sortIndex,
            sortAscending: sortAscending,
            // dataTextStyle: TextStyle(
            //   fontFamily: 'arial',
            //   fontFamilyFallback: ['emoji'],
            // ),
            columns: [
              for (var key in entryKeys)
                DataColumn(
                  onSort: (columnIndex, ascending) {
                    if (columnIndex != 4) {
                      context.read(fakeEntriesProvider).sort((a, b) =>
                          compareString(a, b, columnIndex, ascending));
                      context.read(sortIndexProvider).state = columnIndex;
                      context.read(sortAscendingProvider).state = ascending;
                    }
                  },
                  label: Text(key),
                  numeric: true,
                ),
            ],
            rows: [
              for (var entry in fakeEntries)
                DataRow(
                  cells: [
                    DataCell(Text(entry.description)),
                    DataCell(Text(Utils.formatDate(entry.date))),
                    DataCell(Text(
                      entry.quantity.toString(),
                      textAlign: TextAlign.right,
                    )),
                    DataCell(Text(Utils.formatPrice(entry.unitPrice))),
                    DataCell(Text('${100 * entry.vat} %')),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  int compareString(InvoiceEntry a, InvoiceEntry b, int index, bool ascending) {
    switch (index) {
      case 0:
        return ascending
            ? a.description.compareTo(b.description)
            : b.description.compareTo(a.description);
      case 1:
        return ascending ? a.date.compareTo(b.date) : b.date.compareTo(a.date);
      case 2:
        return ascending
            ? a.quantity.compareTo(b.quantity)
            : b.quantity.compareTo(a.quantity);
      case 3:
        return ascending
            ? a.unitPrice.compareTo(b.unitPrice)
            : b.unitPrice.compareTo(a.unitPrice);
      default:
        return 0;
    }
  }
}
