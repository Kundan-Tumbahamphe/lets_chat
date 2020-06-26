import 'package:flutter/material.dart';
import 'package:lets_chat/models/user_data.dart';
import 'package:lets_chat/services/db_service.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';

class SearchUserScreen extends StatefulWidget {
  @override
  _SearchUserScreenState createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final _searchController = TextEditingController();
  List<User> _users = [];
  List<User> _selectedUsers = [];

  _clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _searchController.clear());
    setState(() {
      _users = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Provider.of<UserData>(context).currentUserID;

    return Scaffold(
      appBar: AppBar(
        title: Text('Search users'),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
              border: InputBorder.none,
              hintText: 'Enter user name',
              prefixIcon: Icon(
                Icons.search,
                size: 30.0,
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: _clearSearch,
              ),
              filled: true,
            ),
            onSubmitted: (input) async {
              if (input.trim().isNotEmpty) {
                List<User> users =
                    await Provider.of<DatabaseService>(context, listen: false)
                        .searchUsers(name: input, userId: currentUserId);

                _selectedUsers.forEach((user) => users.remove(user));

                setState(() {
                  _users = users;
                });
              }
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedUsers.length + _users.length,
              itemBuilder: (BuildContext context, int index) {
                if (index < _selectedUsers.length) {
                  User selectedUser = _selectedUsers[index];
                  return ListTile(
                    title: Text(selectedUser.name),
                    trailing: Icon(Icons.check_circle),
                    onTap: () {
                      setState(() {
                        _selectedUsers.remove(selectedUser);
                      });
                    },
                  );
                }
                int userIndex = index - _selectedUsers.length;
                User user = _users[userIndex];
                return ListTile(
                  title: Text(user.name),
                  trailing: Icon(Icons.check_circle_outline),
                  onTap: () {
                    setState(() {
                      _selectedUsers.add(user);
                      _users.remove(user);
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
