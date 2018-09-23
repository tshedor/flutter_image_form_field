import "package:flutter/material.dart";

class PhotoUploadButton extends StatelessWidget {
  const PhotoUploadButton({
    this.count = 0,
    this.shouldAllowMultiple = true
  });

  final int count;
  final bool shouldAllowMultiple;

  String _computeButtonText() {
    if (count == null || count == 0) {
      if (shouldAllowMultiple) {
        return "Upload Photos";
      } else {
        return "Upload Photo";
      }
    } else {
      if (shouldAllowMultiple) {
        return "Upload More";
      } else {
        return "Choose Another";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = _computeButtonText();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight,
        borderRadius: const BorderRadius.all(const Radius.circular(6.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.camera,
            color: Theme.of(context).primaryColor
          ),
          Text(
            "     $text",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold
            )
          )
        ]
      )
    );
  }
}
