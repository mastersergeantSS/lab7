import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'backend.dart';
import 'shop.dart';

String basePath;
List<Product> products;
final ValueNotifier<int> value = ValueNotifier<int>(0);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  basePath = (await getApplicationDocumentsDirectory()).path + '/products/';
  final baseDir = Directory(basePath)..createSync();
  final filenames = baseDir.listSync().map((file) => file.path).toList();
  filenames.sort();
  products = filenames.map((filename) => Product.fromJson(jsonDecode(File(filename).readAsStringSync()), filename.substring(filename.lastIndexOf('/') + 1))).toList();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'store-front',
    routes: {
      'store-front': (context) => Shop(),
      'back-end': (context) => Backend(),
    },
  ));
}


class Product {
  String name, id;
  double price;
  int quantity;

  Product(this.name, this.price, this.quantity, this.id);
  Product.fromJson(Map<String, dynamic> json, this.id) : name = json['Наименование'], price = json['Цена'], quantity = json['Количество'];

  Map<String, dynamic> get json => {
    'Наименование': name,
    'Цена': price,
    'Количество': quantity,
  };
}
