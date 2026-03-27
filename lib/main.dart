import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import './mod/image_manipulate.dart' as im;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ImportedImage(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(children: [Sidebar(), DisplayImg()]),
          ),
        ),
      ),
    );
  }
}

class ImportedImage extends ChangeNotifier {
  Uint8List? _originalImage;
  Uint8List? _currentImage;
  Uint8List? _grayscaleImage;
  // Uint8List? _originalImage;
  // Uint8List? _originalImage;

  Uint8List? get originalImage => _originalImage;
  Uint8List? get currentImage => _currentImage;
  Uint8List? get grayscaleImage => _grayscaleImage;
  // Uint8List? get image => _originalImage;
  // Uint8List? get image => _originalImage;

  final _pick = ImagePicker();

  Future<void> _openPicker() async {
    final XFile? picked = await _pick.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      throw Exception("No Image Found");
    }
    _originalImage = await picked.readAsBytes();
    _currentImage = _originalImage;
    _grayscaleImage = await im.ImageManipulate().grayscaleImage(
      input: _originalImage!,
    );

    notifyListeners();
  }
}

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
          width: MediaQuery.of(context).size.width * 0.2,
          margin: EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: Provider.of<ImportedImage>(
              context,
              listen: false,
            )._openPicker,
            child: importedImage.originalImage == null
                ? const Text(("Add Image"))
                : const Text("Change Image"),
          ),
        ),
        if (importedImage.originalImage != null)
          Column(
            children: [
              // TODO: Add segmented button to alter between DIsplay mode and Edit mode
              SegmentedButton<Modes>(
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
              ),
              if (modes == Modes.view) ViewMode(),
              if (modes == Modes.edit) Text("something in edit"),
            ],
          ),
      ],
    );
  }
}

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
            ? Image.memory(
                importedImage.currentImage!,
                height: double.infinity,
                width: double.infinity,
              )
            : Text(
                "Add or drop an image here",
                style: TextStyle(fontWeight: FontWeight(500)),
              ),
      ),
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

    return importedImage.originalImage != null
        ? Column(
            children: [
              Container(child: Image.memory(importedImage.grayscaleImage!)),
            ],
          )
        : Container(child: Text("Something went wrong. Try again later."));
  }
}
