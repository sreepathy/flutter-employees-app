import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syndicate_login/model/employee.dart';

import '../widget/loader.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<Employee> empList = new List();
  bool isLoading = true;
  CameraPosition initialCameraPosition =
  new CameraPosition(target: LatLng(12.9716, 77.5946), zoom: 12);
  Completer completer;
  LatLng syndicateDitLatLng = LatLng(12.9441011, 77.6212545);
  bool isListPressed = false;
  int _selectedIndex = 1;
  int _selectedEmployee = 0;
  int _EmployeeCount = 0;
  bool _bottomSheetIsOpen = false;

  @override
  void initState() {
    super.initState();
    getEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(isListPressed ? 'Employees' : 'Home'),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                isListPressed ? Icons.location_on : Icons.list,
                color: Colors.white,
              ),
              onPressed: () async {
                setState(() {
                  isListPressed = !isListPressed;
                });
              }),
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () async {
              showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (dialogContext) {
                    return SimpleDialog(
                      title: Text('Do you want to logout?'),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            FlatButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.pop(dialogContext);
                              },
                            ),
                            FlatButton(
                              child: Text('Yes'),
                              onPressed: () async {
                                Navigator.pop(dialogContext);
                                SharedPreferences _pref =
                                await SharedPreferences.getInstance();
                                _pref.clear();
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginPage()));
                              },
                            )
                          ],
                        )
                      ],
                    );
                  });
            },
          )
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('assets/logo.png')),
              )
            ],
          ),
        ),
      ),
      key: scaffoldKey,
      body: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(15),
            child: isListPressed
                ? RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView.separated(
                itemCount: empList.length,
                itemBuilder: (context, index) {
                  Employee employee = empList[index];
                  return Container(
                    child: ListTile(
                      isThreeLine: true,
                      leading: Material(
                        shape: CircleBorder(
                            side: BorderSide(color: Colors.redAccent)),
                        child: ClipOval(
                          child: Image.memory(
                            base64Decode(employee.avatar),
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(employee.name),
                      subtitle:
                      Text(employee.email + '\n' + employee.mobile),
                    ),
                    color: index.isEven
                        ? Colors.grey.shade100
                        : Colors.white,
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    height: 0.5,
                  );
                },
              ),
            )
                : GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: initialCameraPosition,
              markers: _createMarker(),
              onMapCreated: (GoogleMapController controller) {
                if (_controller == null) _controller.complete(controller);
                mapController = controller;
              },
            ),
          ),
          isLoading ? Loader() : SizedBox()
        ],
      ),
      floatingActionButton: isLoading || !isListPressed
          ? null
          : FloatingActionButton(
        onPressed: () async {
          final result =
          await Navigator.pushNamed(context, 'create_employee');
          if (result != null && result == 'refresh') {
            _handleRefresh();
          }
        },
        backgroundColor: isLoading ? Colors.grey : Colors.red,
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (selectedItemIndex) {
          print('Tapped ' + selectedItemIndex.toString());
          setState(() {
            _selectedIndex = selectedItemIndex;
            int changePosition = 0;
            switch (selectedItemIndex) {
              case 0: // Previous button
                changePosition = _selectedEmployee > 0 ? -1 : 0;
                break;
              case 1: // info button
                openCurrentEmployeeInfo(context);
                break;
              case 2: // Next button
                changePosition = _selectedEmployee < _EmployeeCount - 1 ? 1 : 0;
                break;
            }
            if (changePosition != 0) {
              if (_bottomSheetIsOpen) {
                _bottomSheetIsOpen = false;
                Navigator.pop(context);
              }
              _selectedEmployee += changePosition;
              print('Setting employee to ' + _selectedEmployee.toString());
              setCurrentEmployee();
            }
          });
        },
        items: [
          _selectedEmployee == 0
              ? NavBarButton(Icons.stop, 'First')
              : NavBarButton(Icons.skip_previous, 'Previous'),
          NavBarButton(Icons.info_outline, 'Info'),
          _selectedEmployee < empList.length - 1
              ? NavBarButton(Icons.skip_next, 'Next')
              : NavBarButton(Icons.stop, 'Last'),
        ],
      ),
    );
  }

  Set<Marker> _createMarker() {
    return empList.map<Marker>((employee) {
      return Marker(
          markerId: MarkerId(employee.id.toString()),
          position: employee.latLong,
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: employee.name));
    }).toSet();
  }

  setCurrentEmployee() async {
    setState(() {});
    LatLng selectedEmployeeLocation = empList[_selectedEmployee].latLong;
    mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        new CameraPosition(
          target: selectedEmployeeLocation,
          zoom: 17.0,
        ),
      ),
    );
  }

  openCurrentEmployeeInfo(BuildContext context) {
    _bottomSheetIsOpen = true;
    scaffoldKey.currentState.showBottomSheet((context) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(

          children: <Widget>[
            Image.memory(
              base64Decode(empList[_selectedEmployee].avatar), height: 150,),
            Row(
                children:
                [
                  Text('Name: ', style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.tealAccent)),
                  Text(empList[_selectedEmployee].name, style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(
                    fontWeight: FontWeight.bold, color: Colors.white,),),
                ]
            ),
            Row(
                children:
                [
                  Text('Employee No: ', style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.tealAccent),),
                  Text(empList[_selectedEmployee].id.toString(), style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(
                    fontWeight: FontWeight.bold, color: Colors.white,),),
                ]

            ),
            Row(
                children:
                [
                  Text('Email: ', style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.tealAccent),),
                  Text(empList[_selectedEmployee].email, style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(
                    fontWeight: FontWeight.bold, color: Colors.white,),),
                ]

            ),

            Row(
                children:
                [
                  Text('Phone: ', style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.tealAccent),),
                  Text(empList[_selectedEmployee].mobile, style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(
                    fontWeight: FontWeight.bold, color: Colors.white,),),
                ]

            ),

            Row(
                children:
                [
                  Text('DOB: ', style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.tealAccent),),
                  Text(
                  new DateFormat("dd-MM-yyyy").format(DateTime.parse( empList[_selectedEmployee].dob))
                    , style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(
                    fontWeight: FontWeight.bold, color: Colors.white,),),
                ]

            ),
            Row(crossAxisAlignment: CrossAxisAlignment.start,
                children:
                [
                  Text('Address: ', style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.tealAccent),),
                  Flexible(
                    child: Text(
                      empList[_selectedEmployee].address.replaceAll(new RegExp(r'[\n]'), ', ')
                      , style: Theme
                        .of(context)
                        .textTheme
                        .subhead
                        .copyWith(
                      fontWeight: FontWeight.bold, color: Colors.white,),),
                  ),
                ]

            ),
            RaisedButton(
              child: Text('Close'),
              onPressed: (){
                Navigator.pop(context);
              },
            )


          ],
        ),
      );
    });
  }

  getEmployees() async {
    Map<String, String> data = {'action': 'READALL'};

    await Dio()
        .post('https://webapp.syndicatebank.in/api/employees.php',
        data: FormData.from(data))
        .then((response) {
      if (response != null) {
        //print(response.statusCode);
        //print(response.data);
        List<dynamic> list = json.decode(response.data)['data'];
        setState(() {
          _EmployeeCount = list.length;
          empList = list.map<Employee>((jsonItem) {
            return Employee.fromJson(jsonItem);
          }).toList();
          if (completer != null) {
            completer.complete(null);
          }
          isLoading = false;
        });
      } else {
        print('Response is null');
      }
    });
  }

  BottomNavigationBarItem NavBarButton(IconData icon, String label) {
    return BottomNavigationBarItem(
      title: Text(label),
      icon: Icon(icon, size: 40, color: Colors.red, semanticLabel: label),
    );
  }

  Future<Null> _handleRefresh() async {
    completer = new Completer<Null>();
    await getEmployees();
    return completer.future.then((_) {});
  }
}
