import 'package:flutter/material.dart';
import 'package:linout_iust/screens/home_page.dart';
import 'package:provider/provider.dart';
import 'providers/account_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AccountProvider()..loadAccounts(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'IUST Login Manager',
        theme: ThemeData(
          primarySwatch: Colors.cyan,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomePage(),
      ),
    );
  }
}
