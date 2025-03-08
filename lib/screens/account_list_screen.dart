import 'dart:async';

import 'package:flutter/material.dart';
import 'package:linout_iust/screens/home_page.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../providers/account_provider.dart';
import '../services/network_service.dart';

class AccountListScreen extends StatelessWidget {
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Accounts')),
      body: Consumer<AccountProvider>(
        builder: (context, accountProvider, child) {
          return ListView.builder(
            itemCount: accountProvider.accounts.length,
            itemBuilder: (context, index) {
              final account = accountProvider.accounts[index];
              return Column(
                children: [
                  Card(
                    elevation: 2.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      title: Text(account.name),
                      subtitle: Text(account.username),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            tooltip: "Edit Account",
                            onPressed: () => _editAccount(context, account),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            tooltip: "Delete Account",
                            onPressed: () => _deleteAccount(context, account),
                          ),
                          IconButton(
                            icon: Icon(Icons.link, color: Colors.green),
                            tooltip: "Connect Account",
                            onPressed: () async =>
                                await _connectAccount(context, account),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Divider(
                  //   thickness: .5,
                  // ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff0e6a8c),
        foregroundColor: Colors.white,
        onPressed: () => _addAccount(context),
        child: Icon(Icons.add),
        tooltip: 'Add Account',
      ),
    );
  }

  void _addAccount(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AccountFormScreen()),
    );
  }

  void _editAccount(BuildContext context, Account account) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountFormScreen(account: account),
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context, Account account) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Text('Are you sure you want to delete this account?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      Provider.of<AccountProvider>(context, listen: false)
          .deleteAccount(account.id);
    }
  }

  Future<void> _connectAccount(BuildContext context, Account account) async {
    final NetworkService _networkService = NetworkService();
    final provider = Provider.of<AccountProvider>(context, listen: false);
    var info = await _networkService.getInfo();
    if (info.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('not connected to iust network'),
        ),
      );
      return;
    } else if (info.length == 3) {
      await _networkService.disconnect();
    }
    final password = provider.decryptPassword(account.encryptedPassword);
    final success = await _networkService.connect(
      account.username,
      password,
    );
    if (!context.mounted) return;
    if (success) {
      //show popup
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected successfully'),
        ),
      );
      // Find the nearest HomePage ancestor and switch to Info tab (index 1)
      final homePage = context.findAncestorStateOfType<HomePageState>();
      if (homePage != null) {
        homePage.onItemTapped(1); // Switch to the Info tab
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect'),
        ),
      );
    }
  }
}

// lib/screens/account_form_screen.dart
class AccountFormScreen extends StatefulWidget {
  final Account? account;

  AccountFormScreen({this.account});

  @override
  _AccountFormScreenState createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends State<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name);
    _usernameController = TextEditingController(text: widget.account?.username);
    _passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account == null ? 'Add Account' : 'Edit Account'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a username' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (widget.account == null && (value?.isEmpty ?? true)) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text('Save'),
                onPressed: _saveAccount,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveAccount() {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = Provider.of<AccountProvider>(context, listen: false);

      if (widget.account == null) {
        provider.addAccount(
          _usernameController.text,
          _passwordController.text,
          _nameController.text,
        );
      } else {
        final updatedAccount = Account(
          id: widget.account!.id,
          username: _usernameController.text,
          encryptedPassword: _passwordController.text.isNotEmpty
              ? provider.encryptPassword(_passwordController.text)
              : widget.account!.encryptedPassword,
          name: _nameController.text,
          // isConnected: widget.account!.isConnected,
          // lastConnection: widget.account!.lastConnection,
          // totalTrafficUsage: widget.account!.totalTrafficUsage,
        );
        provider.updateAccount(updatedAccount);
      }

      Navigator.pop(context);
    }
  }
}
