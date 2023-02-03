import 'package:clicktoeat/data/exceptions/default_exception.dart';
import 'package:clicktoeat/data/exceptions/field_exception.dart';
import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/ui/components/buttons/clt_gradient_button.dart';
import 'package:clicktoeat/ui/components/typography/clt_heading.dart';
import 'package:clicktoeat/ui/screens/auth/forget_password_screen.dart';
import 'package:clicktoeat/ui/screens/main_screen.dart';
import 'package:clicktoeat/ui/utils/regex_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  final void Function() goToSignUpForm;
  const LoginForm({
    Key? key,
    required this.goToSignUpForm,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
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
        builder: (_) => const MainScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
              const SizedBox(height: 15),
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
              Container(
                width: double.infinity,
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ForgetPasswordScreen(),
                    ),
                  ),
                  child: const Text("Forgot password?"),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: CltGradientButton(
                  onClick: login,
                  isLoading: _isLoading,
                  text: "Login",
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: widget.goToSignUpForm,
                  child: const Text("Don't have an account? Create one here!"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
