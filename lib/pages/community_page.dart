import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/community_provider.dart';

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

  void _showCommentSheet(String postId) {
    final commentController = TextEditingController();
    final communityProvider = context.read<CommunityProvider>();
    final authorName = context.read<AuthProvider>().username ?? 'ผู้เล่น';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
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
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<PostComment>>(
                stream: communityProvider.commentsOf(postId),
                builder: (context, snapshot) {
                  final comments = snapshot.data ?? [];
                  if (comments.isEmpty) {
                    return const Text('ยังไม่มีความคิดเห็น', style: TextStyle(color: Colors.white38));
                  }
                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final c = comments[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text('${c.authorName}: ${c.content}', style: const TextStyle(color: Colors.white70)),
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
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
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
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
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
          child: StreamBuilder<List<DiscussionPost>>(
            stream: communityProvider.allPosts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text('โหลดกระทู้ไม่สำเร็จ', style: TextStyle(color: Colors.redAccent)),
                );
              }
              final posts = snapshot.data ?? [];
              if (posts.isEmpty) {
                return const Center(
                  child: Text('ยังไม่มีกระทู้ ลองเป็นคนแรกที่พูดคุยดูสิ', style: TextStyle(color: Colors.white38)),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.authorName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(post.content, style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => _showCommentSheet(post.id),
                          icon: const Icon(Icons.mode_comment_outlined, color: Colors.white54, size: 18),
                          label: Text(
                            post.commentCount == 0 ? 'แสดงความคิดเห็น' : '${post.commentCount} ความคิดเห็น',
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
