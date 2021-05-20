import 'package:flutter_riverpod/flutter_riverpod.dart';

final fakeCustomersProvider =
    Provider<List<Customer>>((ref) => Customer.getFakeCustomers());

class Customer {
  final String name;
  final String address;

  Customer({required this.name, required this.address});

  static List<Customer> getFakeCustomers() {
    return <Customer>[
      Customer(
        name: 'Apple',
        address: '4-3-1 Tsunashima, Yokohama',
      ),
      Customer(
        name: 'Google',
        address: '3−21−3, Shibuya, Tokyo',
      ),
      Customer(
        name: 'Huawei',
        address: '1-5-1 Otemachi, Chiba',
      ),
    ];
  }
}
