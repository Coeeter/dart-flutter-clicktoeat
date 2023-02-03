import 'package:clicktoeat/data/exceptions/default_exception.dart';
import 'package:clicktoeat/data/exceptions/field_exception.dart';
import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/ui/components/buttons/clt_gradient_button.dart';
import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:clicktoeat/ui/utils/regex_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _form = GlobalKey<FormState>();
  var _email = "";
  String? _emailError;
  var _isLoading = false;

  void submit() async {
    FocusScope.of(context).unfocus();
    if (_form.currentState?.validate() == false) return;
    _form.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    try {
      var provider = Provider.of<AuthProvider>(context, listen: false);
      await provider.resetPassword(_email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reset password link sent to your email")),
      );
      Navigator.of(context).pop();
    } on FieldException catch (e) {
      var emailError = e.fieldErrors.where((element) {
        return element.field == "email";
      }).toList();
      setState(() {
        _isLoading = false;
        if (emailError.length == 1) _emailError = emailError[0].error;
      });
    } on DefaultException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.error)),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password?"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _form,
            child: Column(
              children: [
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [lightOrange, mediumOrange],
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.security,
                    size: 200,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: const OutlineInputBorder(),
                    errorText: _emailError,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email is required";
                    }
                    var regex = RegExp(emailRegex);
                    if (!regex.hasMatch(value)) {
                      return "Email is invalid";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _email = value ?? "";
                  },
                  onChanged: (value) {
                    setState(() {
                      _emailError = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                CltGradientButton(
                  onClick: submit,
                  text: "Reset Password",
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
