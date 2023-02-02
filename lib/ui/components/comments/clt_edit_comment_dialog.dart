import 'package:clicktoeat/data/exceptions/default_exception.dart';
import 'package:clicktoeat/data/exceptions/field_exception.dart';
import 'package:clicktoeat/domain/comment/comment.dart';
import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/providers/comment_provider.dart';
import 'package:clicktoeat/ui/components/buttons/clt_gradient_button.dart';
import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CltEditCommentDialog extends StatefulWidget {
  final Comment comment;

  const CltEditCommentDialog({
    Key? key,
    required this.comment,
  }) : super(key: key);

  @override
  State<CltEditCommentDialog> createState() => _CltEditCommentDialogState();
}

class _CltEditCommentDialogState extends State<CltEditCommentDialog> {
  final _formKey = GlobalKey<FormState>();
  String review = "";
  int rating = 0;
  String? reviewError;
  String? ratingError;
  bool isLoading = false;

  bool _validateRating() {
    if (rating != 0) return true;
    setState(() {
      ratingError = "Rating required!";
    });
    return false;
  }

  void submit() async {
    FocusScope.of(context).unfocus();
    var isReviewValid = _formKey.currentState!.validate();
    var isRatingValid = _validateRating();
    if (!isReviewValid || !isRatingValid) return;
    _formKey.currentState!.save();
    setState(() {
      isLoading = true;
    });
    try {
      var commentProvider = Provider.of<CommentProvider>(
        context,
        listen: false,
      );
      var token = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).token!;
      await commentProvider.updateComment(
        token,
        widget.comment.id,
        review,
        rating,
      );
    } on FieldException catch (e) {
      var reviewError = e.fieldErrors.where(
        (element) => element.field == "review",
      );
      var ratingError = e.fieldErrors.where(
        (element) => element.field == "rating",
      );
      if (reviewError.isNotEmpty) {
        setState(() {
          this.reviewError = reviewError.first.error;
        });
      }
      if (ratingError.isNotEmpty) {
        setState(() {
          this.ratingError = ratingError.first.error;
        });
      }
      setState(() {
        isLoading = false;
      });
      return;
    } on DefaultException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.error)),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }
    _formKey.currentState!.reset();
    setState(() {
      isLoading = false;
      review = "";
      rating = 0;
    });
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      setState(() {
        review = widget.comment.review;
        rating = widget.comment.rating;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width - 64;

    return Center(
      child: FittedBox(
        child: Material(
          elevation: 4,
          child: Container(
            width: width,
            padding: const EdgeInsets.all(10),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Review",
                      border: const OutlineInputBorder(),
                      errorText: reviewError,
                    ),
                    initialValue: widget.comment.review,
                    onChanged: (_) {
                      if (reviewError == null) return;
                      setState(() {
                        reviewError = null;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Review required!";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      setState(() {
                        review = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (rect) {
                          return LinearGradient(
                            colors: ratingError != null
                                ? [Colors.red, Colors.red]
                                : [lightOrange, mediumOrange],
                          ).createShader(
                            Rect.fromLTRB(0, 0, rect.width, rect.height),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            5,
                            (index) {
                              return Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        ratingError = null;
                                        if (rating == index + 1 &&
                                            rating != 1) {
                                          rating--;
                                          return;
                                        }
                                        rating = index + 1;
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    splashRadius: 20,
                                    icon: Icon(
                                      rating >= index + 1
                                          ? Icons.star
                                          : Icons.star_border_outlined,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CltGradientButton(
                          onClick: submit,
                          isLoading: isLoading,
                          text: "Submit",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  if (ratingError != null)
                    Text(
                      ratingError!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
