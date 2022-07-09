import 'package:clean_api/clean_api.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  CleanApi.instance.setup(
    baseUrl: "https://vast-tadpole-28.hasura.app/api/rest/",
  );
  CleanApi.instance.setToken(
      {"x-hasura-admin-secret": "you need to create your own admin secret"});
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Handle Api in Flutter',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const HomePage(),
    );
  }
}
