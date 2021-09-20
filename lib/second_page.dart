import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  final String? payload;

  const SecondPage({
    Key? key,
    required this.payload,
  }) : super(key:key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Page"),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(payload ?? '',
            style: TextStyle(fontSize: 48),
            textAlign: TextAlign.center,
            ),
            const SizedBox(height: 34,),
            Text(payload?? '', style: TextStyle(fontSize: 32),)
          ],
        ),
      ),
    );
  }
}