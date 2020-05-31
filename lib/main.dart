import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/products_overview_screen.dart';
import './screens/product_details_screen.dart';
import './screens/orders_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './screens/cart_screen.dart';
import './providers/orders.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import 'providers/auth.dart';
import 'screens/auth_screen.dart';
import './screens/splash_screen.dart';
import './helpers/custom_route.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: Auth(),
          ),
          ChangeNotifierProvider.value(
            value: Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            update: (ctx, auth, previoesProducts) => Products(
              auth.token,
              auth.userId,
              previoesProducts.items,
            ),
            create: (_) => Products('', '', []),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            update: (ctx, auth, previoesOrders) => Orders(
              auth.token,
              auth.userId,
              previoesOrders.orders,
            ),
            create: (_) => Orders('', '', []),
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'MyShop',
            theme: ThemeData(
                fontFamily: 'Lato',
                pageTransitionsTheme: PageTransitionsTheme(builders: {
                  TargetPlatform.android: CustomPageTransitionsBuilder(),
                  TargetPlatform.iOS: CustomPageTransitionsBuilder(),
                }),
                primarySwatch: Colors.purple,
                accentColor: Colors.deepOrange),
            home: auth.isAuth
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            routes: {
              ProductDetailesScreen.routeName: (ctx) => ProductDetailesScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
              AuthScreen.routeName: (ctx) => AuthScreen(),
            },
          ),
        ));
  }
}
