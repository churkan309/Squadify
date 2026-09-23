import 'package:flutter/material.dart';

import '../providers/community_provider.dart';
import '../theme/app_colors.dart';

// bottom sheet แสดง/เพิ่มคอมเมนต์ของโพสต์หนึ่งอัน — แยกออกมาจาก community_page.dart
void showCommentSheet(
  BuildContext context, {
  required String postId,
  required CommunityProvider communityProvider,
  required String authorName,
}) {
  final commentController = TextEditingController();

  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ความคิดเห็น',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<PostComment>>(
              stream: communityProvider.commentsOf(postId),
              builder: (context, snapshot) {
                final comments = snapshot.data ?? [];
                if (comments.isEmpty) {
                  return const Text(
                    'ยังไม่มีความคิดเห็น',
                    style: TextStyle(color: Colors.white38),
                  );
                }
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final c = comments[index];
                      final authorName = c.authorName.trim().isEmpty
                          ? 'ผู้เล่น'
                          : c.authorName;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '$authorName: ${c.content}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'แสดงความคิดเห็น...',
                      hintStyle: TextStyle(color: Colors.white38),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    final text = commentController.text.trim();
                    if (text.isEmpty) return;
                    communityProvider.addComment(postId, text, authorName);
                    commentController.clear();
                  },
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
