import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../services/auth_service.dart';
import '../validation/form_validator.dart';
import 'main_navigation_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> _login() async {
    final success = await _authService.login(
      _usernameController.text,
      _passwordController.text,
    );
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigationPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Squadify')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300.0),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(15.0),
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Login',
                      style: TextStyle(color: Color.fromARGB(255, 238, 234, 234), fontSize: 30),
                    ),
                    const SizedBox(height: 20.0),
                    FormBuilderTextField(
                      name: 'username',
                      style: const TextStyle(color: Colors.white),
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      validator: FormValidator.validateUsername,
                    ),
                    const SizedBox(height: 20.0),
                    FormBuilderTextField(
                      name: 'password',
                      style: const TextStyle(color: Colors.white),
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Color.fromARGB(255, 238, 235, 235)),
                      ),
                      validator: FormValidator.validatePassword,
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          _login();
                        }
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Color.fromARGB(255, 13, 13, 13)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
