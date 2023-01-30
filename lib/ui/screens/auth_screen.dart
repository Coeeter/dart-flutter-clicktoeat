import 'package:clicktoeat/data/exceptions/default_exception.dart';
import 'package:clicktoeat/data/exceptions/field_exception.dart';
import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/ui/components/buttons/clt_gradient_button.dart';
import 'package:clicktoeat/ui/components/typography/clt_heading.dart';
import 'package:clicktoeat/ui/screens/home_screen.dart';
import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:clicktoeat/ui/utils/regex_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

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

  final GlobalKey<FormState> _form = GlobalKey();
  bool _obscureText = true;

  String _email = "";
  String? _emailError;
  String _password = "";
  String? _passwordError;
  bool _isLoading = false;

  void login() async {
    FocusScope.of(context).unfocus();
    if (_form.currentState?.validate() == false) return;
    _form.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    var provider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await provider.login(_email, _password);
    } on DefaultException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.error)),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    } on FieldException catch (e) {
      var emailError = e.fieldErrors.where((element) {
        return element.field == "email";
      }).toList();
      var passwordError = e.fieldErrors.where((element) {
        return element.field == "password";
      }).toList();
      setState(() {
        _isLoading = false;
        if (emailError.length == 1) _emailError = emailError[0].error;
        if (passwordError.length == 1) _passwordError = passwordError[0].error;
      });
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }

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
                        key: _form,
                        child: Column(
                          children: [
                            const CltHeading(text: "Login"),
                            const SizedBox(height: 25),
                            TextFormField(
                              decoration: InputDecoration(
                                label: const Text("Email"),
                                border: const OutlineInputBorder(),
                                errorText: _emailError,
                              ),
                              onChanged: (_) {
                                if (_emailError == null) return;
                                setState(() {
                                  _emailError = null;
                                });
                              },
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Email required!";
                                }
                                var regex = RegExp(emailRegex);
                                if (!regex.hasMatch(value)) {
                                  return "Invalid email!";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _email = value!;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              decoration: InputDecoration(
                                label: const Text("Password"),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: _obscureText
                                      ? const Icon(Icons.visibility)
                                      : const Icon(Icons.visibility_off),
                                  onPressed: () => setState(() {
                                    _obscureText = !_obscureText;
                                  }),
                                  splashRadius: 20,
                                ),
                                errorText: _passwordError,
                              ),
                              onChanged: (_) {
                                if (_passwordError == null) return;
                                setState(() {
                                  _passwordError = null;
                                });
                              },
                              obscureText: _obscureText,
                              keyboardType: TextInputType.visiblePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Password required!";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _password = value!;
                              },
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: CltGradientButton(
                                onClick: login,
                                isLoading: _isLoading,
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
