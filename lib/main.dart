import 'dart:async';
import 'dart:io';
import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
      title: '超愛rescute!!!',
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: SafeArea(child: Home()))));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String appbarname = '';
  TextEditingController first = TextEditingController();
  TextEditingController second = TextEditingController();
  GlobalKey<FormState> key = GlobalKey<FormState>();
  int? assets;
  List<XFile> _imageFileList = [];
  bool ontap = false;
  int clicked = 0;
  late SharedPreferences pref;
  final ImagePicker _picker = ImagePicker();
  void saveimage(List<String> path) => pref.setStringList('images', path);
  List<String>? getimage() => pref.getStringList('images');
  void savename(String path) => pref.setString('name', path);
  String? getname() => pref.getString('name');
  void saveint(String key, int num) => pref.setInt(key, num);
  Future<void> init() async => pref = await SharedPreferences.getInstance();
  int? getint(String key) => pref.getInt(key);

  @override
  void initState() {
    init().then((value) {
      String? value = getname();
      if (value == null)
        appbarname = "your image name";
      else
        appbarname = value;

      List<String>? valuel = getimage();
      if (valuel != null) {
        if (valuel[0].startsWith("http") || valuel[0].startsWith("https")) {
          first.text = valuel[0];
          second.text = valuel[1];
          assets = 1;
        } else {
          _imageFileList = [XFile(valuel[0]), XFile(valuel[1])];
          assets = 0;
        }
        setState(() {});
        print(valuel);
      } else
        assets = 67;

      int? ivalue = getint(assets.toString());
      if (ivalue != null) clicked = ivalue;

      setState(() {});
    });

    super.initState();
  }

  getassets(Size size) async {
    try {
      await _picker
          .pickImage(
        maxWidth: 2048,
        maxHeight: 2048,
        source: ImageSource.gallery,
      )
          .then((value) async {
        showDialog(
            builder: (BuildContext context) {
              Timer(Duration(seconds: 1), () => Navigator.pop(context));
              return AlertDialog(
                title: Text("select second image"),
              );
            },
            barrierDismissible: false,
            context: context);
        var twice;
        Timer(Duration(seconds: 1), () async {
          twice = await _picker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 2048,
            maxHeight: 2048,
          );
          if (value != null && twice != null) {
            _imageFileList.clear();
            setState(() {
              _imageFileList.add(value);
              _imageFileList.add(twice);
            });
            saveimage([value.path, twice.path]);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Here are some error on selecting photo"),
            ));
          }
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
  }

  Future<void> _showMyDialog(bool image) async {
    String name = '';
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) => AlertDialog(
        title: Text('Enter your image ${image ? "url" : "name"}'),
        content: Form(
          key: key,
          child: image
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: first,
                      validator: (v) {
                        if (!v!.startsWith("http")) {
                          if (!v.startsWith("https")) {
                            return "Please provide a vaild url(start with http/https)";
                          }
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Enter first image url",
                      ),
                    ),
                    TextFormField(
                      controller: second,
                      validator: (v) {
                        if (!v!.startsWith("http")) {
                          if (!v.startsWith("https")) {
                            return "Please provide a vaild url(start with http/https)";
                          }
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Enter second image url",
                      ),
                    ),
                  ],
                )
              : TextField(
                  onChanged: (v) => name = v,
                  decoration: InputDecoration(hintText: "Enter image name"),
                ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('confirm'),
            onPressed: () {
              if (key.currentState!.validate()) {
                if (image) {
                  Navigator.of(context).pop();
                  setState(() {
                    assets = 1;
                  });
                  saveimage([first.text, second.text]);
                }
              }
              if (!image) {
                if (name.isNotEmpty) {
                  savename(name);
                  appbarname = name;
                }
                Navigator.pop(context);
                setState(() {});
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        GestureDetector(
          onPanStart: (detail) => setState(() {
            ontap = true;
            clicked++;
            saveint(assets.toString(), clicked);
          }),
          onPanEnd: (detial) => setState(() => ontap = false),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: assets != null
                ? BoxDecoration(
                    image: DecorationImage(
                        image: assets == 0
                            ? FileImage(
                                File(_imageFileList[!ontap ? 0 : 1].path))
                            : assets == 1
                                ? NetworkImage(
                                    !ontap ? first.text : second.text)
                                : assets == 15
                                    ? AssetImage(
                                        "images/1${!ontap ? '5' : '6'}.jpg")
                                    : assets! > 60
                                        ? AssetImage(
                                            "images/6${!ontap ? '7' : '8'}.jpg")
                                        : AssetImage(
                                                "images/${!ontap ? '7' : '8'}.jpg")
                                            as ImageProvider,
                        fit: BoxFit.cover))
                : BoxDecoration(),
            child: Align(
              child: BorderedText(
                strokeWidth: 3,
                strokeColor: Colors.blueGrey[800]!,
                child: Text(
                  clicked.toString(),
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),
              ),
              alignment: Alignment(0, -0.7),
            ),
          ),
        ),
        Container(
          color: Colors.black54,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Expanded(
                  child: GestureDetector(
                onLongPress: () => _showMyDialog(false),
                child: Text(
                  "Pop $appbarname",
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              )),
              PopupMenuButton<int>(
                child: Icon(Icons.more_vert, color: Colors.white),
                onSelected: (result) {
                  assets = result;
                  int? ivalue = getint(assets.toString());
                  if (ivalue != null)
                    clicked = ivalue;
                  else
                    clicked = 0;
                  if (result == 0)
                    getassets(size);
                  else if (result == 1)
                    _showMyDialog(true);
                  else
                    setState(() {});
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                  const PopupMenuItem(value: 0, child: Text('from gallery')),
                  const PopupMenuItem(value: 1, child: Text('from network')),
                  const PopupMenuItem(value: 67, child: Text('露恰露恰')),
                  const PopupMenuItem(value: 15, child: Text('15號')),
                  const PopupMenuItem(value: 7, child: Text('歐貝爾')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
