import 'dart:io';

import 'package:clicktoeat/domain/user/user.dart';
import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilePicturePicker extends StatefulWidget {
  final User user;
  const ProfilePicturePicker({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ProfilePicturePicker> createState() => _ProfilePicturePickerState();
}

class _ProfilePicturePickerState extends State<ProfilePicturePicker> {
  bool _isUpdatingImage = false;

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);
    var currentUser = authProvider.user;

    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? mediumOrange
                  : Colors.white,
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
          child: _isUpdatingImage
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? lightOrange
                        : Colors.white,
                  ),
                )
              : widget.user.image == null
                  ? const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 100,
                    )
                  : ClipOval(
                      child: Image.network(
                        widget.user.id == currentUser?.id
                            ? currentUser!.image!.url
                            : widget.user.image!.url,
                        fit: BoxFit.cover,
                        loadingBuilder: _loadingBuilder,
                      ),
                    ),
        ),
        if (currentUser != null && currentUser.id == widget.user.id)
          Positioned(
            bottom: 5,
            right: 5,
            child: Material(
              elevation: 4,
              color: Theme.of(context).brightness == Brightness.dark
                  ? ElevationOverlay.colorWithOverlay(
                      Theme.of(context).colorScheme.surface,
                      Colors.white,
                      50,
                    )
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                onTap: () async {
                  var picker = ImagePicker();
                  var image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image == null) return;
                  setState(() {
                    _isUpdatingImage = true;
                  });
                  var file = File(image.path);
                  await Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  ).updateAccountInfo(
                    image: file,
                  );
                  setState(() {
                    _isUpdatingImage = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  child: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        colors: [lightOrange, mediumOrange],
                      ).createShader(
                        Rect.fromLTWH(0, 0, rect.width, rect.height),
                      );
                    },
                    child: const Icon(
                      Icons.camera_alt,
                    ),
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }

  Widget _loadingBuilder(context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    if (loadingProgress.expectedTotalBytes != null) {
      return CircularProgressIndicator(
        value: loadingProgress.cumulativeBytesLoaded /
            loadingProgress.expectedTotalBytes!,
        color: lightOrange,
      );
    }
    return CircularProgressIndicator(
      color: Theme.of(context).brightness == Brightness.dark
          ? lightOrange
          : Colors.white,
    );
  }
}
