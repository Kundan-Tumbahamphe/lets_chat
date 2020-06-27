import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_chat/models/user_data.dart';
import 'package:lets_chat/models/user_model.dart';
import 'package:lets_chat/services/db_service.dart';
import 'package:lets_chat/services/storage_service.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';

class CreateChatScreen extends StatefulWidget {
  final List<User> selectedUsers;

  const CreateChatScreen(this.selectedUsers);

  @override
  _CreateChatScreenState createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends State<CreateChatScreen> {
  final _nameFieldKey = GlobalKey<FormFieldState>();
  String _name;
  File _image;
  bool _isLoading = false;

  _handelImageFromGallery() async {
    PickedFile pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  _displayChatImage() {
    return GestureDetector(
      onTap: _handelImageFromGallery,
      child: CircleAvatar(
        radius: 60.0,
        backgroundColor: Colors.grey[300],
        backgroundImage: _image != null ? FileImage(_image) : null,
        child: _image == null
            ? Icon(Icons.add_a_photo,
                size: 40.0, color: Theme.of(context).primaryColor)
            : null,
      ),
    );
  }

  _submit() async {
    if (_nameFieldKey.currentState.validate() && !_isLoading) {
      _nameFieldKey.currentState.save();

      if (_image != null) {
        List<String> userIds =
            widget.selectedUsers.map((user) => user.id).toList();

        userIds
            .add(Provider.of<UserData>(context, listen: false).currentUserID);

        setState(() => _isLoading = true);

        String imageUrl =
            await Provider.of<StorageService>(context, listen: false)
                .uploadChatImageAndGetDownloadUrl(imageFile: _image, url: null);

        Provider.of<DatabaseService>(context, listen: false)
            .createChat(
          name: _name,
          imageUrl: imageUrl,
          usersIds: userIds,
        )
            .then(
          (success) {
            if (success) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                  (Route<dynamic> route) => false);
            }
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create chat'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _isLoading
                ? LinearProgressIndicator(
                    backgroundColor: Colors.blue,
                    valueColor: const AlwaysStoppedAnimation(Colors.white70),
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 50.0),
            _displayChatImage(),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: TextFormField(
                key: _nameFieldKey,
                decoration: InputDecoration(
                  hintText: 'Enter chat name',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2.50),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2.50),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  prefixIcon: Icon(
                    Icons.message,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                validator: (input) =>
                    input.trim().isEmpty ? 'Please enter a valid name' : null,
                onSaved: (input) => _name = input,
              ),
            ),
            const SizedBox(height: 20.0),
            Container(
              width: 140.0,
              height: 50.0,
              child: RaisedButton(
                onPressed: _submit,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                color: Theme.of(context).primaryColor,
                child: const Text(
                  'Create',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
