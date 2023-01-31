import 'package:clicktoeat/data/exceptions/default_exception.dart';
import 'package:clicktoeat/data/exceptions/field_exception.dart';
import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/ui/components/buttons/clt_gradient_button.dart';
import 'package:clicktoeat/ui/components/typography/clt_heading.dart';
import 'package:clicktoeat/ui/screens/restaurant/home_screen.dart';
import 'package:clicktoeat/ui/utils/regex_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpForm extends StatefulWidget {
  final void Function() goToLoginPage;
  const SignUpForm({
    Key? key,
    required this.goToLoginPage,
  }) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final GlobalKey<FormState> _firstStageFormKey = GlobalKey();
  final GlobalKey<FormState> _secondStageFormKey = GlobalKey();

  Offset _firstStageOffset = const Offset(0, 0);
  Offset _secondStageOffset = const Offset(1.1, 0);

  String _username = "";
  String? _usernameError;
  String _email = "";
  String? _emailError;
  String _password = "";
  String? _passwordError;
  bool _isLoading = false;

  void animateStages(int index) {
    setState(() {
      _firstStageOffset =
          index == 0 ? const Offset(0, 0) : const Offset(-1.1, 0);
      _secondStageOffset =
          index == 0 ? const Offset(1.1, 0) : const Offset(0, 0);
    });
  }

  void signUp() async {
    FocusScope.of(context).unfocus();
    var isFirstStageValid = _firstStageFormKey.currentState!.validate();
    var isSecondStageValid = _secondStageFormKey.currentState!.validate();
    if (!isFirstStageValid || !isSecondStageValid) {
      if (!isFirstStageValid) animateStages(0);
      return;
    }
    _firstStageFormKey.currentState?.save();
    _secondStageFormKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    var provider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await provider.register(_username, _email, _password);
    } on DefaultException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.error)),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    } on FieldException catch (e) {
      var usernameError = e.fieldErrors.where((element) {
        return element.field == "username";
      }).toList();
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
        if (usernameError.length == 1) _usernameError = usernameError[0].error;
      });
      if (_usernameError != null || _passwordError != null) {
        animateStages(0);
      }
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedSlide(
          offset: _firstStageOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          child: SignUpFirstStage(
            formKey: _firstStageFormKey,
            goToLoginPage: widget.goToLoginPage,
            animateToNextStage: () => animateStages(1),
            onEmailSaved: (value) => setState(() {
              _email = value;
            }),
            onUsernameSaved: (value) => setState(() {
              _username = value;
            }),
            emailError: _emailError,
            usernameError: _usernameError,
            setEmailError: (value) => setState(() {
              _emailError = value;
            }),
            setUsernameError: (value) => setState(() {
              _usernameError = value;
            }),
          ),
        ),
        AnimatedSlide(
          offset: _secondStageOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          child: SignUpSecondStage(
            formKey: _secondStageFormKey,
            isLoading: _isLoading,
            animateToPrevStage: () => animateStages(0),
            onPasswordSaved: (value) => setState(() {
              _password = value;
            }),
            passwordError: _passwordError,
            setPasswordError: (value) => setState(() {
              _passwordError = value;
            }),
            onSubmit: signUp,
          ),
        ),
      ],
    );
  }
}

class SignUpFirstStage extends StatefulWidget {
  final void Function() goToLoginPage;
  final void Function() animateToNextStage;
  final void Function(String) onUsernameSaved;
  final void Function(String) onEmailSaved;
  final GlobalKey<FormState> formKey;
  final String? usernameError;
  final String? emailError;
  final void Function(String?) setUsernameError;
  final void Function(String?) setEmailError;

  const SignUpFirstStage({
    Key? key,
    required this.goToLoginPage,
    required this.animateToNextStage,
    required this.onEmailSaved,
    required this.onUsernameSaved,
    required this.formKey,
    required this.emailError,
    required this.usernameError,
    required this.setEmailError,
    required this.setUsernameError,
  }) : super(key: key);

  @override
  State<SignUpFirstStage> createState() => _SignUpFirstStageState();
}

