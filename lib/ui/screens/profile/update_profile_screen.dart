import 'package:clicktoeat/data/exceptions/default_exception.dart';
import 'package:clicktoeat/data/exceptions/field_exception.dart';
import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/ui/components/buttons/clt_gradient_button.dart';
import 'package:clicktoeat/ui/screens/profile/delete_account_screen.dart';
import 'package:clicktoeat/ui/screens/profile/profile_picture_picker.dart';
import 'package:clicktoeat/ui/screens/profile/update_password_screen.dart';
import 'package:clicktoeat/ui/utils/regex_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = "";
  String? nameError;
  String email = "";
  String? emailError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    name = authProvider.user!.username;
    email = authProvider.user!.email;
  }

  void submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<AuthProvider>(context, listen: false).updateAccountInfo(
        username: name,
        email: email,
      );
    } on DefaultException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.error),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    } on FieldException catch (e) {
      var emailError = e.fieldErrors.where(
        (element) => element.field == "email",
      );
      var nameError = e.fieldErrors.where(
        (element) => element.field == "username",
      );
      setState(() {
        _isLoading = false;
        if (emailError.length == 1) {
          this.emailError = emailError.first.error;
        }
        if (nameError.length == 1) {
          this.nameError = nameError.first.error;
        }
      });
      return;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong'),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);
    var currentUser = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ProfilePicturePicker(user: currentUser!),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: currentUser.username,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: const OutlineInputBorder(),
                  errorText: nameError,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Username required';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (nameError == null) return;
                  setState(() {
                    nameError = null;
                  });
                },
                onSaved: (value) {
                  setState(() {
                    name = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: currentUser.email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Email required';
                  }
                  var regex = RegExp(emailRegex);
                  if (!regex.hasMatch(value)) {
                    return 'Invalid email';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (emailError == null) return;
                  setState(() {
                    emailError = null;
                  });
                },
                onSaved: (value) {
                  setState(() {
                    email = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              CltGradientButton(
                onClick: submit,
                isLoading: _isLoading,
                text: "Update Profile",
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CltGradientButton(
                      onClick: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const UpdatePasswordScreen(),
                        ),
                      ),
                      text: 'Edit Password',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CltGradientButton(
                      onClick: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const DeleteAccountScreen(),
                        ),
                      ),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE60000), Color(0xFFFF5E5E)],
                      ),
                      text: 'Delete Account',
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
