import 'package:flutter/material.dart';

class AnimatedLogo extends StatefulWidget {
  @override
  _AnimatedLogoState createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController animationController;
  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    animation = Tween<double>(begin: 0, end: 4).animate(animationController)
      ..addListener(() {
        setState(() {});
      });
    animationController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return InkWell(
        borderRadius: BorderRadius.horizontal(),
        onTap: () {},
        child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              return Ink(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                    for (int i = 1; i <= 2; i++)
                      BoxShadow(
                          color: Colors.white
                              .withOpacity(animationController.value / 4),
                          spreadRadius: i * animation.value)
                  ]),
                  child: Container(
                      height: height / 3,
                      width: width / 2,
                      child: Image.asset("assets/images/AppIcon.png",
                          fit: BoxFit.contain)));
            }));
  }
}
