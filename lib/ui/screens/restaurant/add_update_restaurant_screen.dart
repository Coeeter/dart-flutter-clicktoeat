import 'dart:io';

import 'package:animations/animations.dart';
import 'package:clicktoeat/data/exceptions/default_exception.dart';
import 'package:clicktoeat/data/exceptions/field_exception.dart';
import 'package:clicktoeat/domain/restaurant/restaurant.dart';
import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/providers/restaurant_provider.dart';
import 'package:clicktoeat/ui/components/buttons/clt_gradient_button.dart';
import 'package:clicktoeat/ui/screens/restaurant/add_branch_screen.dart';
import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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
  String? createdRestaurantId;

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 1000),
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
      child: createdRestaurantId == null
          ? AddUpdateRestaurantForm(
              key: const ValueKey(0),
              navigateBack: widget.navigateBack,
              navigateToNextStage: (restaurantId) => setState(() {
                createdRestaurantId = restaurantId;
              }),
            )
          : AddBranchScreen(
              key: const ValueKey(1),
              restaurantId: createdRestaurantId!,
              navigateBack: widget.navigateBack,
            ),
    );
  }
}

class AddUpdateRestaurantForm extends StatefulWidget {
  final void Function() navigateBack;
  final void Function(String restaurantId) navigateToNextStage;
  final Restaurant? restaurant;

  const AddUpdateRestaurantForm({
    Key? key,
    required this.navigateBack,
    required this.navigateToNextStage,
    this.restaurant,
  }) : super(key: key);

  @override
  State<AddUpdateRestaurantForm> createState() =>
      _AddUpdateRestaurantFormState();
}

class _AddUpdateRestaurantFormState extends State<AddUpdateRestaurantForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  File? _image;
  String? _imageError;
  String _name = "";
  String? _nameError;
  String? _descriptionError;
  String _description = "";
  bool _isSubmitting = false;
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
      _isSubmitting = true;
    });
    String insertId;
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
      if (widget.restaurant == null) {
        insertId = await restaurantProvider.createRestaurant(
          authProvider.token!,
          _name,
          _description,
          _image!,
        );
      } else {
        insertId = "";
        await restaurantProvider.updateRestaurant(
          authProvider.token!,
          widget.restaurant!.id,
          _name,
          _description,
          _image!,
        );
      }
    } on FieldException catch (e) {
      var nameError = e.fieldErrors.where((element) {
        return element.field == "name";
      }).toList();
      var descriptionError = e.fieldErrors.where((element) {
        return element.field == "description";
      }).toList();
      return setState(() {
        _isSubmitting = false;
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
        _isSubmitting = false;
      });
    }
    widget.navigateToNextStage(insertId);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      if (widget.restaurant == null) return;
      setState(() {
        _isLoading = true;
      });
      setState(() {
        _name = widget.restaurant!.name;
        _description = widget.restaurant!.description;
      });
      var uri = Uri.parse(widget.restaurant!.image!.url);
      var responseData = await get(uri);
      var uint8list = responseData.bodyBytes;
      var buffer = uint8list.buffer;
      var byteData = ByteData.view(buffer);
      var tempDir = await getTemporaryDirectory();
      var file = await File('${tempDir.path}/img').writeAsBytes(
        buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );
      setState(() {
        _image = file;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.restaurant == null ? "Add Restaurant" : "Update Restaurant",
        ),
        leading: IconButton(
          onPressed: widget.navigateBack,
          splashRadius: 20,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _imagePicker(),
                    const SizedBox(height: 10),
                    Material(
                      elevation: 4,
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: widget.restaurant?.name,
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
                              initialValue: widget.restaurant?.description,
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
                              isLoading: _isSubmitting,
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
