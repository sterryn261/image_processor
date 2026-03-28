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
  Modes modes = Modes.view;

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
          height: MediaQuery.of(context).size.height * 0.8,
          child: importedImage.originalImage == null
              ? Container()
              : modes == Modes.view
              ? ViewMode()
              : EditMode(),
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
            importedImage.brightness = 0 * 1.0;
          },
          child: Text("Brightness"),
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
            importedImage.temperature = 0 * 1.0;
          },
          child: Text("Temperature"),
        ),
        Slider(
          value: importedImage.temperature,
          min: -20,
          max: 20,
          divisions: 40,
          onChanged: (double value) {
            importedImage.temperature = value;
          },
        ),
      ],
    );
  }
}
