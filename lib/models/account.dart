class Account {
  String id;
  String username;
  String encryptedPassword;
  String name;
  // bool isConnected;
  // DateTime? lastConnection;
  // int totalTrafficUsage;

  Account({
    required this.id,
    required this.username,
    required this.encryptedPassword,
    required this.name,
    // this.isConnected = false,
    // this.lastConnection,
    // this.totalTrafficUsage = 0,
  });

  // Convert to/from JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'encryptedPassword': encryptedPassword,
    'name': name,
    // 'isConnected': isConnected,
    // 'lastConnection': lastConnection?.toIso8601String(),
    // 'totalTrafficUsage': totalTrafficUsage,
  };

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    id: json['id'],
    username: json['username'],
    encryptedPassword: json['encryptedPassword'],
    name: json['name'],
    // isConnected: json['isConnected'],
    // lastConnection: json['lastConnection'] != null 
    //     ? DateTime.parse(json['lastConnection'])
    //     : null,
    // totalTrafficUsage: json['totalTrafficUsage'],
  );
}