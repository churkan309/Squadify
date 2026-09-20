import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../services/auth_service.dart';
import '../validation/form_validator.dart';
import '../widgets/auth_widgets.dart';
import 'main_navigation_page.dart';

// หน้าสมัครสมาชิก: username (เก็บเป็น displayName), email, password จริงผ่าน Firebase Auth
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signUp(
        _emailController.text,
        _passwordController.text,
        _usernameController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainNavigationPage()),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSubmit() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      _register();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      formKey: _formKey,
      title: 'Register',
      fields: [
        AuthTextField(
          name: 'username',
          controller: _usernameController,
          labelText: 'Username',
          validator: FormValidator.validateUsername,
        ),
        AuthTextField(
          name: 'email',
          controller: _emailController,
          labelText: 'Email',
          keyboardType: TextInputType.emailAddress,
          validator: FormValidator.validateEmail,
        ),
        AuthTextField(
          name: 'password',
          controller: _passwordController,
          labelText: 'Password',
          obscureText: true,
          validator: FormValidator.validatePassword,
        ),
      ],
      submitButton: AuthSubmitButton(
        isLoading: _isLoading,
        onPressed: _onSubmit,
        label: 'สมัครสมาชิก',
      ),
      footer: AuthFooterLink(
        label: 'มีบัญชีอยู่แล้ว? เข้าสู่ระบบ',
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}
