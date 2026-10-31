import 'package:flutter/material.dart';

class LayoutPage extends StatefulWidget {
  const LayoutPage({super.key});

  @override
  State<LayoutPage> createState() => _LayoutPageState();
 
}

class _LayoutPageState extends State<LayoutPage> {
  final data = [
    'Flutter',
    'Next.js',
    'React',
    'PHP',
    'MySQL',
    'Laravel',
    'Go'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            width: 200,
            height: 150,
            color: Colors.amber,
            child: Image.asset('assets/images/Amba.jpg'),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
            onPressed: (){}, 
            icon: Icon(Icons.bookmark)),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Chip(label: Text("New")))
        ],
      )
    );
  }
}
