import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

// โครงหน้าจอกลางที่ login_page และ register_page ใช้ร่วมกัน
// (AppBar "Squadify", กรอบกว้าง 300, FormBuilder, หัวข้อ, spacing ระหว่าง field)
// ก่อนหน้านี้สองหน้านี้ copy Scaffold/ConstrainedBox/FormBuilder ทั้งชุดซ้ำกันเกือบ 100%
class AuthPageScaffold extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;
  final String title;
  final List<Widget> fields;
  final Widget submitButton;
  final Widget footer;

  const AuthPageScaffold({
    super.key,
    required this.formKey,
    required this.title,
    required this.fields,
    required this.submitButton,
    required this.footer,
  });

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
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 238, 234, 234),
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    for (final field in fields) ...[
                      field,
                      const SizedBox(height: 20.0),
                    ],
                    submitButton,
                    const SizedBox(height: 12.0),
                    footer,
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

// FormBuilderTextField สไตล์มาตรฐานของหน้า auth (ตัวหนังสือ/label สีขาว, border, validator)
class AuthTextField extends StatelessWidget {
  final String name;
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;

  const AuthTextField({
    super.key,
    required this.name,
    required this.controller,
    required this.labelText,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: name,
      style: const TextStyle(color: Colors.white),
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        labelStyle: const TextStyle(color: Colors.white),
      ),
      validator: validator,
    );
  }
}

// ปุ่ม submit ของหน้า auth — โชว์ spinner แทนข้อความตอนกำลังส่งคำขอ
class AuthSubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String label;

  const AuthSubmitButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label, style: const TextStyle(color: Color.fromARGB(255, 13, 13, 13))),
    );
  }
}

// ปุ่มข้อความท้ายฟอร์ม (สลับไป Login/Register)
class AuthFooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AuthFooterLink({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(color: Colors.white70)),
    );
  }
}