class _SignUpFirstStageState extends State<SignUpFirstStage> {
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
          key: widget.formKey,
          child: Column(
            children: [
              const CltHeading(text: "Create an account"),
              const SizedBox(height: 25),
              TextFormField(
                decoration: InputDecoration(
                  label: const Text("Username"),
                  border: const OutlineInputBorder(),
                  errorText: widget.usernameError,
                ),
                onChanged: (_) {
                  if (widget.usernameError == null) return;
                  widget.setUsernameError(null);
                },
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Username required!";
                  }
                  return null;
                },
                onSaved: (value) {
                  widget.onUsernameSaved(value!);
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: InputDecoration(
                  label: const Text("Email"),
                  border: const OutlineInputBorder(),
                  errorText: widget.emailError,
                ),
                onChanged: (_) {
                  if (widget.emailError == null) return;
                  widget.setEmailError(null);
                },
                textInputAction: TextInputAction.done,
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
                  widget.onEmailSaved(value!);
                },
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: CltGradientButton(
                  onClick: () => widget.animateToNextStage(),
                  text: "Next",
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: widget.goToLoginPage,
                  child: const Text("Already have an account? Login here"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpSecondStage extends StatefulWidget {
  final void Function() animateToPrevStage;
  final void Function(String) onPasswordSaved;
  final GlobalKey<FormState> formKey;
  final String? passwordError;
  final void Function(String?) setPasswordError;
  final void Function() onSubmit;
  final bool isLoading;

  const SignUpSecondStage({
    Key? key,
    required this.animateToPrevStage,
    required this.onPasswordSaved,
    required this.formKey,
    required this.passwordError,
    required this.setPasswordError,
    required this.onSubmit,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<SignUpSecondStage> createState() => _SignUpSecondStageState();
}

class _SignUpSecondStageState extends State<SignUpSecondStage> {
  String _password = "";
  bool _passwordObscureText = true;
  bool _confirmPasswordObscureText = true;

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
          key: widget.formKey,
          child: Column(
            children: [
              const CltHeading(text: "Secure your Account"),
              const SizedBox(height: 25),
              TextFormField(
                decoration: InputDecoration(
                  label: const Text("Password"),
                  border: const OutlineInputBorder(),
                  errorText: widget.passwordError,
                  suffixIcon: IconButton(
                    icon: _passwordObscureText
                        ? const Icon(Icons.visibility)
                        : const Icon(Icons.visibility_off),
                    onPressed: () => setState(() {
                      _passwordObscureText = !_passwordObscureText;
                    }),
                    splashRadius: 20,
                  ),
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.visiblePassword,
                obscureText: _passwordObscureText,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Password required!";
                  }
                  var regex = RegExp(createPasswordRegex);
                  if (!regex.hasMatch(value)) {
                    return "Password should be 8 letters long, contain one special character, number, lowercase and uppercase characters";
                  }
                  return null;
                },
                onChanged: (value) {
                  _password = value;
                  if (widget.passwordError == null) return;
                  widget.setPasswordError(null);
                },
                onSaved: (value) {
                  widget.onPasswordSaved(value!);
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: InputDecoration(
                  label: const Text("Confirm password"),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: _confirmPasswordObscureText
                        ? const Icon(Icons.visibility)
                        : const Icon(Icons.visibility_off),
                    onPressed: () => setState(() {
                      _confirmPasswordObscureText =
                          !_confirmPasswordObscureText;
                    }),
                    splashRadius: 20,
                  ),
                ),
                obscureText: _confirmPasswordObscureText,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.visiblePassword,
                validator: (value) {
                  if (_password != value) {
                    return "Passwords do not match!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 50),
              Row(
                children: [
                  Expanded(
                    child: CltGradientButton(
                      text: "Cancel",
                      onClick: () => widget.animateToPrevStage(),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE60000),
                          Color(0xFFFF5E5E),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CltGradientButton(
                      onClick: () => widget.onSubmit(),
                      isLoading: widget.isLoading,
                      text: "Sign Up",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
