import 'dart:io';

import 'package:clicktoeat/data/exceptions/default_exception.dart';
import 'package:clicktoeat/data/exceptions/field_exception.dart';
import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/providers/restaurant_provider.dart';
import 'package:clicktoeat/ui/components/buttons/clt_gradient_button.dart';
import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddRestaurantScreen extends StatefulWidget {
  final void Function() navigateBack;
  const AddRestaurantScreen({
    Key? key,
    required this.navigateBack,
  }) : super(key: key);

  @override
  State<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  File? _image;
  String? _imageError;
  String _name = "";
  String? _nameError;
  String? _descriptionError;
  String _description = "";
  bool _isLoading = false;

  bool _isImageValid() {
    if (_image != null) return true;
    setState(() {
      _imageError = "Profile picture required!";
    });
    return false;
  }

  void submit() async {
    FocusScope.of(context).unfocus();
    var isTextFieldsValid = _formKey.currentState?.validate() == true;
    var isImageValid = _isImageValid();
    if (!isTextFieldsValid || !isImageValid) return;
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    try {
      var restaurantProvider = Provider.of<RestaurantProvider>(
        context,
        listen: false,
      );
      var authProvider = Provider.of<AuthProvider>(
        context,
        listen: false,
      );
      await authProvider.getToken();
      await restaurantProvider.createRestaurant(
        authProvider.token!,
        _name,
        _description,
        _image!,
      );
    } on FieldException catch (e) {
      var nameError = e.fieldErrors.where((element) {
        return element.field == "name";
      }).toList();
      var descriptionError = e.fieldErrors.where((element) {
        return element.field == "description";
      }).toList();
      return setState(() {
        _isLoading = false;
        if (nameError.length == 1) {
          _nameError = nameError[0].error;
        }
        if (descriptionError.length == 1) {
          _descriptionError = descriptionError[0].error;
        }
      });
    } on DefaultException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.error)),
      );
      return setState(() {
        _isLoading = false;
      });
    }
    widget.navigateBack(); // TODO: Change to add branch state
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Restaurant"),
        leading: IconButton(
          onPressed: widget.navigateBack,
          splashRadius: 20,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _imagePicker(),
              const SizedBox(height: 30),
              Material(
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          label: const Text("Name"),
                          errorText: _nameError,
                        ),
                        textInputAction: TextInputAction.next,
                        onChanged: (_) {
                          if (_nameError == null) return;
                          setState(() {
                            _nameError = null;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Name required!";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          setState(() {
                            _name = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          label: const Text("Description"),
                          errorText: _descriptionError,
                        ),
                        minLines: 3,
                        maxLines: 10,
                        onChanged: (_) {
                          if (_descriptionError == null) return;
                          setState(() {
                            _descriptionError = null;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Description required!";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          setState(() {
                            _description = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 25),
                      CltGradientButton(
                        onClick: submit,
                        text: "Submit",
                        isLoading: _isLoading,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Material(
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: mediumOrange,
                    width: 2,
                  ),
                  color: _image != null ? Colors.white : null,
                ),
                child: _image == null
                    ? ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [lightOrange, mediumOrange],
                        ).createShader(
                          Rect.fromLTWH(
                            0,
                            0,
                            bounds.width,
                            bounds.height,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 100,
                        ),
                      )
                    : Image.file(_image!),
              ),
            ),
          ),
          const SizedBox(height: 20),
          CltGradientButton(
            onClick: () async {
              var image = await ImagePicker().pickImage(
                source: ImageSource.gallery,
              );
              if (image == null) return;
              setState(() {
                _image = File(image.path);
                _imageError = null;
              });
            },
            text: _image == null ? "Choose Picture" : "Change Picture",
          ),
          const SizedBox(height: 10),
          AnimatedOpacity(
            opacity: _imageError == null ? 0 : 1,
            duration: const Duration(milliseconds: 100),
            child: AnimatedSlide(
              offset: _imageError == null
                  ? const Offset(-0.5, 0)
                  : const Offset(0, 0),
              duration: const Duration(milliseconds: 100),
              child: Text(
                _imageError ?? "",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
