import 'package:flutter/material.dart';

// ครอบ StreamBuilder<T> ให้จัดการ loading / error / empty ให้อัตโนมัติ
// ก่อนหน้านี้ pattern (waiting -> spinner, hasError -> ข้อความแดง, ว่าง -> ข้อความเทา)
// ถูก copy ซ้ำหลายจุดใน home_tab_page (2 รอบ) และ community_page
class AsyncStreamSection<T> extends StatelessWidget {
  final Stream<T> stream;
  final Widget Function(BuildContext context, T data) builder;
  final bool Function(T data)? isEmpty;
  final String emptyMessage;
  final String errorMessage;
  final EdgeInsetsGeometry padding;

  const AsyncStreamSection({
    super.key,
    required this.stream,
    required this.builder,
    this.isEmpty,
    this.emptyMessage = 'ยังไม่มีข้อมูล',
    this.errorMessage = 'โหลดข้อมูลไม่สำเร็จ',
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: padding,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: padding,
            child: Center(
              child: Text(errorMessage, style: const TextStyle(color: Colors.redAccent)),
            ),
          );
        }
        final data = snapshot.data;
        if (data == null || (isEmpty?.call(data) ?? false)) {
          return Padding(
            padding: padding,
            child: Center(
              child: Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38),
              ),
            ),
          );
        }
        return builder(context, data);
      },
    );
  }
}
