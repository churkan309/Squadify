import 'package:flutter/material.dart';

import '../providers/community_provider.dart';
import '../theme/app_colors.dart';

// การ์ดโพสต์หนึ่งอันในกระดานสนทนา — แยกออกมาจาก community_page.dart
// เพื่อให้ไฟล์หน้าจอเหลือแค่ state/logic ไม่ปนกับโค้ด UI ของการ์ด
class DiscussionPostCard extends StatelessWidget {
  final DiscussionPost post;
  final VoidCallback onCommentTap;

  const DiscussionPostCard({
    super.key,
    required this.post,
    required this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    final authorName = post.authorName.trim().isEmpty
        ? 'ผู้เล่น'
        : post.authorName;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Post by $authorName',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(post.content, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onCommentTap,
            icon: const Icon(
              Icons.mode_comment_outlined,
              color: Colors.white54,
              size: 18,
            ),
            label: Text(
              post.commentCount == 0
                  ? 'แสดงความคิดเห็น'
                  : '${post.commentCount} ความคิดเห็น',
              style: const TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }
}
