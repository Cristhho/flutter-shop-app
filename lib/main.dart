import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/screens/products_overview_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/user_products_screen.dart';
import 'screens/edit_product_screen.dart';
import 'screens/auth_screen.dart';
import 'providers/products.dart';
import 'providers/cart.dart';
import 'providers/orders.dart';
import 'providers/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => Auth()
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (context) => Products('', [], ''),
          update: (context, auth, prevState) => Products(
            auth.token!,
            prevState == null ? [] : prevState.items,
            auth.userId!
          )
        ),
        ChangeNotifierProvider(
            create: (context) => Cart()
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (context) => Orders([], ''),
          update: (context, auth, prevState) => Orders(
            prevState == null ? [] : prevState.orders,
            auth.token!
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato'
          ),
          home: auth.isAuth ? ProductsOverviewScreen() : AuthScreen(),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName : (ctx) => CartScreen(),
            OrdersScreen.routeName : (ctx) => OrdersScreen(),
            UserProductsScreen.routeName : (ctx) => UserProductsScreen(),
            EditProductScreen.routeName : (ctx) => EditProductScreen(),
            //AuthScreen.routeName : (ctx) => AuthScreen(),
          },
        ),
      ),
    );
  }
}
