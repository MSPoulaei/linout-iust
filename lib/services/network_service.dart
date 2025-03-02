import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';

class NetworkService {
  static const String loginUrl = 'https://login.iust.ac.ir/login.php';
  static const String logoutUrl = 'http://192.168.253.14/logout';

  Future<bool> connect(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
          'Content-Type': 'application/x-www-form-urlencoded',
          // Add other headers as needed
        },
        body: {
          'dst': 'status.html',
          'popup': 'false',
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return await make2ndRequest(response.body);
      }
      return false;
    } catch (e) {
      print('Connection error: $e');
      return false;
    }
  }

  Future<bool> make2ndRequest(String htmlContent) async {
    try {
      final soup = BeautifulSoup(htmlContent);
      final form = soup.find('form', attrs: {'name': 'login'});

      if (form == null) return false;

      final actionUrl = form.attributes['action'];
      final hiddenInputs = <String, String>{};

      // Extract hidden inputs
      form.findAll('input', attrs: {'type': 'hidden'}).forEach((input) {
        final name = input.attributes['name'];
        final value = input.attributes['value'];
        if (name != null && value != null) {
          hiddenInputs[name] = value;
        }
      });

      // Extract username and password from script
      // This part might need adjustment based on the actual HTML structure
      final script =
          soup.find('script', string: RegExp('.*function doLogin\\(.*'));
      if (script != null) {
        final scriptText = script.text;
        final usernameLine = scriptText.split('\n').firstWhere(
            (line) => line.contains('document.login.username.value'));
        final passwordLine = scriptText.split('\n').firstWhere(
            (line) => line.contains('document.login.password.value'));

        final username = RegExp(r"'(.*?)'").firstMatch(usernameLine)!.group(1);
        final password = RegExp(r"'(.*?)'").firstMatch(passwordLine)!.group(1);

        hiddenInputs['username'] = username!;
        hiddenInputs['password'] = password!;
      }
      final response = await http.post(
        Uri.parse(actionUrl!),
        body: hiddenInputs,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Second request error: $e');
      return false;
    }
  }

  Future<bool> disconnect() async {
    try {
      final response = await http.get(Uri.parse(logoutUrl));
      return response.statusCode == 200;
    } catch (e) {
      print('Disconnect error: $e');
      return false;
    }
  }

  Future<List<String>> getInfo() async {
    var responseLogin;
    try {
      responseLogin = await http.get(Uri.parse(loginUrl));
    } catch (e) {
      return [];
    }
    if (responseLogin.statusCode == 403) {
      final soup = BeautifulSoup(responseLogin.body);
      var ip = soup.find("p")!.text;
      ip = RegExp(r"(?:[0-9]{1,3}\.){3}[0-9]{1,3}").firstMatch(ip)!.group(0)!;
      return [ip];
    }
    try {
      const accountInfoUrl = "http://192.168.253.14/status";
      final response = await http.get(Uri.parse(accountInfoUrl));
      //utf8
      final decodedBody = utf8.decode(response.bodyBytes);
      final soup = BeautifulSoup(decodedBody);
      // there is a table inside a div with class ddown
      final table = soup.findAll('table')[1];
      final rows = table.children[0].children;
      var ip = rows[0].text;
      //extract ipv4 using regex
      ip = RegExp(r"(?:[0-9]{1,3}\.){3}[0-9]{1,3}").firstMatch(ip)!.group(0)!;
      var totalUsage = rows[1].text;
      // Extract download and upload values using regex
      final usageMatch =
          RegExp(r"([\d.]+ \w+) / ([\d.]+ \w+)").firstMatch(totalUsage);
      if (usageMatch != null) {
        totalUsage = '${usageMatch.group(1)} / ${usageMatch.group(2)}';
      } else {
        totalUsage = 'N/A';
      }
      var duration = rows[2].text;
      // Extract duration using regex
      final durationMatch = RegExp(r"زمان سپری شده:(.*)").firstMatch(duration);
      if (durationMatch != null) {
        duration = durationMatch.group(1)!;
      } else {
        duration = 'N/A';
      }
      return [ip, totalUsage, duration];
    } catch (e) {
      return [];
    }
  }
}
