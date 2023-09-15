import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

class Network
{
  String url;

  Network(this.url);

  static final Dio dio = Dio();

  final String baseUrl = "https://kursdefteri.com.tr/api/";

  Future<void> takeToken() async
  {
    if(dio.options.headers['Authorization'] == null)
    {
      dio.options.headers['Authorization'] = 'Bearer ${await storage.read(key: 'token')}';
      print("TOKEN ATANDI\n");
    }
  }

  Future<dynamic> get ({String? adres, dynamic parametre, dynamic data}) async => await process("Get", adres, parametre, data);

  Future<dynamic> post (dynamic data, {String? adres, dynamic parametre}) async => await process("Post", adres, parametre, data);

  Future<dynamic> put (dynamic data, {String? adres, dynamic parametre}) async => process("Put", adres, parametre, data);

  Future<dynamic> delete (String adres,{dynamic parametre, dynamic data}) async => process("Delete", adres, parametre, data);

  Future<dynamic> process (String process, String? adres, dynamic parametre, dynamic data) async
  {
    Response? response;
    try
    {
      await takeToken();
      adres = adres == null ? "" : "/$adres";
      switch (process)
      {
        case "Get":
          response = await dio.get("$baseUrl$url$adres", queryParameters: parametre, data: data);
          print("GET ÇALIŞTI | Status Kodu: ${response.statusCode} | Url: $baseUrl$url$adres | Adres: $adres | Parametre: $parametre | Veri: $data | Response: ${response.data}");
          return response.data;

        case "Post":
          response = await dio.post("$baseUrl$url$adres", queryParameters: parametre, data: data);
          print("POST ÇALIŞTI | Status Kodu: ${response.statusCode} | Url: $baseUrl$url$adres | Adres: $adres | Parametre: $parametre | Veri: $data | Response: ${response.data}");
          return response.data;

        case "Put":
          response = await dio.put("$baseUrl$url$adres", queryParameters: parametre, data: data);
          print("PUT ÇALIŞTI | Status Kodu: ${response.statusCode} | Url: $baseUrl$url$adres | Adres: $adres | Parametre: $parametre | Veri: $data | Response: ${response.data}");
          return response.data;

        case "Delete":
          response = await dio.delete("$baseUrl$url$adres", queryParameters: parametre, data: data);
          print("DELETE ÇALIŞTI | Status Kodu: ${response.statusCode} | Url: $baseUrl$url$adres | Id: $adres | Parametre: $parametre | Veri: $data | Response: ${response.data}");
          return response.data;

        default:
          throw Exception("Geçersiz: $process");
      }
    }
    on DioError catch (e)
    {
      if(e.response?.statusCode == 401)
      {
        throw Exception("YETKİSİZ GİRİŞ HATASI | Status Kodu: ${e.response?.statusCode} | İşlem: $process | Url: $baseUrl$url$adres | Adres: $adres | Veri: $data\nStatus Mesajı: ${e.response?.statusMessage}\n");
      }
      else if (e.response?.statusCode == 500)
      {
        throw Exception("SUNUCU HATASI | Status Kodu: ${e.response?.statusCode} | İşlem: $process | Url: $baseUrl$url$adres | Adres: $adres | Veri: $data\nStatus Mesajı: ${e.response?.statusMessage}\n");
      }
      throw Exception("DİO HATASI | Status Kodu: ${e.response?.statusCode} | İşlem: $process | Url: $baseUrl$url$adres | Adres: $adres | Veri: $data\nStatus Mesajı: ${e.response?.statusMessage}\n");
    }
    catch (e)
    {
      throw Exception("HATA: $e\n");
    }
  }
}