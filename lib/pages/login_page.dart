import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../services/auth_service.dart';
import '../validation/form_validator.dart';
import '../widgets/auth_widgets.dart';
import 'main_navigation_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signIn(
        _emailController.text,
        _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigationPage()),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSubmit() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      _login();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      formKey: _formKey,
      title: 'Login',
      fields: [
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
        label: 'เข้าสู่ระบบ',
      ),
      footer: AuthFooterLink(
        label: 'ยังไม่มีบัญชี? สมัครสมาชิก',
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const RegisterPage()));
        },
      ),
    );
  }
}
