import 'package:flutter/material.dart';
import 'main.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';


class Shop extends StatefulWidget {
  Shop();
  @override
  ShopState createState() => ShopState();
}


class ShopState extends State<Shop> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: value,
      builder: (context, _, child) {
        final visibleProducts = products.where((product) => product.quantity != 0).toList();
        return Scaffold(
          appBar: AppBar(
            title: Text('Клиент'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.business),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, 'back-end');
                },
              ),
            ],
          ),
          body: visibleProducts.length == 0 ? Center(
            child: Text(
              'Нет товаров',
              style: TextStyle(fontSize: 30),
            ),
          ) : PageView.builder(
            itemCount: visibleProducts.length,
            controller: PageController(),
            physics: PageScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Имя: ${visibleProducts[index].name}',
                      style: TextStyle(
                        fontSize: 30.0, 
                      ),
                    ),
                    Text(
                      'Количество: ${visibleProducts[index].quantity}',
                      style: TextStyle(
                        fontSize: 30.0, 
                      ),
                    ),
                    Text(
                      'Цена: \$${visibleProducts[index].price}',
                      style: TextStyle(
                        fontSize: 30.0, 
                      ),
                    ),
                    FlatButton(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      color: Colors.black87,
                      textColor: Colors.cyan,
                      child: const Text(
                        'КУПИТЬ',
                        style: TextStyle(fontSize: 35.0),
                      ),
                      onPressed: () {
                        final file = File(basePath + visibleProducts[index].id);
                        Future.delayed(Duration(seconds: 3 + Random().nextInt(3)), () {
                          if (file.existsSync() && visibleProducts[index].quantity != 0) {
                            visibleProducts[index].quantity--;
                            File(basePath + visibleProducts[index].id).writeAsStringSync(
                              jsonEncode(visibleProducts[index].json)
                            );
                            value.value++;
                          }
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }
    );
  }
}
