import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:syndicate_login/model/employee.dart';
import 'package:syndicate_login/utils/text_validators.dart';
import 'package:image_picker_modern/image_picker_modern.dart';
import '../widget/loader.dart';

class CreateEmployeePage extends StatefulWidget {
  @override
  _CreateEmployeePageState createState() => _CreateEmployeePageState();
}

class _CreateEmployeePageState extends State<CreateEmployeePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _form = new GlobalKey<FormState>();
  bool _autovalidate = false;
  bool isLoading = false;
  bool isPassportAvailable = true;
  bool isMale = true;
  File avatar;
  DateTime selectedDate;
  LatLng latLng;
  TextEditingController dobController = new TextEditingController();
  TextEditingController latLongController = new TextEditingController();
  Employee employee = new Employee();

  captureImage(ImageSource source) async {
    await ImagePicker.pickImage(source: source, maxHeight: 200)
        .then((image) async {
      if (image != null) {
        String base64Image = base64Encode(await image.readAsBytes());
        print(base64Image);
        setState(() {
          employee.avatar = base64Image;
          avatar = image;
        });
      } else {
        setState(() {
          employee.avatar = "";
          avatar = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Create Employee'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            _scaffoldKey.currentState
                                .showBottomSheet((context) {
                              return Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                            color: theme.disabledColor))),
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                          captureImage(ImageSource.camera);
                                        },
                                        child: Material(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(
                                                Icons.camera,
                                                color: theme.primaryColor,
                                                size: 70,
                                              ),
                                              Text('Camera')
                                            ],
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                          captureImage(ImageSource.gallery);
                                        },
                                        child: Material(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(
                                                Icons.image,
                                                color: theme.primaryColor,
                                                size: 70,
                                              ),
                                              Text('Gallery')
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                          },
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white,
                            backgroundImage: avatar != null
                                ? FileImage(
                                    avatar,
                                  )
                                : null,
                            child: avatar == null
                                ? Icon(
                                    Icons.person,
                                    size: 55,
                                  )
                                : SizedBox(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Form(
                            key: _form,
                            autovalidate: _autovalidate,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                TextFormField(
                                  validator: TextValidators.validateMandatory,
                                  decoration: InputDecoration(
                                    border: UnderlineInputBorder(),
                                    prefixIcon: Icon(Icons.person),
                                    labelText: 'Name',
                                    hintText: 'Name',
                                  ),
                                  onSaved: (text) {
                                    setState(() {
                                      employee.name = text;
                                    });
                                  },
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                TextFormField(
                                  validator: TextValidators.validatePhone,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      border: UnderlineInputBorder(),
                                      prefixIcon: Icon(Icons.phone),
                                      labelText: 'Mobile',
                                      hintText: 'Mobile'),
                                  maxLength: 10,
                                  onSaved: (text) {
                                    setState(() {
                                      employee.mobile = text;
                                    });
                                  },
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  validator: TextValidators.validateEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      border: UnderlineInputBorder(),
                                      prefixIcon: Icon(Icons.alternate_email),
                                      labelText: 'Email',
                                      hintText: 'Email'),
                                  onSaved: (text) {
                                    setState(() {
                                      employee.email = text;
                                    });
                                  },
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                GestureDetector(
                                    onTap: () async {
                                      final DateTime picked =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: selectedDate != null
                                            ? selectedDate
                                            : DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now(),
                                      );
                                      if (picked != null &&
                                          picked != selectedDate)
                                        setState(() {
                                          selectedDate = picked;
                                          dobController.text =
                                              DateFormat('dd-MM-yyyy')
                                                  .format(selectedDate);
                                        });
                                    },
                                    child: AbsorbPointer(
                                      absorbing: true,
                                      child: TextFormField(
                                        validator:
                                            TextValidators.validateMandatory,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        controller: dobController,
                                        decoration: InputDecoration(
                                            border: UnderlineInputBorder(),
                                            prefixIcon:
                                                Icon(Icons.calendar_today),
                                            labelText: 'DOB',
                                            hintText: 'DOB'),
                                        onSaved: (text) {
                                          setState(() {
                                            employee.dob =
                                                selectedDate.toString();
                                          });
                                        },
                                      ),
                                    )),
                                SizedBox(
                                  height: 25,
                                ),
                                TextFormField(
                                  validator: TextValidators.validateAddress,
                                  keyboardType: TextInputType.emailAddress,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                      border: UnderlineInputBorder(),
                                      prefixIcon: Icon(Icons.home),
                                      labelText: 'Address',
                                      hintText: 'Address'),
                                  onSaved: (text) {
                                    setState(() {
                                      employee.address = text;
                                    });
                                  },
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      await Geolocator()
                                          .getCurrentPosition(
                                              desiredAccuracy:
                                                  LocationAccuracy.best)
                                          .then((position) {
                                        setState(() {
                                          isLoading = false;
                                          latLng = LatLng(position.latitude,
                                              position.longitude);
                                        });
                                        latLongController.text =
                                            '${latLng.latitude}, ${latLng.longitude}';
                                      });
                                    },
                                    child: AbsorbPointer(
                                      absorbing: true,
                                      child: TextFormField(
                                        validator:
                                            TextValidators.validateMandatory,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        controller: latLongController,
                                        decoration: InputDecoration(
                                            border: UnderlineInputBorder(),
                                            prefixIcon: Icon(Icons.gps_fixed),
                                            labelText: 'LatLong',
                                            hintText: 'LatLong'),
                                        onSaved: (text) {
                                          setState(() {
                                            employee.latLong = latLng;
                                          });
                                        },
                                      ),
                                    )),
                                SizedBox(
                                  height: 45,
                                ),
                                RaisedButton(
                                  onPressed: onSubmitted,
                                  elevation: 15,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Text(
                                      'Submit',
                                      style: textTheme.subhead
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                  color: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            )),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          isLoading ? Loader() : SizedBox()
        ],
      ),
    );
  }

  onSubmitted() async {
    final FormState form = _form.currentState;
    if (!form.validate()) {
      //NOT VALIDATED
      setState(() {
        _autovalidate = true; // Start validating on every change.
      });
    } else {
      //VALIDATED
      if (avatar == null) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Please select an avatar'),
        ));
      } else {
        setState(() {
          employee.id = new DateTime.now().millisecondsSinceEpoch;
        });
        form.save();
        print(employee.toJson());
        postEmployee();
      }
    }
  }

  postEmployee() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> data = {'action': 'CREATE'};
    data.addEntries(employee.toJson().entries);

    await Dio()
        .post('https://webapp.syndicatebank.in/api/employees.php',
            data: FormData.from(data))
        .then((response) {
      if (response != null) {
        Map data = json.decode(response.data);
        print(response.statusCode);
        print(data);

        if (data['error'] == null && data['code'] == '-99') {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(data['msg']),
          ));
          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              isLoading = false;
            });
            Navigator.pop(context, 'refresh');
          });
        } else {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(data['error']),
          ));
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('Response is null');
      }
    });
  }
}
