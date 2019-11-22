import 'package:flutter/material.dart';
import 'package:kobe_tmdb/views/movie_sc.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext build){
    return MaterialApp(
      title: "Kobe.io TMDb",
      theme: ThemeData(
          primarySwatch: Colors.blue
      ),
      home: MovieScreen(),
    );
  }
}
