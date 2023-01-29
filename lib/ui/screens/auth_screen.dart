import 'package:clicktoeat/ui/components/buttons/gradient_button.dart';
import 'package:clicktoeat/ui/components/typography/clt_heading.dart';
import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;
  Animation<double>? animation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 750),
      );
      Future.delayed(const Duration(milliseconds: 200)).then((value) {
        animation = Tween<double>(
          begin: 3.5,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: controller!,
            curve: Curves.fastOutSlowIn,
          ),
        );
        controller!.addListener(() {
          setState(() {});
        });
        controller!.forward();
      });
    });
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: lightOrange,
    ));

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
                alignment: Alignment(0, animation?.value ?? 3.5),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 425,
                  child: Card(
                    elevation: 4,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      child: Form(
                        child: Column(
                          children: [
                            const CltHeading(text: "Login"),
                            const SizedBox(height: 25),
                            const TextField(
                              decoration: InputDecoration(
                                label: Text("Email"),
                                border: OutlineInputBorder(),
                              ),
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),
                            const TextField(
                              decoration: InputDecoration(
                                label: Text("Password"),
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              keyboardType: TextInputType.visiblePassword,
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: GradientButton(
                                onClick: () {},
                                text: "Login",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
