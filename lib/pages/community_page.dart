import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/community_provider.dart';
import '../widgets/async_stream_section.dart';
import '../widgets/comment_sheet.dart';
import '../widgets/discussion_post_card.dart';

// แท็บ "ชุมชน" กระดานสนทนา คุย Firestore ผ่าน CommunityProvider
// ทุกคนเห็นโพสต์เดียวกันจาก Firestore เสมอ, shared_preferences ใช้แค่
// (1) cache โพสต์ล่าสุดไว้ดู offline (2) เก็บ draft ข้อความที่พิมพ์ค้างไว้
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final TextEditingController _postController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    final draft = await context.read<CommunityProvider>().readDraft();
    if (mounted && draft.isNotEmpty) {
      _postController.text = draft;
    }
  }

  Future<void> _addPost() async {
    final text = _postController.text.trim();
    if (text.isEmpty) return;
    final authorName = context.read<AuthProvider>().username ?? 'ผู้เล่น';
    await context.read<CommunityProvider>().addPost(text, authorName);
    _postController.clear();
  }

  void _openComments(String postId) {
    showCommentSheet(
      context,
      postId: postId,
      communityProvider: context.read<CommunityProvider>(),
      authorName: context.read<AuthProvider>().username ?? 'ผู้เล่น',
    );
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final communityProvider = context.read<CommunityProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _postController,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (text) => communityProvider.saveDraft(text),
                  decoration: const InputDecoration(
                    hintText: 'พูดคุยอะไรกับชุมชนดี...',
                    hintStyle: TextStyle(color: Colors.white38),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _addPost,
              ),
            ],
          ),
        ),
        Expanded(
          child: AsyncStreamSection<List<DiscussionPost>>(
            stream: communityProvider.allPosts,
            isEmpty: (posts) => posts.isEmpty,
            emptyMessage: 'ยังไม่มีกระทู้ ลองเป็นคนแรกที่พูดคุยดูสิ',
            errorMessage: 'โหลดกระทู้ไม่สำเร็จ',
            padding: const EdgeInsets.all(0),
            builder: (context, posts) => ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: posts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => DiscussionPostCard(
                post: posts[index],
                onCommentTap: () => _openComments(posts[index].id),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
