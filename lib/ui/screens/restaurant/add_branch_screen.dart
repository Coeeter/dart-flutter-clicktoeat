import 'package:clicktoeat/data/exceptions/default_exception.dart';
import 'package:clicktoeat/domain/branch/branch.dart';
import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/providers/restaurant_provider.dart';
import 'package:clicktoeat/ui/components/buttons/clt_gradient_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AddBranchScreen extends StatefulWidget {
  final String restaurantId;
  final void Function() navigateBack;
  final Branch? branch;

  const AddBranchScreen({
    Key? key,
    required this.restaurantId,
    required this.navigateBack,
    this.branch,
  }) : super(key: key);

  @override
  State<AddBranchScreen> createState() => _AddBranchScreenState();
}

class _AddBranchScreenState extends State<AddBranchScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  LatLng? _latLng;
  String? _latLngError;
  String _address = "";
  bool _isLoading = false;

  bool _isLatLngValid() {
    if (_latLng != null) return true;
    setState(() {
      _latLngError = "Location of restaurant required!";
    });
    return false;
  }

  void submit() async {
    FocusScope.of(context).unfocus();
    var isFormValid = _formKey.currentState?.validate() == true;
    var isLatLngValid = _isLatLngValid();
    if (!isFormValid || !isLatLngValid) return;
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
      await restaurantProvider.addBranchToRestaurant(
        authProvider.token!,
        widget.restaurantId,
        _address,
        _latLng!.latitude,
        _latLng!.longitude,
      );
      if (widget.branch != null) {
        await restaurantProvider.deleteBranchFromRestaurant(
          authProvider.token!,
          widget.branch!.id,
          widget.restaurantId,
        );
      }
    } on DefaultException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.error)),
      );
      return setState(() {
        _isLoading = false;
      });
    }
    widget.navigateBack();
  }

  @override
  void initState() {
    super.initState();
    if (widget.branch != null) {
      setState(() {
        _latLng = LatLng(
          widget.branch!.latitude,
          widget.branch!.longitude,
        );
        _address = widget.branch!.address;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var initialCameraPosition = const CameraPosition(
      target: LatLng(1.3610, 103.8200),
      zoom: 10.25,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: widget.navigateBack,
          splashRadius: 20,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(widget.branch == null ? "Add a Branch" : "Edit Branch"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _locationPicker(context, initialCameraPosition),
              const SizedBox(height: 30),
              Material(
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: widget.branch?.address,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text("Address"),
                        ),
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Address required!";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          setState(() {
                            _address = value!;
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

  Widget _locationPicker(
    BuildContext context,
    CameraPosition initialCameraPosition,
  ) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: GoogleMap(
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            initialCameraPosition: initialCameraPosition,
            markers: {
              if (_latLng != null)
                Marker(
                  markerId: MarkerId("Location${_latLng?.longitude}"),
                  position: _latLng!,
                )
            },
            onTap: (latLng) => setState(() {
              _latLng = latLng;
              _latLngError = null;
            }),
          ),
        ),
        const SizedBox(height: 10),
        AnimatedOpacity(
          opacity: _latLngError == null ? 0 : 1,
          duration: const Duration(milliseconds: 100),
          child: AnimatedSlide(
            offset: _latLngError == null
                ? const Offset(-0.5, 0)
                : const Offset(0, 0),
            duration: const Duration(milliseconds: 100),
            child: Text(
              _latLngError ?? "",
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
