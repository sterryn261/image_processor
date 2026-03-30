import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_processor/provider.dart';

enum Modes { edit, view }

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  Modes modes = Modes.edit;

  @override
  Widget build(BuildContext context) {
    final importedImage = Provider.of<ImportedImage>(context);

    return Column(
      children: [
        Container(
          width: 290,
          margin: EdgeInsets.all(10),
          child: FilledButton(
            onPressed: importedImage.openPicker,
            child: importedImage.originalImage == null
                ? const Text(("Add Image"))
                : const Text("Change Image"),
          ),
        ),
        if (importedImage.originalImage != null)
          Container(
            margin: EdgeInsets.all(10),
            child: SegmentedButton<Modes>(
              showSelectedIcon: false,
              segments: const <ButtonSegment<Modes>>[
                ButtonSegment<Modes>(
                  value: Modes.edit,
                  label: Text('Edit Mode'),
                  icon: Icon(Icons.edit),
                ),
                ButtonSegment<Modes>(
                  value: Modes.view,
                  label: Text('Display Mode'),
                  icon: Icon(Icons.grid_view),
                ),
              ],
              selected: <Modes>{modes},
              onSelectionChanged: (Set<Modes> selection) {
                setState(() {
                  modes = selection.first;
                });
              },
              direction: Axis.horizontal,
            ),
          ),

        SizedBox(
          width: 290,
          height: MediaQuery.of(context).size.height * 0.7,
          child: importedImage.originalImage == null
              ? Container()
              : modes == Modes.view
              ? ViewMode()
              : EditMode(),
        ),
        if (importedImage.originalImage != null)
          Container(
            width: 290,
            margin: EdgeInsets.all(10),
            child: FilledButton(
              onPressed: importedImage.saveImage,
              child: const Text(("Save Image")),
            ),
          ),
      ],
    );
  }
}

class ViewMode extends StatefulWidget {
  const ViewMode({super.key});

  @override
  State<ViewMode> createState() => _ViewModeState();
}

class _ViewModeState extends State<ViewMode> {
  @override
  Widget build(BuildContext context) {
    final importedImage = Provider.of<ImportedImage>(context);

    return ListView(
      children: <Widget>[
        Image.memory(importedImage.originalImage!, width: 280),
        ImageDescription(textContent: "Original"),
        Image.memory(importedImage.grayscaleImage!, width: 280),
        ImageDescription(textContent: "Grayscale"),
        Image.memory(importedImage.redImage!, width: 280),
        ImageDescription(textContent: "Red channel"),
        Image.memory(importedImage.blueImage!, width: 280),
        ImageDescription(textContent: "Blue channel"),
        Image.memory(importedImage.greenImage!, width: 280),
        ImageDescription(textContent: "Green channel"),
        Image.memory(importedImage.canny!, width: 280),
        ImageDescription(textContent: "Edge Detection"),
      ],
    );
  }
}

class ImageDescription extends StatelessWidget {
  const ImageDescription({super.key, required this.textContent});
  final String textContent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 10),
      child: Center(
        child: Text(textContent, style: TextStyle(fontWeight: FontWeight(500))),
      ),
    );
  }
}

class EditMode extends StatefulWidget {
  const EditMode({super.key});

  @override
  State<EditMode> createState() => _EditModeState();
}

class _EditModeState extends State<EditMode> {
  @override
  Widget build(BuildContext context) {
    final importedImage = Provider.of<ImportedImage>(context);

    return ListView(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                importedImage.rotateImage(false);
              },
              icon: Icon(Icons.rotate_90_degrees_cw),
              tooltip: "Rotate Clockwise",
            ),
            IconButton(
              onPressed: () {
                importedImage.rotateImage(true);
              },
              icon: Icon(Icons.rotate_90_degrees_ccw),
              tooltip: "Rotate Counter Clockwise",
            ),
            IconButton(
              onPressed: () {
                importedImage.flipImage(true);
              },
              icon: Icon(Icons.flip),
              tooltip: "Flip Image",
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            importedImage.alpha = 1 * 1.0;
          },
          child: Text("Contrast"),
        ),
        Slider(
          value: importedImage.alpha,
          min: 0.5,
          max: 1.5,
          divisions: 40,
          onChanged: (double value) {
            importedImage.alpha = value;
          },
        ),
        TextButton(
          onPressed: () {
            importedImage.beta = 0 * 1.0;
          },
          child: Text("Brightness"),
        ),
        Slider(
          value: importedImage.beta,
          min: -100,
          max: 100,
          divisions: 200,
          onChanged: (double value) {
            importedImage.beta = value;
          },
        ),
        TextButton(
          onPressed: () {
            importedImage.brightness = 0 * 1.0;
          },
          child: Text("Luminance"),
        ),
        Slider(
          value: importedImage.brightness,
          min: -100,
          max: 100,
          divisions: 200,
          onChanged: (double value) {
            importedImage.brightness = value;
          },
        ),
        TextButton(
          onPressed: () {
            importedImage.warmth = 0 * 1.0;
          },
          child: Text("Warmth"),
        ),
        Slider(
          value: importedImage.warmth,
          min: -20,
          max: 20,
          divisions: 40,
          onChanged: (double value) {
            importedImage.warmth = value;
          },
        ),
        TextButton(
          onPressed: () {
            importedImage.tint = 0 * 1.0;
          },
          child: Text("Tint"),
        ),
        Slider(
          value: importedImage.tint,
          min: -20,
          max: 20,
          divisions: 40,
          onChanged: (double value) {
            importedImage.tint = value;
          },
        ),
      ],
    );
  }
}
