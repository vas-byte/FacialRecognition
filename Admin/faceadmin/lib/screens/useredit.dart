import 'dart:io';
import 'AlertDialogs.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'global.dart';
import 'package:camera/camera.dart';

late List camera;

class Uedit extends StatefulWidget {
  final String fullName;
  final String uid;
  const Uedit(this.fullName, this.uid);
  @override
  _Uedit createState() => _Uedit();
}

class _Uedit extends State<Uedit> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text("Edit User"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: TextButton(
                onPressed: () async {
                  camera = await availableCameras();
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (context) => GetPhoto(widget.uid)));
                },
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 5,
                    right: 5,
                  ),
                  height: 70,
                  width: double.infinity,
                  child: Card(
                    child: Center(
                      child: ListTile(
                        leading: Icon(
                          CupertinoIcons.camera,
                          color: (() {
                            if (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark) {
                              return Colors.white;
                            } else {
                              return Colors.black;
                            }
                          }()),
                        ),
                        title: Text("Update Photo"),
                        trailing: Icon(
                          Icons.arrow_right,
                          color: (() {
                            if (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark) {
                              return Colors.white;
                            } else {
                              return Colors.black;
                            }
                          }()),
                        ),
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (context) =>
                          UserDetails(widget.fullName, widget.uid)));
                },
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 5,
                    right: 5,
                  ),
                  height: 70,
                  width: double.infinity,
                  child: Card(
                    child: Center(
                      child: ListTile(
                        leading: Icon(
                          Icons.person,
                          color: (() {
                            if (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark) {
                              return Colors.white;
                            } else {
                              return Colors.black;
                            }
                          }()),
                        ),
                        title: Text("Update Name"),
                        trailing: Icon(
                          Icons.arrow_right,
                          color: (() {
                            if (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark) {
                              return Colors.white;
                            } else {
                              return Colors.black;
                            }
                          }()),
                        ),
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}

class GetPhoto extends StatefulWidget {
  final String userUid;
  const GetPhoto(this.userUid);

  @override
  _GetPhoto createState() => _GetPhoto();
}

class _GetPhoto extends State<GetPhoto> {
  bool imageTaken = false;
  File imagePath = File('');
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(camera.last, ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(children: [
          Container(
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                Visibility(
                    visible: !imageTaken,
                    child: Padding(
                        padding: EdgeInsets.only(top: 55),
                        child: SizedBox(
                            width: 300,
                            child: Stack(children: [
                              ClipPath(
                                  clipper: Clip(),
                                  child: CameraPreview(controller)),
                            ])))),
                Visibility(
                  visible: imageTaken,
                  child: Padding(
                      padding: EdgeInsets.only(top: 55),
                      child: CircleAvatar(
                        radius: 150,
                        backgroundImage: FileImage(imagePath),
                      )),
                ),
              ]))),
          Padding(
              padding: EdgeInsets.only(top: 590),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                      visible: !imageTaken,
                      child: ElevatedButton(
                          child: Icon(Icons.camera),
                          style: ButtonStyle(
                              foregroundColor:
                                  MaterialStateProperty.all<Color>(Colors.red),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      side: BorderSide(color: Colors.white)))),
                          onPressed: () async {
                            final image = await controller.takePicture();
                            imagePath = File(image.path);

                            setState(() {
                              imageTaken = true;
                            });
                          })),
                  Visibility(
                    visible: imageTaken,
                    child: ElevatedButton(
                        child: Icon(Icons.edit),
                        style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: BorderSide(color: Colors.white)))),
                        onPressed: () async {
                          setState(() {
                            imageTaken = false;
                          });
                        }),
                  )
                ],
              )),
          Visibility(
              child: Container(
                  padding: EdgeInsets.only(bottom: 20),
                  alignment: Alignment.bottomCenter,
                  child: CircularProgressIndicator(color: Colors.white)),
              visible: isUploading),
          Visibility(
            visible: !isUploading,
            child: Container(
              padding: EdgeInsets.only(bottom: 20),
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 300,
                    height: 50,
                    child: ElevatedButton(
                        child: Text('Next'),
                        style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: BorderSide(color: Colors.white)))),
                        onPressed: () async {
                          if (imageTaken) {
                            setState(() {
                              isUploading = true;
                            });
                            var url =
                                await uploadFile(imagePath, widget.userUid);
                            await FirebaseFirestore.instance
                                .collection("Users")
                                .doc(widget.userUid)
                                .update({
                              'Photo': url,
                              'modifiedType': "MOD",
                              "storedEncodings": false
                            });
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          } else {
                            showAlertDialog(context, "Please Take a Photo!");
                          }
                        }),
                  ),
                ],
              ),
            ),
          )
        ]));
  }

  Future<String> uploadFile(
    File portrait,
    String fN,
  ) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child('Users/$fN/${fN + '.jpg'}');
    UploadTask uploadTask = ref.putFile(portrait);
    String picURL;
    picURL = await (await uploadTask).ref.getDownloadURL();
    return picURL;
  }
}

