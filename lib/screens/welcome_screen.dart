import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lets_chat/services/auth_service.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _selectedIndex = 0;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  String _name, _email, _password;

  _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: <Widget>[
          _buildEmailTF(),
          _buildPasswordTF(),
        ],
      ),
    );
  }

  _buildRegisterForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        children: <Widget>[
          _buildNameTF(),
          _buildEmailTF(),
          _buildPasswordTF(),
        ],
      ),
    );
  }

  _buildNameTF() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: TextFormField(
        decoration: const InputDecoration(labelText: 'Name'),
        validator: (input) =>
            input.trim().isEmpty ? 'Please enter a valid name' : null,
        onSaved: (input) => _name = input,
      ),
    );
  }

  _buildEmailTF() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: TextFormField(
        decoration: const InputDecoration(labelText: 'Email'),
        validator: (input) =>
            !input.contains('@') ? 'Please enter a valid email' : null,
        onSaved: (input) => _email = input.trim(),
      ),
    );
  }

  _buildPasswordTF() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: 'Password',
          focusColor: Colors.red,
        ),
        validator: (input) =>
            input.length < 6 ? 'Password length must be 6 characters' : null,
        onSaved: (input) => _password = input,
        obscureText: true,
      ),
    );
  }

  _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  _submit() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final loginFormKeyState = _loginFormKey.currentState;
    final registerFormKeyState = _registerFormKey.currentState;

    try {
      if (_selectedIndex == 0 && loginFormKeyState.validate()) {
        loginFormKeyState.save();
        await authService.signIn(email: _email, password: _password);
      } else if (_selectedIndex == 1 && registerFormKeyState.validate()) {
        registerFormKeyState.save();
        await authService.signUp(
            name: _name, email: _email, password: _password);
      }
    } on PlatformException catch (e) {
      _showErrorDialog(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Let\'s Chat!',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 40.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    height: 45.0,
                    width: 120.0,
                    child: FlatButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 0;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        side: _selectedIndex == 0
                            ? BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2.50)
                            : BorderSide.none,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: Colors.grey[300],
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18.0,
                          letterSpacing: 0.8,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 45.0,
                    width: 120.0,
                    child: FlatButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        side: _selectedIndex == 1
                            ? BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2.50)
                            : BorderSide.none,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: Colors.grey[300],
                      child: Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 18.0,
                          letterSpacing: 0.8,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              _selectedIndex == 0 ? _buildLoginForm() : _buildRegisterForm(),
              const SizedBox(height: 20.0),
              Container(
                height: 45.0,
                width: 120.0,
                child: FlatButton(
                  onPressed: _submit,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 18.0,
                      letterSpacing: 0.8,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
