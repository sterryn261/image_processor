import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_processor/provider.dart';

class DisplayImg extends StatefulWidget {
  const DisplayImg({super.key});

  @override
  State<DisplayImg> createState() => _DisplayImgState();
}

class _DisplayImgState extends State<DisplayImg> {
  @override
  Widget build(BuildContext context) {
    final importedImage = Provider.of<ImportedImage>(context);
    return Center(
      child: Container(
        color: Colors.grey[100],
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.9,

        child: importedImage.originalImage != null
            ? InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(20.0),
                minScale: 1,
                maxScale: 6,
                child: Image.memory(
                  importedImage.currentImage!,
                  height: double.infinity,
                  width: double.infinity,
                ),
              )
            : Text(
                "Add an image here...",
                style: TextStyle(fontWeight: FontWeight(500)),
              ),
      ),
    );
  }
}
