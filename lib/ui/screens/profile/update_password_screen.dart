import 'package:clicktoeat/data/exceptions/default_exception.dart';
import 'package:clicktoeat/data/exceptions/field_exception.dart';
import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/ui/components/buttons/clt_gradient_button.dart';
import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:clicktoeat/ui/utils/regex_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({Key? key}) : super(key: key);

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String oldPassword = '';
  String? oldPasswordError;
  String newPassword = '';
  String? newPasswordError;
  bool _isUpdatingPassword = false;

  bool _obscureTextOld = true;
  bool _obscureTextNew = true;
  bool _obscureTextConfirm = true;

  void submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() {
      _isUpdatingPassword = true;
    });
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.login(authProvider.user!.email, oldPassword);
    } on DefaultException catch (e) {
      setState(() {
        oldPasswordError = e.error;
        _isUpdatingPassword = false;
      });
      return;
    } on FieldException catch (e) {
      var passwordError = e.fieldErrors.where(
        (element) => element.field == 'password',
      );
      setState(() {
        if (passwordError.length == 1) {
          oldPasswordError = passwordError.first.error;
        }
        _isUpdatingPassword = false;
      });
      return;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong'),
        ),
      );
      setState(() {
        _isUpdatingPassword = false;
      });
      return;
    }
    try {
      await authProvider.updatePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully'),
        ),
      );
      Navigator.of(context).pop();
    } on DefaultException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.error),
        ),
      );
      setState(() {
        _isUpdatingPassword = false;
      });
    } on FieldException catch (e) {
      var passwordError = e.fieldErrors.where(
        (element) => element.field == 'password',
      );
      setState(() {
        if (passwordError.length == 1) {
          newPasswordError = passwordError.first.error;
        }
        _isUpdatingPassword = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong'),
        ),
      );
      setState(() {
        _isUpdatingPassword = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Password'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [lightOrange, mediumOrange],
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.lock,
                    size: 200,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Old Password',
                    border: const OutlineInputBorder(),
                    errorText: oldPasswordError,
                    suffixIcon: IconButton(
                      icon: _obscureTextOld
                          ? const Icon(Icons.visibility_off)
                          : const Icon(Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscureTextOld = !_obscureTextOld;
                        });
                      },
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  obscureText: _obscureTextOld,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Old password is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      oldPasswordError = null;
                    });
                  },
                  onSaved: (value) {
                    oldPassword = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: const OutlineInputBorder(),
                    errorText: newPasswordError,
                    errorMaxLines: 3,
                    suffixIcon: IconButton(
                      icon: _obscureTextNew
                          ? const Icon(Icons.visibility_off)
                          : const Icon(Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscureTextNew = !_obscureTextNew;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureTextNew,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'New password is required';
                    }
                    var regex = RegExp(createPasswordRegex);
                    if (!regex.hasMatch(value)) {
                      return 'Password must be at least 8 characters long, contain at least one uppercase letter, one lowercase letter, one number and one special character';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      newPasswordError = null;
                      newPassword = value;
                    });
                  },
                  onSaved: (value) {
                    newPassword = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: _obscureTextConfirm
                          ? const Icon(Icons.visibility)
                          : const Icon(Icons.visibility_off),
                      onPressed: () => setState(
                        () {
                          _obscureTextConfirm = !_obscureTextConfirm;
                        },
                      ),
                      splashRadius: 20,
                    ),
                  ),
                  obscureText: _obscureTextConfirm,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Confirm password is required';
                    }
                    if (value != newPassword) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CltGradientButton(
                  onClick: submit,
                  isLoading: _isUpdatingPassword,
                  text: "Update Password",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
