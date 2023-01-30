import 'package:clicktoeat/ui/screens/auth/login_form.dart';
import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AuthScreen extends StatefulWidget {
  final bool animate;
  const AuthScreen({Key? key, this.animate = true}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 750),
      );
      Future.delayed(const Duration(milliseconds: 600)).then((value) {
        _animation = Tween<double>(
          begin: 3.5,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: _controller!,
            curve: Curves.fastOutSlowIn,
          ),
        );
        _controller!.addListener(() {
          setState(() {});
        });
        _controller!.forward();
      });
    });
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Hero(
                tag: "logo",
                child: Container(
                  height: MediaQuery.of(context).size.width + 40,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        lightOrange,
                        mediumOrange,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(75),
                      bottomRight: Radius.circular(75),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/clicktoeat_icon.svg",
                        width: 175,
                        height: 175,
                      ),
                      const SizedBox(height: 20),
                      const DefaultTextStyle(
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 60,
                          fontFamily: 'FreeStyleScript',
                        ),
                        child: Text('ClickToEat'),
                      )
                    ],
                  ),
                ),
              ),
              Align(
                alignment: widget.animate
                    ? Alignment(0, _animation?.value ?? 3.5)
                    : Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 425,
                  child: LoginForm(goToSignUpForm: () {}),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
