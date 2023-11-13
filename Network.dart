import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//flutter_secure_storage: ^8.0.0
//dio: ^5.0.1
//Network.createBaseUrl("");
//if(e.toString().contains("401")){al();}

const storage = FlutterSecureStorage();

class Network
{
  String url;

  Network(this.url);

  static final Dio dio = Dio();

  static late String baseUrl;

  static createBaseUrl(String value) async
  {
    baseUrl = value;
    await storage.write(key: "baseurl", value: value);
    print("Base url oluşturuldu: $baseUrl\n");
  }

  static tempBaseUrl(String value) async
  {
    await storage.write(key: "baseurl", value: baseUrl);
    baseUrl = value;
    print("Base url değiştirildi: $baseUrl\n");
  }

  static resetBaseUrl() async
  {
    try
    {
      baseUrl = (await storage.read(key: "baseurl"))!;
      print("Base url sıfırlandı: $baseUrl\n");
    }
    catch(e){}
  }

  Future<void> takeToken() async
  {
    if(dio.options.headers['Authorization'] == null)
    {
      dio.options.headers['Authorization'] = 'Bearer ${await storage.read(key: 'token')}';
      print("Token atandı\n");
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
          print("GET çalıştı | Status Kodu: ${response.statusCode} | Url: $baseUrl$url$adres | Adres: $adres | Parametre: $parametre | Veri: $data | Response: ${response.data}");
          print("GET response data: ${response.data}");
          return response.data;

        case "Post":
          response = await dio.post("$baseUrl$url$adres", queryParameters: parametre, data: data);
          print("POST çalıştı | Status Kodu: ${response.statusCode} | Url: $baseUrl$url$adres | Adres: $adres | Parametre: $parametre | Veri: $data | Response: ${response.data}");
          print("POST response data: ${response.data}");
          return response.data;

        case "Put":
          response = await dio.put("$baseUrl$url$adres", queryParameters: parametre, data: data);
          print("PUT çalıştı | Status Kodu: ${response.statusCode} | Url: $baseUrl$url$adres | Adres: $adres | Parametre: $parametre | Veri: $data | Response: ${response.data}");
          print("PUT response data: ${response.data}");
          return response.data;

        case "Delete":
          response = await dio.delete("$baseUrl$url$adres", queryParameters: parametre, data: data);
          print("DELETE çalıştı | Status Kodu: ${response.statusCode} | Url: $baseUrl$url$adres | Id: $adres | Parametre: $parametre | Veri: $data | Response: ${response.data}");
          print("DELETE response data: ${response.data}");
          return response.data;

        default:
          throw Exception("Geçersiz: $process");
      }
    }
    on DioError catch (e)
    {
      if(e.response?.statusCode == 401)
      {
        try
        {
          String? username = await storage.read(key: "username");
          String? password = await storage.read(key: "password");
          dynamic response2 = await Network("Account/login").post({
            "userName": username,
            "password": password,
          });
          dio.options.headers['Authorization'] = 'Bearer ${response2["data"]["accessToken"]}';
          print("Token atandı\n");
          await storage.write(key: "token", value: response2["data"]["accessToken"]);
        }
        catch (e2)
        {
          throw Exception("YETKİ HATASI | Status Kodu: ${e.response?.statusCode} | İşlem: $process | Url: $baseUrl$url$adres | Adres: $adres | Veri: $data\nStatus Mesajı: ${e.response?.statusMessage}\n");
        }
      }
      else if (e.response?.statusCode == 500)
      {
        throw Exception("SUNUCU HATASI | Status Kodu: ${e.response?.statusCode} | İşlem: $process | Url: $baseUrl$url$adres | Adres: $adres | Veri: $data\nStatus Mesajı: ${e.response?.statusMessage}\n");
      }
      else if (e.response?.statusCode == 400)
      {
        throw Exception("İSTEK HATASI | Status Kodu: ${e.response?.statusCode} | İşlem: $process | Url: $baseUrl$url$adres | Adres: $adres | Veri: $data\nStatus Mesajı: ${e.response?.statusMessage}\n");
      }
      throw Exception("DİO HATASI | Status Kodu: ${e.response?.statusCode} | İşlem: $process | Url: $baseUrl$url$adres | Adres: $adres | Veri: $data\nStatus Mesajı: ${e.response?.statusMessage}\n");
    }
    catch (e)
    {
      throw Exception("HATA: $e\n");
    }
  }
}
