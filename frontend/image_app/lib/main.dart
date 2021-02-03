import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Main(),
    );
  }
}

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  File _image;

  String prediction = "";

  double _imagewidth;

  double _imageheight;

  selectfromImagepicker() async {
    var _image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (_image == null) return;

    print("image has been selected");

    predict(_image);
  }

  void predict(File image) async {
    await uploadandpredict(image);

    FileImage(image)
        .resolve(ImageConfiguration())
        .addListener((ImageStreamListener((ImageInfo info, bool _) {
          setState(() {
            _imagewidth = info.image.width.toDouble();
            _imageheight = info.image.height.toDouble();
          });
        })));

    setState(() {
      _image = image;
    });
  }

  void uploadandpredict(File imagefile) async {
    var stream =
        new http.ByteStream(DelegatingStream.typed(imagefile.openRead()));

    var length = await imagefile.length();

    var uri = Uri.parse("http://192.168.43.143:8000/predict");

    var request = http.MultipartRequest("POST", uri);

    var multipartFile = http.MultipartFile('image', stream, length,
        filename: basename(imagefile.path));

    request.files.add(multipartFile);

    var res = await request.send();

    var response = await http.Response.fromStream(res);

    print(response.body);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    List<Widget> stackchildren = [];

    stackchildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: size.width,
      child: _image == null ? Text("no image selected") : Image.file(_image),
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text("Image Classifier"),
      ),
      body: Stack(children: stackchildren),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.image),
        tooltip: "Pick from image gallery",
        onPressed: selectfromImagepicker,
      ),
    );
  }
}
