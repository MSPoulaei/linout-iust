// pages/info_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../services/network_service.dart';

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final NetworkService _networkService = NetworkService();
  Map<String, dynamic> _info = {};
  final _defaultInfo = {
    "isConnected": false,
    "duration": "",
    "ip": "",
    "usage": "",
  };
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchInfo();
    // Set up timer to fetch data every 10 seconds
    _timer = Timer.periodic(Duration(seconds: 60), (timer) {
      _fetchInfo();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchInfo() async {
    var data = await _networkService.getInfo();
    if (data.isEmpty) {
      setState(() {
        _info = _defaultInfo;
        _info["lastUpdated"] = DateTime.now().toString();
      });
    } else if (data.length == 1) {
      setState(() {
        _info = {
          "isConnected": false,
          "ip": data[0],
          "usage": "",
          "duration": "",
          'lastUpdated': DateTime.now().toString(),
        };
      });
    } else {
      setState(() {
        _info = {
          "isConnected": true,
          "ip": data[0],
          "usage": data[1],
          "duration": data[2],
          'lastUpdated': DateTime.now().toString(),
        };
      });
    }
  }

  String _timeAgo(DateTime dateTime) {
    Duration diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 1) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours > 1) {
      return '${diff.inHours} hours ago';
    } else if (diff.inMinutes > 1) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inSeconds > 5) {
      return '${diff.inSeconds} seconds ago';
    } else {
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    var iconColor = _info['isConnected'] == true ? Colors.green : Colors.red;
    return Scaffold(
      appBar: AppBar(
        title: Text('Network Status'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchInfo,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoRow(
                      icon: Icons.wifi,
                      label: 'IP',
                      value: _info['ip'] ?? 'Loading...',
                      iconColor: iconColor,
                      copyable: true,
                    ),
                    SizedBox(height: 16),
                    InfoRow(
                      icon: Icons.data_usage,
                      label: 'Total Usage(U/D)',
                      value: _info['usage'] ?? 'Loading...',
                      iconColor: iconColor,
                    ),
                    SizedBox(height: 16),
                    InfoRow(
                      icon: Icons.timer,
                      label: 'Duration',
                      value: _info['duration'] ?? 'Loading...',
                      iconColor: iconColor,
                    ),
                    SizedBox(height: 16),
                    // Text(
                    //   'Last Updated: ${_info['lastUpdated'] != null ? _timeAgo(DateTime.parse(_info['lastUpdated'])) : 'Loading...'}',
                    //   style: TextStyle(fontSize: 12, color: Colors.grey),
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Last Updated: ${_info['lastUpdated'] != null ? _timeAgo(DateTime.parse(_info['lastUpdated'])) : 'Loading...'}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        IconButton(
                          icon: Icon(Icons.refresh, color: Colors.blue),
                          onPressed: _fetchInfo,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    if (_info['isConnected'] == true)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        onPressed: () async {
                          bool success = await _networkService.disconnect();
                          if (success) {
                            await _fetchInfo();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Disconnected successfully')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to disconnect')),
                            );
                          }
                        },
                        child: Text('Disconnect'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final bool copyable;

  const InfoRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.iconColor,
      this.copyable = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            color: iconColor ?? Theme.of(context).colorScheme.primary,
            size: 24),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 4),
              if (copyable)
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$label copied to clipboard')),
                    );
                  },
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
