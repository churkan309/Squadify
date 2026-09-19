import 'package:flutter/material.dart';

// โมเดลเก็บข้อมูลโพสต์ในกระดานสนทนา (เก็บในหน่วยความจำเท่านั้น ยังไม่เชื่อมฐานข้อมูล)
class DiscussionPost {
  final String id;
  final String author;
  final String message;
  final List<String> comments;

  DiscussionPost({
    required this.id,
    required this.author,
    required this.message,
    List<String>? comments,
  }) : comments = comments ?? [];
}

// แท็บ "ชุมชน" กระดานสนทนาแบบง่ายๆ โพสต์ข้อความ + คอมเมนต์ใต้โพสต์
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final List<DiscussionPost> _posts = [];
  final TextEditingController _postController = TextEditingController();
  int _postCounter = 0;

  void _addPost() {
    final text = _postController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _postCounter++;
      _posts.insert(0, DiscussionPost(id: 'post_$_postCounter', author: 'คุณ', message: text));
      _postController.clear();
    });
  }

  void _showCommentSheet(DiscussionPost post) {
    final commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                  if (post.comments.isEmpty)
                    const Text('ยังไม่มีความคิดเห็น', style: TextStyle(color: Colors.white38)),
                  ...post.comments.map(
                    (c) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('• $c', style: const TextStyle(color: Colors.white70)),
                    ),
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
                          setModalState(() => post.comments.add(text));
                          setState(() {});
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
          child: _posts.isEmpty
              ? const Center(
                  child: Text('ยังไม่มีกระทู้ ลองเป็นคนแรกที่พูดคุยดูสิ', style: TextStyle(color: Colors.white38)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _posts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final post = _posts[index];
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
                          Text(post.author, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(post.message, style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => _showCommentSheet(post),
                            icon: const Icon(Icons.mode_comment_outlined, color: Colors.white54, size: 18),
                            label: Text(
                              post.comments.isEmpty ? 'แสดงความคิดเห็น' : '${post.comments.length} ความคิดเห็น',
                              style: const TextStyle(color: Colors.white54),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
