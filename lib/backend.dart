import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';
import 'main.dart';
import 'dart:math';


class Backend extends StatefulWidget {
  Backend();
  @override
  BackendState createState() => BackendState();
}


class BackendState extends State<Backend> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Административная часть'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.business_center),
            onPressed: () {
              Navigator.pushReplacementNamed(context, 'store-front');
            },
          )
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: value,
        builder: (context, value, child) => products.length == 0 ? Center(
          child: Text(
            'Нет товаров',
            style: TextStyle(fontSize: 30),
          ),
        ) : ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0), 
                child: Text(products[index].id),
              ),
              title: Text(
                products[index].name,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Количество: ${products[index].quantity}',
                  ),
                  IconButton(
                    padding: EdgeInsets.only(left: 15),
                    iconSize: 24,
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      editDialog(
                        'ИЗМЕНИТЬ', 
                        (Product product) {
                          products[index] = product;
                        },
                        name: products[index].name,
                        price: products[index].price.toString(),
                        quantity: products[index].quantity.toString(),
                        index: index,
                      );
                    },
                  ),
                  IconButton(
                    iconSize: 24,
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      File(basePath + products.removeAt(index).id).deleteSync();
                      setState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          editDialog('ДОБАВИТЬ', (Product product) {
            products.add(product);
            File(basePath + product.id).writeAsStringSync(jsonEncode(product.json));
          });
        },
      ),
    );
  }

  void editDialog(String confirmationString, Function(Product) success, {String name, String price, String quantity, int index}) {
    final nameNode = FocusNode();
    final nameController = TextEditingController(text: name);
    final priceNode = FocusNode();
    final priceController = TextEditingController(text: price);
    final quantityNode = FocusNode();
    final quantityController = TextEditingController(text: quantity);
    showDialog<void>(
      context: context,
      builder: (BuildContext _) {
        return AlertDialog(
          contentPadding: const EdgeInsets.only(
            left: 16.0, 
            bottom: 16.0,
          ),
          content: Container(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    focusNode: nameNode,
                    controller: nameController,
                    onEditingComplete: priceNode.requestFocus,
                    decoration: const InputDecoration(
                      hintText: 'Наименование',
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          focusNode: priceNode,
                          controller: priceController,
                          onEditingComplete: quantityNode.requestFocus,
                          decoration: const InputDecoration(
                            hintText: 'Стоимость',
                          ),
                          inputFormatters: <TextInputFormatter>[
                            WhitelistingTextInputFormatter(RegExp('[0-9]+.{0,1}')),
                          ],
                        ),
                      ),
                      FlatButton(
                        child: const Text(
                          'ОТМЕНА',
                          style: TextStyle(fontSize: 15.0),
                        ),
                        onPressed: Navigator.of(context).pop,
                      ),
                    ]
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          focusNode: quantityNode,
                          controller: quantityController,
                          decoration: const InputDecoration(
                            hintText: 'Количество',
                          ),
                          inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
                        ),
                      ),
                      FlatButton(
                        child: Text(
                          confirmationString,
                          style: TextStyle(fontSize: 15.0),
                        ),
                        onPressed: () {
                          if ((nameController.text ?? '') == '' || (priceController.text ?? '') == '' || (quantityController.text ?? '') == '') {
                            Navigator.pop(context);
                            showDialog<void> (
                              useRootNavigator: false,
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: Text(
                                  'Заполните все поля для того чтобы ${confirmationString.toLowerCase()} a product!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    height: 1.5,
                                    fontSize: 24.0,
                                  ), 
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('OK'),
                                    onPressed: Navigator.of(context).pop,
                                  )
                                ],
                              ),
                            );
                          }
                          else {
                            Navigator.pop(context);
                            if (confirmationString == 'ИЗМЕНИТЬ') {
                              final file = File(basePath + products[index].id);
                              Future.delayed(Duration(seconds: 3 + Random().nextInt(3)), () {
                                if (file.existsSync()) {
                                  final product = Product(
                                    nameController.text, 
                                    double.parse(priceController.text), 
                                    int.parse(quantityController.text), 
                                    products[index].id,
                                  );
                                  success(product);
                                  file.writeAsStringSync(jsonEncode(product.json));
                                  value.value++;
                                }
                              });
                            }
                            else {
                              final product = Product(
                                nameController.text, 
                                double.parse(priceController.text), 
                                int.parse(quantityController.text), 
                                products.length == 0 ? '1' : (int.parse(products[products.length - 1].id) + 1).toString(),
                              );
                              success(product);
                              File(basePath + product.id).writeAsStringSync(jsonEncode(product.json));
                              setState(() {});
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        );
      },
    );
  }
}