class Clip extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    print(size);
    Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, size.height / 2 - 150, 300, 300),
          Radius.circular(200)));
    return path;
  }

  @override
  bool shouldReclip(oldClipper) {
    return true;
  }
}

class UserDetails extends StatefulWidget {
  final String fullName;
  final String uid;
  const UserDetails(this.fullName, this.uid);

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation _colorTween;
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    nameController.text = widget.fullName;
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _colorTween = ColorTween(begin: Colors.grey, end: Colors.red)
        .animate(_animationController);

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: AnimatedBuilder(
        animation: _colorTween,
        builder: (context, child) => GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Container(
            alignment: Alignment.center,
            width: double.infinity,
            color: (() {
              if (MediaQuery.of(context).platformBrightness ==
                  Brightness.light) {
                return Colors.grey[100];
              }
            }()),
            height: () {
              if (Platform.isAndroid) {
                return 75.0;
              } else if (Platform.isIOS) {
                return 120.0;
              }
            }(),
            child: Column(
              children: [
                Visibility(
                  visible: isLoading,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
                Visibility(
                  visible: !isLoading,
                  child: SizedBox(
                    height: 60,
                    width: 200,
                    child: ElevatedButton(
                        child: Text(
                          'Update',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              _colorTween.value,
                            ),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: BorderSide(
                                        color: Colors.transparent)))),
                        onPressed: () async {
                          if (nameController.text == widget.fullName) {
                            FocusScope.of(context).unfocus();
                            Navigator.of(context).pop();
                          } else {
                            FocusScope.of(context).unfocus();
                            setState(() {
                              isLoading = true;
                            });
                            await FirebaseFirestore.instance
                                .collection('Users')
                                .doc(widget.uid)
                                .update({'FullName': nameController.text});
                            FirebaseFirestore.instance
                                .collection('Users')
                                .where("isAdmin", isEqualTo: false)
                                .get(GetOptions(source: Source.serverAndCache))
                                .then((QuerySnapshot querySnapshot) {
                              querySnapshot.docs.forEach((doc) {
                                UserNameUID[doc["uid"]] = doc["FullName"];
                              });
                            });
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          }
                        }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text("Update User Details"),
        backgroundColor: Colors.red,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Column(
          children: [
            Container(
                padding: EdgeInsets.only(top: 30, left: 20),
                child: Text(
                  "Full Name:",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 35),
                ),
                alignment: Alignment.centerLeft),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: TextFormField(
                onChanged: (value) {
                  if (value == widget.fullName) {
                    _animationController.reverse();
                  } else {
                    _animationController.forward();
                  }
                },
                controller: nameController,
                style: TextStyle(
                    color: (() {
                  if (MediaQuery.of(context).platformBrightness ==
                      Brightness.light) {
                    return Colors.black;
                  } else {
                    return Colors.white;
                  }
                }())),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(
                        right: 5,
                      ),
                      child: Icon(
                        CupertinoIcons.person_alt_circle_fill,
                        size: 50,
                        color: (() {
                          if (MediaQuery.of(context).platformBrightness ==
                              Brightness.light) {
                            return Colors.black;
                          } else {
                            return Colors.white;
                          }
                        }()),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: (() {
                          if (MediaQuery.of(context).platformBrightness ==
                              Brightness.light) {
                            return Colors.black;
                          } else {
                            return Colors.white;
                          }
                        }()),
                        width: 0,
                      ),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: (() {
                          if (MediaQuery.of(context).platformBrightness ==
                              Brightness.light) {
                            return Colors.black;
                          } else {
                            return Colors.white;
                          }
                        }()),
                        width: 0,
                      ),
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    filled: true,
                    hintStyle: TextStyle(
                        color: (() {
                      if (MediaQuery.of(context).platformBrightness ==
                          Brightness.light) {
                        return Colors.black;
                      } else {
                        return Colors.white;
                      }
                    }())),
                    hintText: "Enter your Name",
                    fillColor: Colors.white12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
