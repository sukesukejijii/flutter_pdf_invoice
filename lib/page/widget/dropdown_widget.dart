import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_invoice/model/customer.dart';
import 'package:pdf_invoice/page/widget/table_widget.dart';

final selectedCustomerProvider = StateProvider<Customer>((ref) {
  return ref.read(fakeCustomersProvider).first;
});

class DropdownWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, watch) {
    final fakeCustomers = watch(fakeCustomersProvider);
    final selectedCustomer = watch(selectedCustomerProvider).state;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Select Client'),
        const SizedBox(width: 12),
        DropdownButton<Customer>(
          value: selectedCustomer,
          items: [
            for (var customer in fakeCustomers)
              DropdownMenuItem<Customer>(
                  child: Text(customer.name), value: customer),
          ],
          onChanged: (customer) {
            context.read(selectedCustomerProvider).state = customer!;
            context.refresh(fakeEntriesProvider);
          },
        ),
      ],
    );
  }
}
