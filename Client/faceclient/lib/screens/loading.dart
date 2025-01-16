import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  const Loading({required Key key}) : super(key: key);

  @override
  State<Loading> createState() => _Loading();
}

class _Loading extends State<Loading> with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: false);

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            child: Align(
              alignment: Alignment.center,
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 55, 0, 0),
            child: Align(
              child: CircularProgressIndicator(
                value: controller.value,
                strokeWidth: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
