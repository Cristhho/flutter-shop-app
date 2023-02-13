import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../providers/orders.dart';
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15.0),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Total', style: TextStyle(fontSize: 20.0),),
                  Spacer(),
                  Chip(
                    label: Text('\$${cart.totalAmount.toStringAsFixed(2)}', style: TextStyle(
                      color: Theme.of(context).primaryTextTheme.headline6!.color
                    )),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cart: cart)
                ],
              ),
            ),
          ),
          SizedBox(height: 10.0,),
          Expanded(child: ListView.builder(
            itemCount: cart.itemsCount,
            itemBuilder: (ctx, index) => CartItem(
              cart.items.values.toList()[index].id,
              cart.items.keys.toList()[index],
              cart.items.values.toList()[index].price,
              cart.items.values.toList()[index].quantity,
              cart.items.values.toList()[index].title,
            ),
          ))
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {

  const OrderButton({
    Key? key,
    required this.cart
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading) ? null : () async {
        setState(() {
          _isLoading = true;
        });
        if (widget.cart.items.isNotEmpty) {
          await Provider.of<Orders>(context, listen: false).addOrder(widget.cart.items.values.toList(), widget.cart.totalAmount);
          setState(() {
            _isLoading = false;
          });
          widget.cart.clear();
        }
      },
      child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW')
    );
  }
}
