import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../model/employee.dart';
import '../widget/loader.dart';

class EmployeesPage extends StatefulWidget {
  @override
  _EmployeesPageState createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  List<Employee> empList = new List();
  bool isLoading = true;
  Completer completer;

  @override
  void initState() {
    super.initState();
    getEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employees'),
      ),
      body: isLoading
          ? Center(
              child: Loader(),
            )
          : RefreshIndicator(
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
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png',
                          height: 50,
                          width: 50,
                        ),
                      ),
                      title: Text(employee.name),
                      subtitle: Text(employee.email + '\n' + employee.mobile),
                    ),
                    color: index.isEven ? Colors.grey.shade100 : Colors.white,
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    height: 0.5,
                  );
                },
              ),
            ),
      floatingActionButton: isLoading
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, 'create_employee');
              },
              backgroundColor: isLoading ? Colors.grey : Colors.red,
              child: Icon(Icons.add),
            ),
    );
  }

  getEmployees() async {
    Map<String, String> data = {'action': 'READALL'};

    await Dio()
        .post('https://webapp.syndicatebank.in/api/employees.php',
            data: FormData.from(data))
        .then((response) {
      if (response != null) {
        print(response.statusCode);
        print(response.data);
        List<dynamic> list = json.decode(response.data)['data'];
        setState(() {
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

  Future<Null> _handleRefresh() async {
    completer = new Completer<Null>();
    await getEmployees();
    return completer.future.then((_) {});
  }
}
