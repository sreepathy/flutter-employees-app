import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpHandler {
  static final HttpHandler _httpHandler = new HttpHandler._internal();

  static HttpHandler get() {
    return _httpHandler;
  }

  HttpHandler._internal();

  static Future<Map> getData(String url) async {
      http.Response res = await http.get(url); // get api call
      Map data = json.decode(res.body);
      print(res.body);
      return data;
  }

  static Future<Map> getDataApi(String url, Map<String, dynamic> header) async {
    http.Response res = await http.get(url, headers: header); // get api call
    Map data = json.decode(res.body);
    print(res.body);
    return data;
  }

  static Future<Map> postData(String url, Map<String, dynamic> poData) async {
      http.Response res = await http.post(url, body: poData); // post api call
      Map data = json.decode(res.body);
      print(res.body);
      return data;
  }

  static Future<Map> postDataApi(String url, Map<String, dynamic> header) async {
    http.Response res = await http.post(url, headers: header); // post api call
    Map data = json.decode(res.body);
    print(res.body);
    return data;
  }
}
