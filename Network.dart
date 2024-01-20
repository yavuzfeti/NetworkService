import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mpmatik/Services/Log.dart';
import 'package:mpmatik/Services/Storage.dart';

class Network
{
  String url;

  Network(this.url);

  static Dio dio = Dio();

  static const List<String> baseUrls =
  [
    "",
  ];

  Future<bool> takeToken(bool t) async
  {
    if(t)
    {
      try
      {
        String username = await Storage.read("username");
        String password = await Storage.read("password");
        dynamic response = await Network("").post(
            {
              "userName": username,
              "password": password,
              "isRememberMe": true,
              "languageId": 0
            });
        dio.options.headers['Authorization'] = "Bearer ${response}";
        await Storage.write("token",response);
        return true;
      }
      catch(e,s)
      {
        Log.save(e,s);
        rethrow;
      }
    }
    return false;
  }

  Future<dynamic> get ({int? b, bool? t, String? adres, dynamic parametre, dynamic data}) async => await process(b, t??false, "Get", adres, parametre, data);

  Future<dynamic> post (dynamic data, {int? b, bool? t, String? adres, dynamic parameter}) async => await process(b, t??false, "Post", adres, parameter, data);

  Future<dynamic> put (dynamic data, {int? b, bool? t, String? adres, dynamic parameter}) async => process(b, t??false, "Put", adres, parameter, data);

  Future<dynamic> delete (String? adres, {int? b, bool? t, dynamic parametre, dynamic data}) async => process(b, t??false, "Delete", adres, parametre, data);

  Future<dynamic> process (int? b, bool t, String process, String? adres, dynamic parameter, dynamic data) async
  {
    Response? response;
    String baseUrl = baseUrls[b??1];
    try
    {
      t = await takeToken(t);
      adres = adres == null ? "" : "/$adres";
      switch (process)
      {
        case "Get":
          response = await dio.get("$baseUrl$url$adres", queryParameters: parameter, data: data);
          debug(process, response, baseUrl+url+adres, parameter, data, t);
          return response.data;

        case "Post":
          response = await dio.post("$baseUrl$url$adres", queryParameters: parameter, data: data);
          debug(process, response, baseUrl+url+adres, parameter, data, t);
          return response.data;

        case "Put":
          response = await dio.put("$baseUrl$url$adres", queryParameters: parameter, data: data);
          debug(process, response, baseUrl+url+adres, parameter, data, t);
          return response.data;

        case "Delete":
          response = await dio.delete("$baseUrl$url$adres", queryParameters: parameter, data: data);
          debug(process, response, baseUrl+url+adres, parameter, data, t);
          return response.data;

        default:
          debug(process, response, baseUrl+url+adres, parameter, data, t);
      }
    }
    on DioError catch (e,s)
    {
      debug(process, response, baseUrl+url+adres!, parameter, data, t, e: e.toString(),s: s);
      throw (e.response!=null) ? (e.response!.toString()) : e;
    }
    catch (e,s)
    {
      debug(process, response, baseUrl+url+adres!, parameter, data, t, e: e.toString(), s: s);
      rethrow;
    }
  }

  debug(String process, Response? response, String link, dynamic parameter, dynamic data, bool t, {String? e, StackTrace? s})
  {
    /*
    if(kDebugMode)
    {
      if(e!=null)
      {
        print(" \nHATA OLUŞTU: $e\n$s ");
      }
      if(t)
      {
        print(" \nTOKEN DEĞİŞTİ: ${dio.options.headers['Authorization']}\n ");
      }
      print(" \n$process | KOD: ${response?.statusCode.toString()} | URL: $link | PARAMETRE: $parameter\n ");
      print("GÖNDERİLEN VERİ: ${data.toString()}\n ");
      print("ALINAN VERİ: ${response?.data.toString()}\n ");
    }*/
  }
}
