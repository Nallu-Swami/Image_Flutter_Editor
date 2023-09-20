import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

// Your ColorFilters class
class ColorFilters {
  static const greyscale = ColorFilter.mode(
    Colors.grey,
    BlendMode.saturation,
  );

  static const sepia = ColorFilter.mode(
    Colors.brown,
    BlendMode.hue,
  );

  static const invert = ColorFilter.mode(
    Colors.black,
    BlendMode.difference,
  );
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Basic Photo Filters',
    theme: ThemeData(primarySwatch: Colors.deepOrange),
    home: MyHomePage(
      title: 'NalluSwami PhotoEditor',
    ),
  );
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<int>? imageBytes;
  img.Image? editedImage; // Track the edited image
  ColorFilter? currentFilter; // Track the current filter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: pickImage,
          ),
          IconButton( // Add a "Save" button to the AppBar
            icon: Icon(Icons.save),
            onPressed: () {
              // Implement your save logic here
              // You can save the edited image or apply the filter to the original image
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ColorFiltered(
                  colorFilter: currentFilter ?? ColorFilter.mode(
                      Colors.orange, BlendMode.color),
                  child: buildImage(),
                ),
              ),
            ),
          ),
          buildFilterButtons(),
        ],
      ),
    );
  }

  Future pickImage() async {
    final image =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      final imageBytes = File(image.path).readAsBytesSync();
      final decodedImage =
      img.decodeImage(Uint8List.fromList(imageBytes));

      setState(() {
        this.imageBytes = imageBytes;
        this.editedImage = decodedImage;
        currentFilter = null; // Reset the current filter when a new image is picked
      });
    }
  }

  void applyFilter(ColorFilter filter) {
    setState(() {
      currentFilter = filter;
    });
  }

  Widget buildFilterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        buildFilterButton("Gryscale", ColorFilters.greyscale),
        buildFilterButton("Sepia", ColorFilters.sepia),
        buildFilterButton("Invert", ColorFilters.invert),
      ],
    );
  }

  Widget buildFilterButton(String text, ColorFilter filter) {
    return ElevatedButton(
      onPressed: () {
        applyFilter(filter);
      },
      child: Text(text),
    );
  }

  Widget buildImage() {
    if (editedImage != null) {
      final editedImageBytes =
      Uint8List.fromList(img.encodePng(editedImage!));
      return Image.memory(
        editedImageBytes,
        fit: BoxFit.contain,
      );
    } else {
      return Container();
    }
  }
}
