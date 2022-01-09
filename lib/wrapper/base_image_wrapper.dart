import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BaseImageWrapper extends StatelessWidget {

  final Widget child;
  final Function? function;
  final bool hasContinue;

  BaseImageWrapper({required this.child, this.function, this.hasContinue = true});

  @override
  Widget build(BuildContext context) {

    Widget continueButton = Container();
    Function function = this.function ?? (){};

    if(hasContinue){
      continueButton = Positioned(
        bottom: 10,
        right: 10,
        child: Container(
          height: 45,
          width: 150,
          decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.all(Radius.circular(50))
          ),
          child: Center(
            child: TextButton(
              onPressed: () => function(),
              child: Text(
                "Continue",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return FractionallySizedBox(
      widthFactor: 0.85,
      heightFactor: 0.9,
      child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: this.child,
            ),

            continueButton,
          ],
      ),
    );
  }
}
