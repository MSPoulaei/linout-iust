import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

class AccountProvider with ChangeNotifier {
  final _secureStorage = FlutterSecureStorage();
  List<Account> _accounts = [];
  Account? _currentAccount;
  encrypt.Key? _encryptionKey=null;
  encrypt.IV? _iv=null;
  // Constants for storing key and IV
  static const String KEY_STORAGE_KEY = 'encryption_key';
  static const String IV_STORAGE_KEY = 'encryption_iv';
  List<Account> get accounts => _accounts;
  Account? get currentAccount => _currentAccount;
  // Constructor
  AccountProvider() {
    _initialize();
  }

  // Initialization method called in constructor
  Future<void> _initialize() async {
    await initializeEncryption();
    await loadAccounts();
  }
  Future<void> initializeEncryption() async {
    if(_encryptionKey != null && _iv !=null) return;
    // Try to retrieve existing key and IV
    String? storedKey = await _secureStorage.read(key: KEY_STORAGE_KEY);
    String? storedIV = await _secureStorage.read(key: IV_STORAGE_KEY);

    if (storedKey == null || storedIV == null) {
      // Generate new key and IV if they don't exist
      _encryptionKey = encrypt.Key.fromSecureRandom(32);
      _iv = encrypt.IV.fromSecureRandom(16);

      // Store them securely
      await _secureStorage.write(
        key: KEY_STORAGE_KEY,
        value: base64Encode(_encryptionKey!.bytes),
      );
      await _secureStorage.write(
        key: IV_STORAGE_KEY,
        value: base64Encode(_iv!.bytes),
      );
    } else {
      // Use existing key and IV
      _encryptionKey = encrypt.Key(base64Decode(storedKey));
      _iv = encrypt.IV(base64Decode(storedIV));
    }
  }
  
  Future<void> loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = prefs.getStringList('accounts') ?? [];
    _accounts = accountsJson
        .map((json) => Account.fromJson(jsonDecode(json)))
        .toList();
    notifyListeners();
  }

  Future<void> saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = _accounts
        .map((account) => jsonEncode(account.toJson()))
        .toList();
    await prefs.setStringList('accounts', accountsJson);
  }

  String encryptPassword(String password) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey!));
    final encrypted = encrypter.encrypt(password, iv: _iv);
    return encrypted.base64;
  }

  String decryptPassword(String encryptedPassword) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey!));
    final decrypted = encrypter.decrypt64(encryptedPassword, iv: _iv);
    return decrypted;
  }

  Future<void> addAccount(String username, String password, String name) async {
    final encryptedPassword = encryptPassword(password);
    final account = Account(
      id: DateTime.now().toString(),
      username: username,
      encryptedPassword: encryptedPassword,
      name: name,
    );
    _accounts.add(account);
    await saveAccounts();
    notifyListeners();
  }

  Future<void> updateAccount(Account account) async {
    final index = _accounts.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      _accounts[index] = account;
      await saveAccounts();
      notifyListeners();
    }
  }

  Future<void> deleteAccount(String id) async {
    _accounts.removeWhere((account) => account.id == id);
    await saveAccounts();
    notifyListeners();
  }

  void setCurrentAccount(Account account) {
    _currentAccount = account;
    notifyListeners();
  }


}