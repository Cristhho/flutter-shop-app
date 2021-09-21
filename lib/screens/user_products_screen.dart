import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import 'edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your products'),
        actions: <Widget>[
          IconButton(onPressed: (){
            Navigator.of(context).pushNamed(EditProductScreen.routeName);
          }, icon: Icon(Icons.add))
        ],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: productsData.items.length,
            itemBuilder: (context, index) => Column(
              children: [
                UserProductItem(
                    productsData.items[index].id,
                  productsData.items[index].title,
                  productsData.items[index].imageUrl
                ),
                Divider()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
